import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

/// A Material 3 filled card; a [Material] so the list tiles inside keep their
/// ink.
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
    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      shape: AppShape.medium,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}
