import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';

/// The ambient light behind every glass surface: a two stop base gradient and
/// four soft blobs, all derived from the seed hue so any theme color works.
@immutable
class AuroraPalette {
  const AuroraPalette({required this.base, required this.blobs});

  final List<Color> base;
  final List<Color> blobs;

  static AuroraPalette lerp(AuroraPalette a, AuroraPalette b, double t) {
    return AuroraPalette(
      base: [
        for (var i = 0; i < a.base.length; i++)
          Color.lerp(a.base[i], b.base[i], t)!,
      ],
      blobs: [
        for (var i = 0; i < a.blobs.length; i++)
          Color.lerp(a.blobs[i], b.blobs[i], t)!,
      ],
    );
  }
}

/// Fills, rims and shadows of the frosted glass language. Structural panels
/// sit on the static aurora and only tint it; floating chrome (the dock,
/// dialogs, sheets) blurs whatever scrolls beneath it with [blurSigma].
@immutable
class GlassStyle extends ThemeExtension<GlassStyle> {
  const GlassStyle({
    required this.brightness,
    required this.panel,
    required this.tile,
    required this.tileHover,
    required this.chrome,
    required this.menu,
    required this.rimLight,
    required this.rimShade,
    required this.sheen,
    required this.divider,
    required this.shadow,
    required this.selected,
    required this.selectedRim,
    required this.glow,
    required this.aurora,
    required this.blurSigma,
  });

  final Brightness brightness;
  final Color panel;
  final Color tile;
  final Color tileHover;
  final Color chrome;
  final Color menu;
  final Color rimLight;
  final Color rimShade;
  final Color sheen;
  final Color divider;
  final Color shadow;
  final Color selected;
  final Color selectedRim;
  final Color glow;
  final AuroraPalette aurora;
  final double blurSigma;

  bool get isDark => brightness == Brightness.dark;

  factory GlassStyle.of(ColorScheme scheme, {bool pureBlack = false}) {
    final dark = scheme.brightness == Brightness.dark;
    final hue = Hct.fromInt(scheme.primary.toARGB32()).hue;
    Color tone(double shift, double chroma, double tone) =>
        Color(Hct.from((hue + shift) % 360, chroma, tone).toInt());
    final aurora = dark
        ? AuroraPalette(
            base: pureBlack
                ? const [Colors.black, Colors.black]
                : [tone(0, 18, 7), tone(30, 22, 11)],
            blobs: [
              tone(0, 72, pureBlack ? 30 : 40),
              tone(48, 64, pureBlack ? 26 : 36),
              tone(-56, 60, pureBlack ? 24 : 34),
              tone(150, 40, pureBlack ? 20 : 28),
            ],
          )
        : AuroraPalette(
            base: [tone(0, 10, 97), tone(30, 14, 93)],
            blobs: [
              tone(0, 56, 80),
              tone(48, 50, 86),
              tone(-56, 48, 84),
              tone(150, 30, 90),
            ],
          );
    if (dark) {
      return GlassStyle(
        brightness: scheme.brightness,
        panel: Colors.white.withValues(alpha: 0.055),
        tile: Colors.white.withValues(alpha: 0.07),
        tileHover: Colors.white.withValues(alpha: 0.11),
        chrome: tone(0, 16, 10).withValues(alpha: 0.62),
        menu: tone(0, 14, 14).withValues(alpha: 0.94),
        rimLight: Colors.white.withValues(alpha: 0.2),
        rimShade: Colors.white.withValues(alpha: 0.04),
        sheen: Colors.white.withValues(alpha: 0.05),
        divider: Colors.white.withValues(alpha: 0.08),
        shadow: Colors.black.withValues(alpha: 0.42),
        selected: scheme.primary.withValues(alpha: 0.2),
        selectedRim: scheme.primary.withValues(alpha: 0.62),
        glow: scheme.primary.withValues(alpha: 0.55),
        aurora: aurora,
        blurSigma: 28,
      );
    }
    return GlassStyle(
      brightness: scheme.brightness,
      panel: Colors.white.withValues(alpha: 0.4),
      tile: Colors.white.withValues(alpha: 0.52),
      tileHover: Colors.white.withValues(alpha: 0.7),
      chrome: Colors.white.withValues(alpha: 0.6),
      menu: tone(0, 6, 98).withValues(alpha: 0.95),
      rimLight: Colors.white.withValues(alpha: 0.9),
      rimShade: Colors.white.withValues(alpha: 0.3),
      sheen: Colors.white.withValues(alpha: 0.35),
      divider: tone(0, 20, 20).withValues(alpha: 0.07),
      shadow: tone(0, 40, 20).withValues(alpha: 0.12),
      selected: scheme.primary.withValues(alpha: 0.14),
      selectedRim: scheme.primary.withValues(alpha: 0.5),
      glow: scheme.primary.withValues(alpha: 0.4),
      aurora: aurora,
      blurSigma: 28,
    );
  }

  @override
  GlassStyle copyWith({AuroraPalette? aurora, double? blurSigma}) {
    return GlassStyle(
      brightness: brightness,
      panel: panel,
      tile: tile,
      tileHover: tileHover,
      chrome: chrome,
      menu: menu,
      rimLight: rimLight,
      rimShade: rimShade,
      sheen: sheen,
      divider: divider,
      shadow: shadow,
      selected: selected,
      selectedRim: selectedRim,
      glow: glow,
      aurora: aurora ?? this.aurora,
      blurSigma: blurSigma ?? this.blurSigma,
    );
  }

  @override
  GlassStyle lerp(covariant GlassStyle? other, double t) {
    if (other == null) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GlassStyle(
      brightness: t < 0.5 ? brightness : other.brightness,
      panel: mix(panel, other.panel),
      tile: mix(tile, other.tile),
      tileHover: mix(tileHover, other.tileHover),
      chrome: mix(chrome, other.chrome),
      menu: mix(menu, other.menu),
      rimLight: mix(rimLight, other.rimLight),
      rimShade: mix(rimShade, other.rimShade),
      sheen: mix(sheen, other.sheen),
      divider: mix(divider, other.divider),
      shadow: mix(shadow, other.shadow),
      selected: mix(selected, other.selected),
      selectedRim: mix(selectedRim, other.selectedRim),
      glow: mix(glow, other.glow),
      aurora: AuroraPalette.lerp(aurora, other.aurora, t),
      blurSigma: blurSigma + (other.blurSigma - blurSigma) * t,
    );
  }
}

extension GlassContextExt on BuildContext {
  GlassStyle get glass =>
      Theme.of(this).extension<GlassStyle>() ??
      GlassStyle.of(Theme.of(this).colorScheme);
}

enum GlassTone { accent, success, warning, danger, neutral }

extension GlassToneExt on BuildContext {
  Color toneColor(GlassTone tone) {
    final colorScheme = Theme.of(this).colorScheme;
    final dark = colorScheme.brightness == Brightness.dark;
    return switch (tone) {
      GlassTone.accent => colorScheme.primary,
      GlassTone.success =>
        dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      GlassTone.warning =>
        dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      GlassTone.danger => colorScheme.error,
      GlassTone.neutral => colorScheme.onSurfaceVariant,
    };
  }
}
