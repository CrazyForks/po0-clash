import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'fade_box.dart';
import 'text.dart';

class Info {
  final String label;
  final IconData? iconData;

  const Info({required this.label, this.iconData});
}

class InfoHeader extends StatelessWidget {
  final Info info;
  final List<Widget> actions;
  final EdgeInsets? padding;

  const InfoHeader({
    super.key,
    required this.info,
    this.padding,
    List<Widget>? actions,
  }) : actions = actions ?? const [];

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry nextPadding = (padding ?? baseInfoEdgeInsets);
    if (actions.isNotEmpty) {
      nextPadding = nextPadding.subtract(EdgeInsets.symmetric(vertical: 8.mAp));
    }
    return Padding(
      padding: nextPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (info.iconData != null) ...[
                  Icon(
                    info.iconData,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  flex: 1,
                  child: TooltipText(
                    text: Text(
                      info.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (actions.isNotEmpty)
            SizedBox(
              height: globalState.measure.titleSmallHeight + 16.ap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [...actions],
              ),
            ),
        ],
      ),
    );
  }
}

class CommonCard extends StatelessWidget {
  const CommonCard({
    super.key,
    bool? isSelected,
    this.type = CommonCardType.plain,
    this.onPressed,
    this.selectWidget,
    this.radius,
    this.padding,
    this.enterAnimated = false,
    this.info,
    this.onLongPress,
    this.shape,
    this.isError = false,
    this.enterActionsOnRight = false,
    this.skipTraversal = false,
    required this.child,
  }) : isSelected = isSelected ?? false;

  final bool enterAnimated;
  final bool enterActionsOnRight;
  final bool skipTraversal;
  final bool isSelected;
  final bool isError;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final Widget? selectWidget;
  final Widget child;
  final EdgeInsets? padding;
  final Info? info;
  final CommonCardType type;
  final double? radius;
  final OutlinedBorder? shape;

  BorderSide _buildBorderSide(BuildContext context, Set<WidgetState> states) {
    final colorScheme = context.colorScheme;
    if (isError) {
      if (type == CommonCardType.filled) {
        return BorderSide(color: colorScheme.error);
      }
      final hoverColor = isSelected
          ? colorScheme.error.opacity80
          : colorScheme.error.opacity38;
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused) ||
          states.contains(WidgetState.pressed)) {
        return BorderSide(color: hoverColor);
      }
      return BorderSide(
        color: isSelected
            ? colorScheme.error.opacity60
            : colorScheme.error.opacity30,
      );
    }
    if (type == CommonCardType.filled) {
      return BorderSide.none;
    }
    final hero = HeroTheme.maybeOf(context);
    final hoverColor = isSelected
        ? colorScheme.primary.opacity80
        : hero?.default300 ?? colorScheme.primary.opacity60;
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return BorderSide(color: hoverColor);
    }
    return BorderSide(
      color: isSelected
          ? colorScheme.primary
          : hero?.ring ?? colorScheme.surfaceContainerHighest,
    );
  }

  Color? _buildBackgroundColor(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (type == CommonCardType.filled) {
      if (isSelected) {
        return colorScheme.secondaryContainer.opacity80;
      }
      return colorScheme.surfaceContainerHigh;
    }
    if (isSelected) {
      return colorScheme.secondaryContainer;
    }
    return colorScheme.surfaceContainerLow;
  }

  Color? _buildForegroundColor(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (isError) {
      return colorScheme.error;
    }
    if (type == CommonCardType.filled) {
      if (isSelected) {
        return colorScheme.onSecondaryContainer;
      }
      return colorScheme.onSurfaceVariant;
    }
    if (isSelected) {
      return colorScheme.onSecondaryContainer;
    }
    return colorScheme.onSurfaceVariant;
  }

  Color? _buildIconColor(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (isError) {
      return colorScheme.error;
    }
    return colorScheme.primary;
  }

  Widget _buildButton(
    BuildContext context,
    Widget childWidget,
    FocusNode? focusNode,
  ) {
    final hero = HeroTheme.maybeOf(context);
    final defaultRadius = hero != null ? HeroCorner.large : AppCorner.md;
    return switch (type == CommonCardType.filled) {
      true => FilledButton(
        focusNode: focusNode,
        onLongPress: onLongPress,
        clipBehavior: Clip.antiAlias,
        style:
            FilledButton.styleFrom(
              padding: padding ?? EdgeInsets.zero,
              shape: shape ?? AppShape.all(radius ?? defaultRadius),
              iconSize: 20,
              iconColor: _buildIconColor(context),
              foregroundColor: _buildForegroundColor(context),
              side: BorderSide.none,
              elevation: 0,
            ).copyWith(
              backgroundColor: WidgetStatePropertyAll(
                _buildBackgroundColor(context),
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => _buildBorderSide(context, states),
              ),
            ),
        onPressed: onPressed,
        child: childWidget,
      ),
      false => OutlinedButton(
        focusNode: focusNode,
        onLongPress: onLongPress,
        clipBehavior: Clip.antiAlias,
        style:
            OutlinedButton.styleFrom(
              padding: padding ?? EdgeInsets.zero,
              shape: shape ?? AppShape.all(radius ?? defaultRadius),
              iconSize: 20,
              iconColor: _buildIconColor(context),
              backgroundColor: _buildBackgroundColor(context),
              foregroundColor: _buildForegroundColor(context),
              elevation: 0,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => _buildBorderSide(context, states),
              ),
            ),
        onPressed: onPressed,
        child: childWidget,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    var childWidget = child;

    if (info != null) {
      childWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoHeader(
            padding: baseInfoEdgeInsets.copyWith(bottom: 0),
            info: info!,
          ),
          Flexible(flex: 1, child: child),
        ],
      );
    }

    if (selectWidget != null && isSelected) {
      final List<Widget> children = [];
      children.add(childWidget);
      children.add(Positioned.fill(child: selectWidget!));
      childWidget = Stack(children: children);
    }

    final plainButton = skipTraversal
        ? _SkipTraversalScope(
            builder: (focusNode) =>
                _buildButton(context, childWidget, focusNode),
          )
        : _buildButton(context, childWidget, null);
    final hero = HeroTheme.maybeOf(context);
    final button = hero == null || type == CommonCardType.filled
        ? plainButton
        : _HeroCardFrame(
            hero: hero,
            shape: shape ?? AppShape.all(radius ?? HeroCorner.large),
            interactive: onPressed != null,
            child: plainButton,
          );
    final card = !enterActionsOnRight
        ? button
        : Focus(
            canRequestFocus: false,
            onKeyEvent: (_, event) {
              if (event is! KeyDownEvent ||
                  event.logicalKey != LogicalKeyboardKey.arrowRight) {
                return KeyEventResult.ignored;
              }
              final focusNode = FocusManager.instance.primaryFocus;
              final context = focusNode?.context;
              if (focusNode == null ||
                  context == null ||
                  context.findAncestorWidgetOfExactType<IconButton>() != null) {
                return KeyEventResult.ignored;
              }
              return focusNode.nextFocus()
                  ? KeyEventResult.handled
                  : KeyEventResult.ignored;
            },
            child: button,
          );

    return switch (enterAnimated) {
      true => FadeScaleEnterBox(child: card),
      false => card,
    };
  }
}

