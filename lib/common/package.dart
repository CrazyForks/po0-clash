import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    '$appName/v$version',
    'clash-verge',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}

typedef _Version = ({List<int> core, List<String> preRelease, int build});

_Version _parseVersion(String version) {
  final normalized = version.trim().replaceFirst(RegExp('^[vV]'), '');
  final [head, ...build] = normalized.split('+');
  final dash = head.indexOf('-');
  final core = (dash < 0 ? head : head.substring(0, dash)).split('.');
  return (
    core: [
      for (var i = 0; i < 3; i++)
        i < core.length ? int.tryParse(core[i]) ?? 0 : 0,
    ],
    preRelease: dash < 0
        ? const <String>[]
        : head.substring(dash + 1).split('.'),
    build: build.isEmpty ? 0 : int.tryParse(build.first) ?? 0,
  );
}

int _compareIdentifiers(String a, String b) {
  final x = int.tryParse(a);
  final y = int.tryParse(b);
  if (x != null && y != null) return x.compareTo(y);
  if (x != null) return -1;
  if (y != null) return 1;
  return a.compareTo(b);
}

/// Semver precedence, then the Flutter build number after `+` as a tiebreaker.
int compareVersions(String version1, String version2) {
  final a = _parseVersion(version1);
  final b = _parseVersion(version2);
  for (var i = 0; i < 3; i++) {
    if (a.core[i] != b.core[i]) {
      return a.core[i].compareTo(b.core[i]);
    }
  }
  if (a.preRelease.isEmpty != b.preRelease.isEmpty) {
    return a.preRelease.isEmpty ? 1 : -1;
  }
  for (var i = 0; i < a.preRelease.length && i < b.preRelease.length; i++) {
    final result = _compareIdentifiers(a.preRelease[i], b.preRelease[i]);
    if (result != 0) return result;
  }
  if (a.preRelease.length != b.preRelease.length) {
    return a.preRelease.length.compareTo(b.preRelease.length);
  }
  return a.build.compareTo(b.build);
}

const releaseNotesBeginMarker = '<!-- flclash:changelog:begin -->';
const releaseNotesEndMarker = '<!-- flclash:changelog:end -->';

List<String> parseReleaseBody(String? body) {
  if (body == null) return [];
  final regex = RegExp(r'^[ \t]*-[ \t]+(.*)$', multiLine: true);
  return regex
      .allMatches(scopeReleaseNotes(body))
      .map((match) => match.group(1)?.trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String scopeReleaseNotes(String body) {
  final begin = body.indexOf(releaseNotesBeginMarker);
  if (begin < 0) return body;
  final start = begin + releaseNotesBeginMarker.length;
  final end = body.indexOf(releaseNotesEndMarker, start);
  return end < 0 ? body.substring(start) : body.substring(start, end);
}
