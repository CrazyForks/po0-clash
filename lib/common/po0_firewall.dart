import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fl_clash/models/po0_firewall.dart';

const po0FirewallApiHost = '124.221.69.228';

const po0FirewallDirectCidr = '$po0FirewallApiHost/32';

const _po0FirewallApiBase = 'https://$po0FirewallApiHost/api/firewall';

const _po0TokenPrefix = 'pgnfw_';

class Po0Token {
  final String value;
  final int? slot;

  const Po0Token(this.value, {this.slot});

  String get label => '${value.substring(0, min(12, value.length))}…';

  @override
  bool operator ==(Object other) =>
      other is Po0Token && other.value == value && other.slot == slot;

  @override
  int get hashCode => Object.hash(value, slot);
}

final _po0TokenPattern = RegExp('^$_po0TokenPrefix[^\\s,|;、@]+\$');

bool isPo0Token(String value) => _po0TokenPattern.hasMatch(value);

/// The first entry wins when a token is listed twice, as with the old string.
List<({Po0Token token, String name})> po0TokensOf(List<Po0TokenEntry> entries) {
  final seen = <String>{};
  return [
    for (final entry in entries)
      if (isPo0Token(entry.token) && seen.add(entry.token))
        (token: Po0Token(entry.token, slot: entry.slot), name: entry.name),
  ];
}

List<Po0Token> parsePo0Tokens(String raw) {
  final seen = <String>{};
  final tokens = <Po0Token>[];
  for (final part in raw.split(RegExp(r'[,|;、\s]+'))) {
    if (!part.startsWith(_po0TokenPrefix)) {
      continue;
    }
    final at = part.indexOf('@');
    final value = at == -1 ? part : part.substring(0, at);
    if (!seen.add(value)) {
      continue;
    }
    final slot = at == -1 ? null : int.tryParse(part.substring(at + 1));
    tokens.add(Po0Token(value, slot: slot));
  }
  return tokens;
}

/// The server whitelists whole /24s and echoes entries as IPs or `x.x.x.0/24`.
bool sameC24(String? a, String? b) {
  if (a == null || b == null || a.isEmpty || b.isEmpty) {
    return false;
  }
  if (a == b) {
    return true;
  }
  if (!a.endsWith('/24') && !b.endsWith('/24')) {
    return false;
  }
  final pa = a.replaceAll('/24', '').split('.');
  final pb = b.replaceAll('/24', '').split('.');
  return pa.length == 4 &&
      pb.length == 4 &&
      pa[0] == pb[0] &&
      pa[1] == pb[1] &&
      pa[2] == pb[2];
}

class _Ipv4Cidr {
  final int network;
  final int prefix;

  const _Ipv4Cidr(this.network, this.prefix);

  static _Ipv4Cidr? tryParse(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 2) {
      return null;
    }
    final prefix = int.tryParse(parts[1]);
    final address = InternetAddress.tryParse(parts[0]);
    if (prefix == null ||
        prefix < 0 ||
        prefix > 32 ||
        address == null ||
        address.type != InternetAddressType.IPv4) {
      return null;
    }
    final ip = address.rawAddress.fold<int>(0, (acc, byte) => acc << 8 | byte);
    return _Ipv4Cidr(ip & _mask(prefix), prefix);
  }

  static int _mask(int prefix) =>
      prefix == 0 ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;

  bool contains(_Ipv4Cidr other) =>
      other.prefix >= prefix && (other.network & _mask(prefix)) == network;

  (_Ipv4Cidr, _Ipv4Cidr) split() {
    final next = prefix + 1;
    return (
      _Ipv4Cidr(network, next),
      _Ipv4Cidr(network | (1 << (32 - next)), next),
    );
  }

  @override
  String toString() {
    final octets = [24, 16, 8, 0].map((shift) => (network >> shift) & 0xFF);
    return '${octets.join('.')}/$prefix';
  }
}