/// HeroUI's pressable card: a soft shadow at rest, lifted with a deeper
/// shadow on hover, and slightly scaled down while pressed.
class _HeroCardFrame extends StatefulWidget {
  const _HeroCardFrame({
    required this.hero,
    required this.shape,
    required this.interactive,
    required this.child,
  });

  final HeroTheme hero;
  final ShapeBorder shape;
  final bool interactive;
  final Widget child;

  @override
  State<_HeroCardFrame> createState() => _HeroCardFrameState();
}

class _HeroCardFrameState extends State<_HeroCardFrame> {
  static const _duration = Duration(milliseconds: 180);

  bool _hovered = false;
  bool _pressed = false;

  void _update({bool? hovered, bool? pressed}) {
    if (!widget.interactive) {
      return;
    }
    setState(() {
      _hovered = hovered ?? _hovered;
      _pressed = pressed ?? _pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lifted = widget.interactive && _hovered;
    return MouseRegion(
      onEnter: (_) => _update(hovered: true),
      onExit: (_) => _update(hovered: false, pressed: false),
      child: Listener(
        onPointerDown: (_) => _update(pressed: true),
        onPointerUp: (_) => _update(pressed: false),
        onPointerCancel: (_) => _update(pressed: false),
        child: AnimatedScale(
          scale: widget.interactive && _pressed ? 0.985 : 1,
          duration: _duration,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, lifted ? -2 : 0, 0),
            decoration: ShapeDecoration(
              shape: widget.shape,
              shadows: lifted
                  ? widget.hero.shadowMedium
                  : widget.hero.shadowSoft,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _SkipTraversalFocusNode extends FocusNode {
  @override
  bool get skipTraversal => true;
}

class _SkipTraversalScope extends StatefulWidget {
  const _SkipTraversalScope({required this.builder});

  final Widget Function(FocusNode focusNode) builder;

  @override
  State<_SkipTraversalScope> createState() => _SkipTraversalScopeState();
}

class _SkipTraversalScopeState extends State<_SkipTraversalScope> {
  final FocusNode _focusNode = _SkipTraversalFocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_focusNode);
  }
}

class SelectIcon extends StatelessWidget {
  const SelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inversePrimary,
      shape: AppShape.circle,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(Icons.check, size: 16),
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  final String title;
  final List<Widget> settings;

  const SettingsBlock({super.key, required this.title, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          InfoHeader(info: Info(label: title)),
          Card(
            color: context.colorScheme.surfaceContainer,
            child: Column(children: settings),
          ),
        ],
      ),
    );
  }
}
