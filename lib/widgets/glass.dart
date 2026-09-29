import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

/// Where the four aurora blobs sit, in fractions of the backdrop's size.
@immutable
class AuroraScene {
  const AuroraScene(this.blobs);

  final List<({Offset center, double radius})> blobs;

  static const home = AuroraScene([
    (center: Offset(0.08, 0.06), radius: 0.62),
    (center: Offset(0.96, 0.22), radius: 0.5),
    (center: Offset(0.28, 1.0), radius: 0.58),
    (center: Offset(0.92, 0.96), radius: 0.36),
  ]);
  static const proxies = AuroraScene([
    (center: Offset(0.9, 0.02), radius: 0.6),
    (center: Offset(0.12, 0.36), radius: 0.46),
    (center: Offset(0.72, 0.9), radius: 0.56),
    (center: Offset(0.02, 0.98), radius: 0.34),
  ]);
  static const profiles = AuroraScene([
    (center: Offset(0.5, -0.08), radius: 0.56),
    (center: Offset(0.02, 0.7), radius: 0.52),
    (center: Offset(1.0, 0.62), radius: 0.5),
    (center: Offset(0.5, 1.06), radius: 0.3),
  ]);
  static const po0 = AuroraScene([
    (center: Offset(0.0, 0.3), radius: 0.6),
    (center: Offset(0.74, 0.08), radius: 0.44),
    (center: Offset(0.88, 0.78), radius: 0.58),
    (center: Offset(0.2, 0.98), radius: 0.3),
  ]);
  static const activity = AuroraScene([
    (center: Offset(0.64, 0.0), radius: 0.5),
    (center: Offset(0.98, 0.5), radius: 0.46),
    (center: Offset(0.06, 0.82), radius: 0.62),
    (center: Offset(0.46, 0.42), radius: 0.24),
  ]);
  static const settings = AuroraScene([
    (center: Offset(0.14, 0.9), radius: 0.62),
    (center: Offset(0.02, 0.06), radius: 0.4),
    (center: Offset(0.96, 0.1), radius: 0.54),
    (center: Offset(0.78, 1.0), radius: 0.32),
  ]);

  static AuroraScene lerp(AuroraScene a, AuroraScene b, double t) {
    return AuroraScene([
      for (var i = 0; i < a.blobs.length; i++)
        (
          center: Offset.lerp(a.blobs[i].center, b.blobs[i].center, t)!,
          radius: ui.lerpDouble(a.blobs[i].radius, b.blobs[i].radius, t)!,
        ),
    ]);
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.palette, required this.scene});

  final AuroraPalette palette;
  final AuroraScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.base,
        ).createShader(rect),
    );
    final extent = size.longestSide;
    for (var i = 0; i < scene.blobs.length; i++) {
      final blob = scene.blobs[i];
      final color = palette.blobs[i % palette.blobs.length];
      final center = Offset(
        blob.center.dx * size.width,
        blob.center.dy * size.height,
      );
      final radius = blob.radius * extent;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0.5), color.withAlpha(0)],
            stops: const [0, 0.42, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      palette != oldDelegate.palette || scene != oldDelegate.scene;
}

/// The ambient light every glass surface tints. Moving to another scene drifts
/// the blobs instead of cutting, and lands at once under reduced motion.
class AuroraBackdrop extends StatelessWidget {
  const AuroraBackdrop({super.key, this.scene = AuroraScene.home, this.child});

  static const drift = Duration(milliseconds: 900);

  final AuroraScene scene;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.glass.aurora;
    return TweenAnimationBuilder<AuroraScene>(
      tween: _AuroraSceneTween(end: scene),
      duration: context.motionDuration(drift),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (_, scene, child) => CustomPaint(
        painter: _AuroraPainter(palette: palette, scene: scene),
        isComplex: true,
        child: child,
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _AuroraSceneTween extends Tween<AuroraScene> {
  _AuroraSceneTween({super.end});

  @override
  AuroraScene lerp(double t) => AuroraScene.lerp(begin ?? end!, end!, t);
}

/// Carries the scene the app backdrop shows, so a full-screen route can lay
/// the same aurora under itself and slide in without a seam.
class AuroraSceneScope extends InheritedWidget {
  const AuroraSceneScope({
    super.key,
    required this.scene,
    required super.child,
  });

  final AuroraScene scene;

  static AuroraScene of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuroraSceneScope>()?.scene ??
      AuroraScene.home;

  @override
  bool updateShouldNotify(AuroraSceneScope oldWidget) =>
      scene != oldWidget.scene;
}

/// An opaque aurora for routes that cover the whole window.
class AuroraFloor extends StatelessWidget {
  const AuroraFloor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AuroraBackdrop(scene: AuroraSceneScope.of(context), child: child);
  }
}

enum GlassKind { panel, tile, chrome }

/// A frosted surface: a translucent veil with a sheen on top, a light rim that
/// fades toward the bottom edge, and a shadow drawn only outside the shape so
/// it never darkens the glass itself.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    this.kind = GlassKind.tile,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.selected = false,
    this.color,
    this.rimColor,
    this.elevated,
    this.blur,
    this.clip = true,
    this.circle = false,
    required this.child,
  });

  final GlassKind kind;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final Color? color;
  final Color? rimColor;
  final bool? elevated;
  final bool? blur;
  final bool clip;
  final bool circle;
  final Widget child;

  static OutlinedBorder shapeOf({
    required GlassKind kind,
    BorderRadius? borderRadius,
    bool circle = false,
  }) => circle
      ? const CircleBorder()
      : RoundedSuperellipseBorder(borderRadius: borderRadius ?? radiusOf(kind));

  static BorderRadius radiusOf(GlassKind kind) => switch (kind) {
    GlassKind.panel => AppRadius.extraLarge,
    GlassKind.tile => AppRadius.medium,
    GlassKind.chrome => AppRadius.extraLarge,
  };

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final shape = shapeOf(
      kind: kind,
      borderRadius: borderRadius,
      circle: circle,
    );
    final fill =
        color ??
        (selected
            ? Color.alphaBlend(glass.selected, glass.tile)
            : switch (kind) {
                GlassKind.panel => glass.panel,
                GlassKind.tile => glass.tile,
                GlassKind.chrome => glass.chrome,
              });
    final shouldBlur = blur ?? kind == GlassKind.chrome;
    Widget content = CustomPaint(
      painter: _GlassFillPainter(shape: shape, fill: fill, sheen: glass.sheen),
      foregroundPainter: _GlassRimPainter(
        shape: shape,
        light: rimColor ?? (selected ? glass.selectedRim : glass.rimLight),
        shade: rimColor ?? (selected ? glass.selectedRim : glass.rimShade),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (shouldBlur) {
      content = BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: glass.blurSigma,
          sigmaY: glass.blurSigma,
          tileMode: TileMode.mirror,
        ),
        child: content,
      );
    }
    if (clip || shouldBlur) {
      content = ClipPath.shape(shape: shape, child: content);
    }
    if (!(elevated ?? kind != GlassKind.tile)) {
      return content;
    }
    return CustomPaint(
      painter: _GlassShadowPainter(shape: shape, color: glass.shadow),
      child: content,
    );
  }
}