/// Android's `VpnService.Builder.excludeRoute` needs API 33, so covering routes
/// are split instead.
List<String> excludeIpv4Route(List<String> routes, String excluded) {
  final target = _Ipv4Cidr.tryParse(excluded);
  if (target == null) {
    return routes;
  }
  final result = <String>[];
  for (final route in routes) {
    final cidr = _Ipv4Cidr.tryParse(route);
    if (cidr == null || !cidr.contains(target)) {
      if (cidr == null || !target.contains(cidr)) {
        result.add(route);
      }
      continue;
    }
    var current = cidr;
    while (current.prefix < target.prefix) {
      final (low, high) = current.split();
      final keepLow = !low.contains(target);
      result.add((keepLow ? low : high).toString());
      current = keepLow ? high : low;
    }
  }
  return result;
}

class Po0HttpResponse {
  final int statusCode;
  final String body;

  const Po0HttpResponse(this.statusCode, this.body);
}

typedef Po0HttpSend = Future<Po0HttpResponse> Function(String method, Uri uri);

/// The API sees the request's source address, so the request must leave on
/// the physical network. The app's global [HttpOverrides] would send it to the
/// mixed port while the proxy runs; TUN capture is handled by the DIRECT rule
/// and route exclusion that setup adds for [po0FirewallDirectCidr]. The pooled
/// socket outlives a network switch, so it is dropped on failure and on change.
class Po0DirectTransport {
  HttpClient? _client;

  HttpClient get _http => _client ??= HttpClient()
    ..findProxy = ((_) => 'DIRECT')
    ..connectionTimeout = const Duration(seconds: 5)
    ..idleTimeout = const Duration(seconds: 30);

  Future<Po0HttpResponse> send(String method, Uri uri) async {
    final client = _http;
    try {
      final request = await client.openUrl(method, uri);
      request.headers.contentType = ContentType.json;
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      return Po0HttpResponse(response.statusCode, body);
    } catch (_) {
      if (identical(client, _client)) {
        reset();
      }
      rethrow;
    }
  }

  void reset() {
    _client?.close(force: true);
    _client = null;
  }
}

/// A FIFO entry still needs an add when the token pins a slot.
bool po0NeedsWhitelist(Po0Token token, Po0TokenResult result) {
  if (result.type == Po0ResultType.notApplied) {
    return true;
  }
  return token.slot != null &&
      result.type == Po0ResultType.applied &&
      result.currentEntry?.slot == null;
}

extension Po0TokenResultExt on Po0TokenResult {
  Po0WhitelistEntry? get currentEntry =>
      whitelist.where((entry) => sameC24(entry.ip, currentIp)).firstOrNull;
}

class Po0FirewallClient {
  final Po0HttpSend? _customSend;
  final void Function()? _customReset;
  final Po0DirectTransport? _transport;
  final Duration retryDelay;
  final Duration requestTimeout;
  final Duration pollTimeout;
  final int maxAttempts;

  Po0FirewallClient({
    Po0HttpSend? send,
    void Function()? resetConnections,
    this.retryDelay = const Duration(milliseconds: 1500),
    this.requestTimeout = const Duration(seconds: 20),
    this.pollTimeout = const Duration(seconds: 5),
    this.maxAttempts = 3,
  }) : _customSend = send,
       _customReset = resetConnections,
       _transport = send == null ? Po0DirectTransport() : null;

  Future<Po0HttpResponse> _send(String method, Uri uri) =>
      (_customSend ?? _transport!.send)(method, uri);

  void resetConnections() => (_customReset ?? _transport?.reset)?.call();

  Future<Po0TokenResult> whitelist(Po0Token token) {
    final slot = token.slot;
    final uri = Uri.parse(
      '$_po0FirewallApiBase/${Uri.encodeComponent(token.value)}/add',
    ).replace(queryParameters: slot == null ? null : {'slot': '$slot'});
    return _call(token, 'POST', uri, isQuery: false);
  }

  /// Read-only: the add endpoint would claim a FIFO slot and evict the oldest
  /// entry whenever the current exit is not listed yet.
  Future<Po0TokenResult> query(Po0Token token) =>
      _call(token, 'GET', _queryUri(token), isQuery: true);

