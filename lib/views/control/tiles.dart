import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/activity.dart';
import 'package:fl_clash/views/config/network.dart';
import 'package:fl_clash/views/po0_firewall.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tilePadding = EdgeInsets.all(16);

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.icon,
    required this.label,
    this.color,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Row(
      children: [
        GlassIconBadge(icon: icon, color: color, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class OutboundModeSwitch extends ConsumerWidget {
  const OutboundModeSwitch({super.key, this.height = 44});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return GlassSegmented<Mode>(
      height: height,
      values: Mode.values,
      selected: mode,
      labelOf: (mode) => mode.label,
      onChanged: (mode) {
        ref.read(setupActionProvider.notifier).changeMode(mode);
      },
    );
  }
}

/// The group the proxies page opens on, or the first one it lists.
Group? leadingGroupOf(WidgetRef ref) {
  final groups = ref.watch(currentGroupsStateProvider).value;
  final preferred = ref.watch(
    currentProfileProvider.select((state) => state?.currentGroupName),
  );
  return groups.firstWhereOrNull((group) => group.name == preferred) ??
      groups.firstOrNull;
}

class CurrentNodeCard extends ConsumerWidget {
  const CurrentNodeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.mode),
    );
    final group = leadingGroupOf(ref);
    final selected = group == null
        ? null
        : ref.watch(selectedProxyNameProvider(group.name));
    final title = switch ((mode, selected)) {
      (Mode.direct, _) => appLocalizations.direct,
      (_, final String name) when name.isNotEmpty => name,
      _ => appLocalizations.noProxySelected,
    };
    return GlassButton(
      padding: _tilePadding,
      onTap: () =>
          ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.proxies),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.hub_rounded,
            label: group == null || mode == Mode.direct
                ? appLocalizations.currentProxy
                : group.name,
            trailing: selected == null || mode == Mode.direct
                ? null
                : _DelayPill(proxyName: selected, testUrl: group?.testUrl),
          ),
          const SizedBox(height: 12),
          EmojiText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DelayPill extends ConsumerWidget {
  const _DelayPill({required this.proxyName, this.testUrl});

  final String proxyName;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: proxyName, testUrl: testUrl),
    );
    if (delay == null || delay == 0) {
      return const SizedBox.shrink();
    }
    final color = getDelayColor(delay) ?? context.colorScheme.onSurfaceVariant;
    return GlassPill(color: color, label: delay > 0 ? '$delay ms' : 'Timeout');
  }
}

class TrafficCard extends ConsumerWidget {
  const TrafficCard({super.key});

