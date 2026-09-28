import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// A grouping surface; a [Material] so the list tiles inside keep their ink.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hero = HeroTheme.maybeOf(context);
    final shape = hero != null
        ? AppShape.all(
            HeroCorner.large,
          ).copyWith(side: BorderSide(color: hero.ring))
        : AppShape.xl;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        shadows: hero?.shadowSoft ?? const [],
      ),
      child: Material(
        color: hero?.content1 ?? context.colorScheme.surfaceContainerLow,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
