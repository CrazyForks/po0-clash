import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one control that starts and stops the proxy: a glass disc inside a
/// ring that fills while running, with the run time at its heart.
class ConnectOrb extends ConsumerStatefulWidget {
  const ConnectOrb({super.key, this.size = 188});

  final double size;

  @override
  ConsumerState<ConnectOrb> createState() => _ConnectOrbState();
}

class _ConnectOrbState extends ConsumerState<ConnectOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Durations.long2,
    value: ref.read(isStartProvider) ? 1 : 0,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Easing.emphasizedDecelerate,
    reverseCurve: Easing.emphasizedAccelerate.flipped,
  );

  @override
  void initState() {
    super.initState();
    ref.listenManual(isStartProvider, (_, next) {
      if (context.disableAnimations) {
        _controller.value = next ? 1 : 0;
      } else if (next) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(bool hasProfile) {
    if (!hasProfile) {
      ref.read(currentPageLabelProvider.notifier).toPage(PageLabel.profiles);
      return;
    }
    ref.read(commonActionProvider.notifier).toggleRunning();
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final isStart = ref.watch(isStartProvider);
    final suspend = ref.watch(suspendProvider);
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final glass = context.glass;
    final size = widget.size;
    final disc = size * 0.68;
    final label = !hasProfile
        ? appLocalizations.addProfile
        : suspend
        ? appLocalizations.suspended
        : isStart
        ? appLocalizations.proxyOn
        : appLocalizations.tapToConnect;
    return Semantics(
      button: true,
      toggled: isStart,
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (_, child) => CustomPaint(
            painter: _OrbRingPainter(
              progress: _progress.value,
              track: colorScheme.onSurface.withValues(
                alpha: glass.isDark ? 0.1 : 0.07,
              ),
              glow: glass.glow,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
                colorScheme.primary,
              ],
            ),
            child: child,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: disc,
              child: GlassButton(
                circle: true,
                elevated: true,
                selected: isStart,
                onTap: () => _handleTap(hasProfile),
                child: _OrbFace(
                  size: disc,
                  label: label,
                  active: isStart && !suspend,
                  hasProfile: hasProfile,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbFace extends ConsumerWidget {
  const _OrbFace({
    required this.size,
    required this.label,
    required this.active,
    required this.hasProfile,
  });

  final double size;
  final String label;
  final bool active;
  final bool hasProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final color = active ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final duration = context.motionDuration(Durations.medium2);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: duration,
          builder: (_, color, _) => Icon(
            hasProfile ? Icons.power_settings_new_rounded : Icons.add_rounded,
            size: size * 0.3,
            color: color,
          ),
        ),
        SizedBox(height: size * 0.04),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.12),
          child: FadeBox(
            child: Text(
              label,
              key: ValueKey(label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Consumer(
          builder: (_, ref, _) {
            final runTime = ref.watch(runTimeProvider);
            return AnimatedOpacity(
              opacity: runTime == null ? 0 : 1,
              duration: duration,
              child: Text(
                getTimeText(runTime),
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OrbRingPainter extends CustomPainter {
  const _OrbRingPainter({
    required this.progress,
    required this.track,
    required this.glow,
    required this.colors,
  });

  final double progress;
  final Color track;
  final Color glow;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final extent = size.shortestSide;
    final stroke = extent * 0.035;
    final radius = extent * 0.41;
    if (progress > 0) {
      canvas.drawCircle(
        center,
        extent / 2,
        Paint()
          ..shader = RadialGradient(
            colors: [
              glow.withValues(alpha: glow.a * progress),
              glow.withValues(alpha: glow.a * 0.35 * progress),
              glow.withAlpha(0),
            ],
            stops: const [0.5, 0.74, 1],
          ).createShader(Rect.fromCircle(center: center, radius: extent / 2)),
      );
    }
    final ring = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (progress <= 0) {
      return;
    }
    canvas.drawArc(
      ring,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: colors,
          transform: const GradientRotation(-pi / 2),
        ).createShader(ring),
    );
  }

  @override
  bool shouldRepaint(_OrbRingPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      track != oldDelegate.track ||
      glow != oldDelegate.glow ||
      colors != oldDelegate.colors;
}
