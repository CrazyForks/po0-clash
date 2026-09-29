import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

import 'glass.dart';

/// A glass track with a lit pill that slides to the chosen segment.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
    this.height = 44,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final IconData Function(T value)? iconOf;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final glass = context.glass;
    final index = values.indexOf(selected);
    final count = values.length;
    final duration = context.motionDuration(Durations.medium2);
    const inset = 4.0;
    return SizedBox(
      height: height,
      child: GlassSurface(
        borderRadius: AppRadius.full,
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: Stack(
            children: [
              if (index >= 0)
                AnimatedAlign(
                  duration: duration,
                  curve: Easing.emphasizedDecelerate,
                  alignment: Alignment(
                    count == 1 ? 0 : -1 + 2 * index / (count - 1),
                    0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            Color.lerp(
                              colorScheme.primary,
                              colorScheme.tertiary,
                              0.45,
                            )!,
                          ],
                        ),
                        shape: AppShape.full,
                        shadows: [
                          BoxShadow(
                            color: glass.glow.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Material(
                type: MaterialType.transparency,
                child: Row(
                  children: [
                    for (final value in values)
                      Expanded(
                        child: _Segment(
                          label: labelOf(value),
                          icon: iconOf?.call(value),
                          selected: value == selected,
                          duration: duration,
                          onTap: () {
                            if (value != selected) {
                              onChanged(value);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final icon = this.icon;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: AppShape.full,
        overlayColor: WidgetStatePropertyAll(
          colorScheme.onSurface.withValues(alpha: selected ? 0 : 0.05),
        ),
        child: AnimatedDefaultTextStyle(
          duration: duration,
          curve: Easing.standard,
          style: context.textTheme.labelLarge!.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: color),
                  duration: duration,
                  builder: (_, color, _) => Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
