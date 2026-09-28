import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

class CommonPopupMenuItem {
  const CommonPopupMenuItem({
    required this.label,
    this.icon,
    this.onPressed,
    this.danger = false,
    this.subItems = const [],
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool danger;
  final List<CommonPopupMenuItem> subItems;
}

class CommonPopupBox extends StatelessWidget {
  const CommonPopupBox({
    super.key,
    required this.targetBuilder,
    required this.items,
  });

  final Widget Function(VoidCallback open) targetBuilder;
  final List<CommonPopupMenuItem> items;

  Widget _buildItem(BuildContext context, CommonPopupMenuItem item) {
    final colorScheme = context.colorScheme;
    final style = item.danger
        ? MenuItemButton.styleFrom(
            foregroundColor: colorScheme.error,
            iconColor: colorScheme.error,
          )
        : null;
    final icon = item.icon == null ? null : Icon(item.icon);
    if (item.subItems.isNotEmpty) {
      return SubmenuButton(
        leadingIcon: icon,
        style: style,
        menuChildren: [
          for (final subItem in item.subItems) _buildItem(context, subItem),
        ],
        child: Text(item.label),
      );
    }
    return MenuItemButton(
      leadingIcon: icon,
      style: style,
      onPressed: item.onPressed,
      child: Text(item.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [for (final item in items) _buildItem(context, item)],
      builder: (_, controller, _) => targetBuilder(() {
        if (controller.isOpen) {
          controller.close();
        } else {
          controller.open();
        }
      }),
    );
  }
}