  Future<Po0TokenResult> poll(Po0Token token) => _call(
    token,
    'GET',
    _queryUri(token),
    isQuery: true,
    attempts: 1,
    timeout: pollTimeout,
  );

  Uri _queryUri(Po0Token token) =>
      Uri.parse('$_po0FirewallApiBase/${Uri.encodeComponent(token.value)}');

  Future<Po0TokenResult> _call(
    Po0Token token,
    String method,
    Uri uri, {
    required bool isQuery,
    int? attempts,
    Duration? timeout,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= (attempts ?? maxAttempts); attempt++) {
      if (attempt > 1) {
        await Future.delayed(retryDelay * (attempt - 1));
      }
      try {
        final response = await _send(
          method,
          uri,
        ).timeout(timeout ?? requestTimeout);
        if (_isTransient(response)) {
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }
        return _parse(token, response, isQuery: isQuery);
      } on TimeoutException catch (error) {
        lastError = error;
        resetConnections();
      } catch (error) {
        lastError = error;
      }
    }
    return Po0TokenResult(
      label: token.label,
      slot: token.slot,
      type: Po0ResultType.error,
      message: _redact('$lastError', token),
    );
  }

  // The API occasionally answers a bare 400 "Error" or a 5xx that succeeds a
  // few seconds later; a JSON error body (an invalid token) is final. Retrying
  // add is safe because the server treats a listed exit idempotently.
  bool _isTransient(Po0HttpResponse response) {
    final status = response.statusCode;
    if (status >= 500) {
      return true;
    }
    if ((status >= 200 && status < 300) || status == HttpStatus.forbidden) {
      return false;
    }
    return _decodeMap(response.body) == null;
  }

  Po0TokenResult _parse(
    Po0Token token,
    Po0HttpResponse response, {
    required bool isQuery,
  }) {
    final status = response.statusCode;
    final data = _decodeMap(response.body);
    final base = Po0TokenResult(
      label: token.label,
      slot: token.slot,
      type: Po0ResultType.error,
      currentIp: data?['currentIp']?.toString(),
    );
    if (status == HttpStatus.forbidden && !isQuery) {
      return base.copyWith(type: Po0ResultType.conflict);
    }
    if (data == null) {
      return base.copyWith(message: 'HTTP $status: ${_snippet(response.body)}');
    }
    if (status < 200 || status >= 300) {
      final message = data['message'] ?? data['msg'] ?? data['error'];
      return base.copyWith(
        type: Po0ResultType.rejected,
        message: _redact('${message ?? 'HTTP $status'}', token),
      );
    }
    final rawWhitelist = data['whitelist'];
    if (rawWhitelist is! List) {
      return base.copyWith(message: _snippet(response.body));
    }
    final whitelist = rawWhitelist
        .map(
          (item) => item is Map
              ? Po0WhitelistEntry(
                  ip: '${item['ip']}',
                  slot: item['slot'] is num
                      ? (item['slot'] as num).toInt()
                      : null,
                )
              : Po0WhitelistEntry(ip: '$item'),
        )
        .toList();
    final limit = data['limit'];
    final listed = whitelist
        .where((entry) => sameC24(entry.ip, base.currentIp))
        .firstOrNull;
    final slot = token.slot;
    final type = data['enabled'] == false
        ? Po0ResultType.disabled
        : listed == null
        ? Po0ResultType.notApplied
        : slot != null && listed.slot != null && listed.slot != slot
        ? Po0ResultType.conflict
        : Po0ResultType.applied;
    return base.copyWith(
      type: type,
      whitelist: whitelist,
      limit: limit is num ? limit.toInt() : null,
    );
  }

  Map<String, dynamic>? _decodeMap(String body) {
    try {
      final data = json.decode(body);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  String _snippet(String body) {
    final text = body.trim();
    return text.length > 80 ? '${text.substring(0, 80)}…' : text;
  }

  String _redact(String text, Po0Token token) =>
      text.replaceAll(token.value, token.label);
}