class _GlassFillPainter extends CustomPainter {
  const _GlassFillPainter({
    required this.shape,
    required this.fill,
    required this.sheen,
  });

  final ShapeBorder shape;
  final Color fill;
  final Color sheen;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sheen, sheen.withAlpha(0)],
          stops: const [0, 0.55],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassFillPainter oldDelegate) =>
      shape != oldDelegate.shape ||
      fill != oldDelegate.fill ||
      sheen != oldDelegate.sheen;
}

class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({
    required this.shape,
    required this.light,
    required this.shade,
  });

  final ShapeBorder shape;
  final Color light;
  final Color shade;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    canvas.drawPath(
      shape.getOuterPath(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            light,
            shade,
            shade,
            light.withValues(alpha: light.a * 0.5),
          ],
          stops: const [0, 0.4, 0.8, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      shape != oldDelegate.shape ||
      light != oldDelegate.light ||
      shade != oldDelegate.shade;
}

class _GlassShadowPainter extends CustomPainter {
  const _GlassShadowPainter({required this.shape, required this.color});

  static const _blur = 24.0;
  static const _offset = Offset(0, 10);

  final ShapeBorder shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);
    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(_blur * 3))
        ..addPath(path, Offset.zero),
    );
    canvas.drawPath(
      path.shift(_offset),
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _blur / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassShadowPainter oldDelegate) =>
      shape != oldDelegate.shape || color != oldDelegate.color;
}

/// A tappable [GlassSurface] whose hover, press and focus states light the
/// glass from inside rather than laying a grey overlay on it.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.kind = GlassKind.tile,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.selected = false,
    this.color,
    this.rimColor,
    this.elevated,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.circle = false,
    required this.child,
  });

  final bool circle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSecondaryTap;
  final GlassKind kind;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final bool selected;
  final Color? color;
  final Color? rimColor;
  final bool? elevated;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    final colorScheme = context.colorScheme;
    final button = GlassSurface(
      kind: kind,
      borderRadius: borderRadius,
      circle: circle,
      selected: selected,
      color: color,
      rimColor: rimColor,
      elevated: elevated,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onSecondaryTap: onSecondaryTap,
          focusNode: focusNode,
          autofocus: autofocus,
          customBorder: GlassSurface.shapeOf(
            kind: kind,
            borderRadius: borderRadius,
            circle: circle,
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onSurface.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return colorScheme.primary.withValues(alpha: 0.14);
            }
            if (states.contains(WidgetState.hovered)) {
              return glass.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.35);
            }
            return null;
          }),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    final tooltip = this.tooltip;
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// A tinted squircle holding an icon, the way glass tiles mark their kind.
class GlassIconBadge extends StatelessWidget {
  const GlassIconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
    this.iconSize,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colorScheme.primary;
    final glass = context.glass;
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: glass.isDark ? 0.34 : 0.22),
            accent.withValues(alpha: glass.isDark ? 0.16 : 0.1),
          ],
        ),
        shape: RoundedSuperellipseBorder(
          borderRadius: AppRadius.all(size * 0.32),
          side: BorderSide(color: accent.withValues(alpha: 0.28)),
        ),
      ),
      child: Icon(icon, size: iconSize ?? size * 0.52, color: accent),
    );
  }
}

/// The small caps label above a group of glass tiles.
class GlassSectionLabel extends StatelessWidget {
  const GlassSectionLabel(
    this.label, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(6, 20, 6, 10),
  });

  final String label;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A tinted capsule for short states: delays, results, counts.
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.monospace = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colorScheme.primary;
    final icon = this.icon;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: accent.withValues(alpha: context.glass.isDark ? 0.2 : 0.13),
        shape: AppShape.full.copyWith(
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              maxLines: 1,
              style: context.textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
                fontFamily: monospace ? FontFamily.jetBrainsMono.value : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
