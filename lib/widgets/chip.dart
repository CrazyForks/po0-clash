import 'package:material_ui/material_ui.dart';

/// An assist chip, or an input chip when it can be deleted.
class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;

  const CommonChip({
    super.key,
    required this.label,
    this.onPressed,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    final onDeleted = this.onDeleted;
    if (onDeleted != null) {
      return InputChip(
        label: text,
        onPressed: onPressed,
        onDeleted: onDeleted,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return ActionChip(
      label: text,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class MetaChip extends StatelessWidget {
  final String label;

  const MetaChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
