import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/manager/window_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';

class HeroSidebar extends StatelessWidget {
  const HeroSidebar({
    super.key,
    required this.hero,
    required this.items,
    required this.currentIndex,
    required this.showLabel,
    required this.showAppIcon,
    required this.topInset,
    required this.onSelected,
    required this.onToggleLabel,
  });

  static const expandedWidth = 216.0;
  static const collapsedWidth = 72.0;
  static const itemExtent = 44.0;
  static const itemGap = 4.0;
  static const indicatorDuration = Duration(milliseconds: 320);
  static const indicatorCurve = Cubic(0.25, 1.1, 0.35, 1);

  final HeroTheme hero;
  final List<NavigationItem> items;
  final int currentIndex;
  final bool showLabel;
  final bool showAppIcon;
  final double topInset;
  final ValueChanged<int> onSelected;
  final VoidCallback onToggleLabel;

  @override
  Widget build(BuildContext context) {
    final width = showLabel ? expandedWidth : collapsedWidth;
    // Content is laid out at the target width and clipped while the width
    // animates, so rows never squeeze through the intermediate sizes.
    return AnimatedContainer(
      duration: commonDuration,
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        color: hero.background,
        border: Border(right: BorderSide(color: hero.divider)),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerStart,
          minWidth: width - 1,
          maxWidth: width - 1,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topInset + 12),
                if (showAppIcon) ...[
                  _HeroBrand(hero: hero, showLabel: showLabel),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const HiddenBarScrollBehavior(),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Stack(
                        children: [
                          if (items.isNotEmpty)
                            AnimatedPositioned(
                              duration: indicatorDuration,
                              curve: indicatorCurve,
                              top: currentIndex * (itemExtent + itemGap),
                              left: 0,
                              right: 0,
                              height: itemExtent,
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: context.colorScheme.primaryContainer,
                                  shape: AppShape.all(HeroCorner.medium),
                                ),
                              ),
                            ),
                          Column(
                            children: [
                              for (final (index, item) in items.indexed)
                                _HeroNavItem(
                                  hero: hero,
                                  icon: item.icon,
                                  label: item.label.label,
                                  selected: index == currentIndex,
                                  showLabel: showLabel,
                                  onTap: () => onSelected(index),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: showLabel
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: IconButton(
                      tooltip: context.appLocalizations.toggleLabel,
                      onPressed: onToggleLabel,
                      icon: Icon(
                        showLabel ? Icons.menu_open : Icons.menu,
                        color: hero.default500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBrand extends StatelessWidget {
  const _HeroBrand({required this.hero, required this.showLabel});

  final HeroTheme hero;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showLabel ? 16 : 0),
      child: Row(
        mainAxisAlignment: showLabel
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          const ClipRect(child: AppIcon()),
          if (showLabel) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  color: hero.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroNavItem extends StatelessWidget {
  const _HeroNavItem({
    required this.hero,
    required this.icon,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  static const _colorDuration = Duration(milliseconds: 200);

  final HeroTheme hero;
  final Widget icon;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final iconColor = selected ? colorScheme.primary : hero.default500;
    final tile = Material(
      type: MaterialType.transparency,
      shape: AppShape.all(HeroCorner.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: selected
            ? Colors.transparent
            : hero.default100.withValues(alpha: 0.8),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        child: SizedBox(
          height: HeroSidebar.itemExtent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: showLabel
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: iconColor),
                  duration: _colorDuration,
                  builder: (_, color, child) => IconTheme.merge(
                    data: IconThemeData(color: color, size: 22),
                    child: child!,
                  ),
                  child: icon,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: _colorDuration,
                      style: context.textTheme.labelLarge!.copyWith(
                        color: selected ? colorScheme.primary : hero.foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: HeroSidebar.itemGap),
      child: Semantics(
        selected: selected,
        button: true,
        child: showLabel ? tile : Tooltip(message: label, child: tile),
      ),
    );
  }
}