  void _openActivity(BuildContext context, WidgetRef ref) {
    if (context.isMobileView) {
      BaseNavigator.push(context, const ActivityView());
      return;
    }
    ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.activity);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final traffics = ref.watch(trafficsProvider).list;
    final last = traffics.lastOrNull ?? const Traffic();
    final total = ref.watch(totalTrafficProvider);
    return RepaintBoundary(
      child: GlassButton(
        padding: _tilePadding,
        onTap: () => _openActivity(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(
              icon: Icons.speed_rounded,
              label: appLocalizations.networkSpeed,
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SpeedValue(
                    icon: Icons.north_rounded,
                    value: last.up,
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _SpeedValue(
                    icon: Icons.south_rounded,
                    value: last.down,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              child: LineChart(
                gradient: true,
                color: colorScheme.primary,
                points: [
                  const Point(0, 0),
                  const Point(1, 0),
                  for (final (index, traffic) in traffics.indexed)
                    Point(index + 2, traffic.speed.toDouble()),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${appLocalizations.trafficUsage}  ${total.desc}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedValue extends StatelessWidget {
  const _SpeedValue({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final num value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final show = value.traffic;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: show.value,
              style: context.textTheme.titleLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              children: [
                TextSpan(
                  text: ' ${show.unit}/s',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class Po0StatusCard extends ConsumerWidget {
  const Po0StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final setting = ref.watch(po0FirewallSettingProvider);
    final state = ref.watch(po0FirewallProvider);
    final overview = po0OverviewOf(
      appLocalizations,
      enabled: setting.enable,
      hasTokens: po0TokensOf(setting.tokenEntries).isNotEmpty,
      state: state,
    );
    final color = context.toneColor(overview.tone);
    final exitIp = state.results.map((it) => it.currentIp).nonNulls.firstOrNull;
    return GlassButton(
      padding: _tilePadding,
      onTap: () =>
          ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.po0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: overview.icon,
            label: appLocalizations.po0Nav,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            overview.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium,
          ),
          if (exitIp != null) ...[
            const SizedBox(height: 4),
            Text(
              appLocalizations.po0Exit(exitIp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontFamily: FontFamily.jetBrainsMono.value,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CurrentProfileCard extends ConsumerWidget {
  const CurrentProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    return GlassButton(
      padding: _tilePadding,
      onTap: () => ref
          .read(currentPageLabelProvider.notifier)
          .toPage(PageLabel.profiles),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.layers_rounded,
            label: appLocalizations.profile,
            color: context.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            profile?.realLabel ?? appLocalizations.nullProfileDesc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium,
          ),
          if (profile?.subscriptionInfo case final info?) ...[
            const SizedBox(height: 8),
            SubscriptionInfoView(subscriptionInfo: info),
          ],
        ],
      ),
    );
  }
}

class _QuickToggle extends StatelessWidget {
  const _QuickToggle({
    required this.label,
    required this.icon,
    required this.items,
    required this.selector,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final List<Widget> items;
  final ProviderListenable<bool> selector;
  final void Function(WidgetRef ref, bool value) onChanged;

  void _showOptions(BuildContext context) {
    showSheet(
      context: context,
      builder: (_) => AdaptiveSheetScaffold(
        body: generateListView(generateSection(items: items)),
        title: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Consumer(
      builder: (_, ref, _) {
        final value = ref.watch(selector);
        return GlassButton(
          selected: value,
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          onTap: () => onChanged(ref, !value),
          onLongPress: () => _showOptions(context),
          onSecondaryTap: () => _showOptions(context),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: value
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge,
                ),
              ),
              IconButton(
                tooltip: context.appLocalizations.options,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: () => _showOptions(context),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuickToggles extends StatelessWidget {
  const QuickToggles({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final toggles = [
      if (system.isAndroid)
        _QuickToggle(
          label: 'VPN',
          icon: Icons.vpn_lock_rounded,
          items: const [VPNItem(), VpnSystemProxyItem(), TunStackItem()],
          selector: vpnSettingProvider.select((state) => state.enable),
          onChanged: (ref, value) => ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(enable: value)),
        ),
      if (system.isDesktop) ...[
        _QuickToggle(
          label: appLocalizations.tun,
          icon: Icons.lan_rounded,
          items: [
            const TUNItem(),
            if (system.isMacOS) const AutoSetSystemDnsItem(),
            const TunStackItem(),
          ],
          selector: patchClashConfigProvider.select(
            (state) => state.tun.enable,
          ),
          onChanged: (ref, value) => ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.tun(enable: value)),
        ),
        _QuickToggle(
          label: appLocalizations.systemProxy,
          icon: Icons.settings_ethernet_rounded,
          items: const [SystemProxyItem(), BypassDomainItem()],
          selector: networkSettingProvider.select((state) => state.systemProxy),
          onChanged: (ref, value) => ref
              .read(networkSettingProvider.notifier)
              .update((state) => state.copyWith(systemProxy: value)),
        ),
      ],
    ];
    return Row(
      children: [
        for (final (index, toggle) in toggles.indexed) ...[
          if (index > 0) const SizedBox(width: 10),
          Expanded(child: toggle),
        ],
      ],
    );
  }
}

String _flagOf(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) {
    return countryCode;
  }
  return String.fromCharCodes([
    code.codeUnitAt(0) - 0x41 + 0x1F1E6,
    code.codeUnitAt(1) - 0x41 + 0x1F1E6,
  ]);
}

class NetworkCard extends ConsumerWidget {
  const NetworkCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final detection = ref.watch(networkDetectionProvider);
    final ipInfo = detection.ipInfo;
    final localIp = ref.watch(localIpProvider);
    final valueStyle = context.textTheme.bodyMedium?.copyWith(
      fontFamily: FontFamily.jetBrainsMono.value,
    );
    return GlassSurface(
      padding: _tilePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.public_rounded,
            label: appLocalizations.networkDetection,
            color: context.toneColor(GlassTone.success),
            trailing: IconButton(
              tooltip: appLocalizations.tip,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              onPressed: () => dialogs.showMessage(
                title: appLocalizations.tip,
                message: TextSpan(text: appLocalizations.detectionTip),
                cancelable: false,
              ),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: FadeThroughBox(
              alignment: Alignment.centerLeft,
              child: ipInfo != null
                  ? Row(
                      key: ValueKey(ipInfo),
                      children: [
                        Text(
                          _flagOf(ipInfo.countryCode),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontFamily: FontFamily.twEmoji.value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: TooltipText(
                            text: Text(
                              ipInfo.ip,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: valueStyle,
                            ),
                          ),
                        ),
                      ],
                    )
                  : detection.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CommonCircleLoading(),
                    )
                  : Text(
                      'Timeout',
                      style: valueStyle?.copyWith(
                        color: context.toneColor(GlassTone.danger),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.devices_rounded,
                size: 16,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localIp == null
                      ? '…'
                      : localIp.isNotEmpty
                      ? localIp
                      : appLocalizations.noNetwork,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MemoryInfo extends ConsumerStatefulWidget {
  final Future<num> Function()? memoryReader;

  const MemoryInfo({super.key, @visibleForTesting this.memoryReader});

  @override
  ConsumerState<MemoryInfo> createState() => _MemoryInfoState();
}

class _MemoryInfoState extends ConsumerState<MemoryInfo>
    with WidgetsBindingObserver, ActivePollingMixin<MemoryInfo> {
  final _memoryStateNotifier = ValueNotifier<num>(0);

  CoreController get _core => ref.read(coreHandlerProvider);

  @override
  Duration get pollInterval => const Duration(seconds: 2);

  @override
  void dispose() {
    _memoryStateNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> poll(PollGuard isCurrent) async {
    final memory = await _readMemory();
    if (memory == null || !isCurrent()) {
      return;
    }
    _memoryStateNotifier.value = memory;
  }

  Future<num?> _readMemory() async {
    try {
      final memoryReader = widget.memoryReader;
      return memoryReader != null ? await memoryReader() : await _readTotal();
    } catch (error) {
      commonPrint.log(
        'updateMemory error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  Future<num> _readTotal() async {
    final rss = ProcessInfo.currentRss;
    final coreConnected = ref.read(coreStatusProvider) == CoreStatus.connected;
    if (system.isDesktop && coreConnected) {
      return await _core.getMemory() + rss;
    }
    return rss;
  }

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      padding: _tilePadding,
      tooltip: context.appLocalizations.memoryInfo,
      onTap: _core.requestGc,
      child: Row(
        children: [
          GlassIconBadge(
            icon: Icons.memory_rounded,
            color: context.toneColor(GlassTone.warning),
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _memoryStateNotifier,
              builder: (_, memory, _) => Text(
                memory.traffic.show,
                maxLines: 1,
                style: context.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
