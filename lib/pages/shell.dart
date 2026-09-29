import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/control/connect_orb.dart';
import 'package:fl_clash/views/control/control_center.dart';
import 'package:fl_clash/views/control/tiles.dart';
import 'package:fl_clash/views/po0_firewall.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef OnDestinationSelected = void Function(PageLabel label);

Color pageAccentOf(BuildContext context, PageLabel label) {
  final colorScheme = context.colorScheme;
  return switch (label) {
    PageLabel.profiles => colorScheme.tertiary,
    PageLabel.po0 => context.toneColor(GlassTone.success),
    PageLabel.activity => context.toneColor(GlassTone.warning),
    PageLabel.tools => colorScheme.onSurfaceVariant,
    _ => colorScheme.primary,
  };
}

IconData _iconOf(NavigationItem item) => item.icon.icon ?? Icons.circle;

/// The floating capsule that navigates on phones. Pages scroll beneath it, so
/// it is the one surface that blurs what it covers.
class GlassDock extends StatelessWidget {
  const GlassDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  static const height = 66.0;
  static const margin = 12.0;

  static double extentOf(BuildContext context) =>
      height + margin * 2 + MediaQuery.paddingOf(context).bottom;

  final List<NavigationItem> items;
  final int currentIndex;
  final OnDestinationSelected onSelected;

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    final duration = context.motionDuration(Durations.medium2);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        margin,
        16,
        margin + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        height: height,
        child: GlassSurface(
          kind: GlassKind.chrome,
          borderRadius: AppRadius.full,
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Stack(
                children: [
                  if (count > 0)
                    AnimatedAlign(
                      duration: duration,
                      curve: Easing.emphasizedDecelerate,
                      alignment: Alignment(
                        count == 1 ? 0 : -1 + 2 * currentIndex / (count - 1),
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / count,
                        heightFactor: 1,
                        child: const _SelectionPill(),
                      ),
                    ),
                  Row(
                    children: [
                      for (final (index, item) in items.indexed)
                        Expanded(
                          child: _DockItem(
                            icon: _iconOf(item),
                            label: item.label.label,
                            selected: index == currentIndex,
                            onTap: () => onSelected(item.label),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill();

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: glass.selected,
        shape: AppShape.full.copyWith(
          side: BorderSide(color: glass.selectedRim),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: AppShape.full,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The narrow-window navigation: a vertical glass capsule of icons.
class GlassRail extends StatelessWidget {
  const GlassRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  static const width = 84.0;
  static const _itemHeight = 64.0;

  final List<NavigationItem> items;
  final int currentIndex;
  final OnDestinationSelected onSelected;

  @override
  Widget build(BuildContext context) {
    final duration = context.motionDuration(Durations.medium2);
    return SizedBox(
      width: width,
      child: GlassSurface(
        kind: GlassKind.panel,
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Stack(
              children: [
                if (items.isNotEmpty)
                  AnimatedPositioned(
                    duration: duration,
                    curve: Easing.emphasizedDecelerate,
                    top: currentIndex * _itemHeight,
                    left: 0,
                    right: 0,
                    height: _itemHeight,
                    child: const _SelectionPill(),
                  ),
                Column(
                  children: [
                    for (final (index, item) in items.indexed)
                      SizedBox(
                        height: _itemHeight,
                        child: _DockItem(
                          icon: _iconOf(item),
                          label: item.label.label,
                          selected: index == currentIndex,
                          onTap: () => onSelected(item.label),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The wide-window sidebar: the whole control center on top, the spaces below
/// it with a live line each, and the network at the foot.
class ControlSidebar extends StatelessWidget {
  const ControlSidebar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    this.topInset = 0,
  });

  static const width = 300.0;

  final List<NavigationItem> items;
  final int currentIndex;
  final OnDestinationSelected onSelected;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassSurface(
        kind: GlassKind.panel,
        child: Material(
          type: MaterialType.transparency,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 0),
                sliver: const SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    BrandHeader(dense: true),
                    SizedBox(height: 12),
                    Center(child: ConnectOrb(size: 176)),
                    SizedBox(height: 12),
                    OutboundModeSwitch(height: 40),
                    SizedBox(height: 18),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverList.list(
                  children: [
                    for (final (index, item) in items.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _SidebarItem(
                          item: item,
                          selected: index == currentIndex,
                          onTap: () => onSelected(item.label),
                        ),
                      ),
                  ],
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: _SidebarFooter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends ConsumerWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  String? _subtitleOf(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    switch (item.label) {
      case PageLabel.proxies:
        final group = leadingGroupOf(ref);
        if (group == null) {
          return null;
        }
        return ref.watch(selectedProxyNameProvider(group.name));
      case PageLabel.profiles:
        return ref.watch(
          currentProfileProvider.select((state) => state?.realLabel),
        );
      case PageLabel.po0:
        final setting = ref.watch(po0FirewallSettingProvider);
        return po0OverviewOf(
          appLocalizations,
          enabled: setting.enable,
          hasTokens: po0TokensOf(setting.tokenEntries).isNotEmpty,
          state: ref.watch(po0FirewallProvider),
        ).title;
      case PageLabel.activity:
        return appLocalizations.activityDesc;
      default:
        return item.label.description;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = _subtitleOf(context, ref);
    final colorScheme = context.colorScheme;
    return GlassButton(
      selected: selected,
      elevated: false,
      color: selected ? null : Colors.transparent,
      rimColor: selected ? null : Colors.transparent,
      borderRadius: AppRadius.medium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      onTap: onTap,
      child: Row(
        children: [
          GlassIconBadge(
            icon: _iconOf(item),
            color: pageAccentOf(context, item.label),
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: selected ? colorScheme.primary : null,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  EmojiText(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final traffic = ref.watch(trafficsProvider).list.lastOrNull;
    final ipInfo = ref.watch(networkDetectionProvider).ipInfo;
    final style = context.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.north_rounded, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${(traffic?.up ?? 0).traffic.show}/s',
                  maxLines: 1,
                  style: style,
                ),
              ),
              Icon(Icons.south_rounded, size: 14, color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${(traffic?.down ?? 0).traffic.show}/s',
                  maxLines: 1,
                  style: style,
                ),
              ),
            ],
          ),
          if (ipInfo != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.public_rounded,
                  size: 14,
                  color: context.toneColor(GlassTone.success),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${ipInfo.countryCode} · ${ipInfo.ip}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style?.copyWith(
                      fontFamily: FontFamily.jetBrainsMono.value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The aurora behind the whole window, drifting to each space's own scene.
class AppBackdrop extends ConsumerWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  static AuroraScene sceneOf(PageLabel label) => switch (label) {
    PageLabel.dashboard => AuroraScene.home,
    PageLabel.proxies => AuroraScene.proxies,
    PageLabel.profiles => AuroraScene.profiles,
    PageLabel.po0 => AuroraScene.po0,
    PageLabel.activity ||
    PageLabel.connections ||
    PageLabel.requests ||
    PageLabel.logs => AuroraScene.activity,
    PageLabel.tools || PageLabel.resources => AuroraScene.settings,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = sceneOf(ref.watch(currentPageLabelProvider));
    return AuroraSceneScope(
      scene: scene,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: AuroraBackdrop(scene: scene)),
          child,
        ],
      ),
    );
  }
}
