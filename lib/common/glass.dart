import 'package:material_ui/material_ui.dart';

/// The Liquid Glass palette. Content sits on neutral, opaque grouped cells;
/// only floating controls (sidebar, dock, segmented tracks, toolbars and
/// dialogs) are glass, which blurs and saturates what lies beneath it and
/// carries a specular rim.
@immutable
class GlassStyle extends ThemeExtension<GlassStyle> {
  const GlassStyle({
    required this.brightness,
    required this.background,
    required this.card,
    required this.fill,
    required this.thumb,
    required this.glass,
    required this.glassStrong,
    required this.rimLight,
    required this.rimShade,
    required this.separator,
    required this.shadow,
    required this.selected,
    required this.secondaryLabel,
    required this.blurSigma,
  });

  final Brightness brightness;
  final Color background;
  final Color card;
  final Color fill;
  final Color thumb;
  final Color glass;
  final Color glassStrong;
  final Color rimLight;
  final Color rimShade;
  final Color separator;
  final Color shadow;
  final Color selected;
  final Color secondaryLabel;
  final double blurSigma;

  bool get isDark => brightness == Brightness.dark;

  static const saturation = 1.8;

  /// Dark mode follows macOS unless [pureBlack] asks for iOS's OLED black.
  factory GlassStyle.of(ColorScheme scheme, {bool pureBlack = false}) {
    if (scheme.brightness == Brightness.dark) {
      return GlassStyle(
        brightness: Brightness.dark,
        background: pureBlack ? Colors.black : const Color(0xFF1C1C1E),
        card: pureBlack ? const Color(0xFF1C1C1E) : const Color(0xFF2C2C2E),
        fill: const Color(0x3D767680),
        thumb: const Color(0xFF636366),
        glass: pureBlack ? const Color(0x8C1E1E20) : const Color(0x99343437),
        glassStrong: pureBlack
            ? const Color(0xE62C2C2E)
            : const Color(0xEB38383B),
        rimLight: Colors.white.withValues(alpha: 0.26),
        rimShade: Colors.white.withValues(alpha: 0.06),
        separator: const Color(0x99545458),
        shadow: Colors.black.withValues(alpha: 0.5),
        selected: Colors.white.withValues(alpha: 0.1),
        secondaryLabel: const Color(0x99EBEBF5),
        blurSigma: 24,
      );
    }
    return GlassStyle(
      brightness: Brightness.light,
      background: const Color(0xFFF2F2F7),
      card: Colors.white,
      fill: const Color(0x1F767680),
      thumb: Colors.white,
      glass: Colors.white.withValues(alpha: 0.62),
      glassStrong: const Color(0xEBF9F9FB),
      rimLight: Colors.white.withValues(alpha: 0.95),
      rimShade: Colors.white.withValues(alpha: 0.4),
      separator: const Color(0x2E3C3C43),
      shadow: Colors.black.withValues(alpha: 0.1),
      selected: Colors.black.withValues(alpha: 0.06),
      secondaryLabel: const Color(0x993C3C43),
      blurSigma: 24,
    );
  }

  @override
  GlassStyle copyWith({double? blurSigma}) {
    return GlassStyle(
      brightness: brightness,
      background: background,
      card: card,
      fill: fill,
      thumb: thumb,
      glass: glass,
      glassStrong: glassStrong,
      rimLight: rimLight,
      rimShade: rimShade,
      separator: separator,
      shadow: shadow,
      selected: selected,
      secondaryLabel: secondaryLabel,
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
      background: mix(background, other.background),
      card: mix(card, other.card),
      fill: mix(fill, other.fill),
      thumb: mix(thumb, other.thumb),
      glass: mix(glass, other.glass),
      glassStrong: mix(glassStrong, other.glassStrong),
      rimLight: mix(rimLight, other.rimLight),
      rimShade: mix(rimShade, other.rimShade),
      separator: mix(separator, other.separator),
      shadow: mix(shadow, other.shadow),
      selected: mix(selected, other.selected),
      secondaryLabel: mix(secondaryLabel, other.secondaryLabel),
      blurSigma: blurSigma + (other.blurSigma - blurSigma) * t,
    );
  }
}

extension GlassContextExt on BuildContext {
  GlassStyle get glass =>
      Theme.of(this).extension<GlassStyle>() ??
      GlassStyle.of(Theme.of(this).colorScheme);
}

/// Apple's system colors, for states and the settings icons.
enum GlassTone {
  accent,
  success,
  warning,
  danger,
  neutral,
  indigo,
  teal,
  pink;

  (Color, Color) get lightAndDark => switch (this) {
    GlassTone.accent => (const Color(0xFF007AFF), const Color(0xFF0A84FF)),
    GlassTone.success => (const Color(0xFF34C759), const Color(0xFF30D158)),
    GlassTone.warning => (const Color(0xFFFF9500), const Color(0xFFFF9F0A)),
    GlassTone.danger => (const Color(0xFFFF3B30), const Color(0xFFFF453A)),
    GlassTone.neutral => (const Color(0xFF8E8E93), const Color(0xFF8E8E93)),
    GlassTone.indigo => (const Color(0xFF5856D6), const Color(0xFF5E5CE6)),
    GlassTone.teal => (const Color(0xFF30B0C7), const Color(0xFF40C8E0)),
    GlassTone.pink => (const Color(0xFFFF2D55), const Color(0xFFFF375F)),
  };

  Color on(Brightness brightness) {
    final (light, dark) = lightAndDark;
    return brightness == Brightness.dark ? dark : light;
  }
}

extension GlassToneExt on BuildContext {
  Color toneColor(GlassTone tone) {
    final colorScheme = Theme.of(this).colorScheme;
    if (tone == GlassTone.accent) {
      return colorScheme.primary;
    }
    return tone.on(colorScheme.brightness);
  }
}
