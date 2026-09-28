import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _transitions = PageTransitionsTheme();

ThemeData _build({
  required bool heroStyle,
  Brightness brightness = Brightness.light,
  ThemeProps themeProps = const ThemeProps(),
}) {
  return buildAppTheme(
    brightness: brightness,
    materialScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    ),
    pageTransitionsTheme: _transitions,
    themeProps: themeProps,
    heroStyle: heroStyle,
  );
}

double _radius(ShapeBorder? shape) {
  final border = shape! as OutlinedBorder;
  final radius = switch (border) {
    RoundedSuperellipseBorder(:final borderRadius) => borderRadius,
    RoundedRectangleBorder(:final borderRadius) => borderRadius,
    _ => BorderRadius.zero,
  };
  return (radius as BorderRadius).topLeft.x;
}

void main() {
  group('heroColorScheme', () {
    test('uses the HeroUI surfaces and the HeroUI blue by default', () {
      final light = heroColorScheme(Brightness.light);
      expect(light.primary, heroPrimary);
      expect(light.surface, HeroTheme.light.background);
      expect(light.onSurface, HeroTheme.light.foreground);
      expect(light.onSurfaceVariant, HeroTheme.light.default500);
      expect(light.error, HeroTheme.light.danger);
      expect(light.surfaceContainerLow, HeroTheme.light.content1);

      final dark = heroColorScheme(Brightness.dark);
      expect(dark.surface, const Color(0xFF000000));
      expect(dark.surfaceContainerLow, HeroTheme.dark.content1);
      expect(dark.brightness, Brightness.dark);
    });

    test('flat containers tint the surface with the accent', () {
      final scheme = heroColorScheme(
        Brightness.light,
        primary: const Color(0xFF17C964),
      );
      expect(scheme.primary, const Color(0xFF17C964));
      expect(scheme.secondaryContainer, scheme.primaryContainer);
      expect(scheme.primaryContainer, isNot(HeroTheme.light.content1));
      expect(scheme.primaryContainer.g, greaterThan(scheme.primaryContainer.r));
    });
  });

  group('buildAppTheme', () {
    test('keeps the Material theme when the HeroUI style is off', () {
      final theme = _build(heroStyle: false);
      expect(theme.extension<HeroTheme>(), isNull);
      expect(theme.colorScheme.primary, isNot(heroPrimary));
    });

    test('pure black only reaches the Material dark theme', () {
      final theme = _build(
        heroStyle: false,
        brightness: Brightness.dark,
        themeProps: const ThemeProps(pureBlack: true),
      );
      expect(theme.colorScheme.surface, Colors.black);
    });

    test('attaches the HeroUI tokens and maps the stock accent to blue', () {
      final theme = _build(
        heroStyle: true,
        themeProps: const ThemeProps(primaryColor: defaultPrimaryColor),
      );
      expect(theme.extension<HeroTheme>(), HeroTheme.light);
      expect(theme.colorScheme.primary, heroPrimary);
      expect(theme.scaffoldBackgroundColor, HeroTheme.light.background);
    });

    test('keeps an accent the user picked', () {
      final theme = _build(
        heroStyle: true,
        brightness: Brightness.dark,
        themeProps: const ThemeProps(primaryColor: 0xFFF5A524),
      );
      expect(theme.colorScheme.primary, const Color(0xFFF5A524));
      expect(theme.extension<HeroTheme>(), HeroTheme.dark);
    });

    test('rounds components to the HeroUI radii', () {
      final theme = _build(heroStyle: true);
      expect(_radius(theme.cardTheme.shape), HeroCorner.large);
      expect(_radius(theme.dialogTheme.shape), HeroCorner.large);
      expect(
        _radius(theme.filledButtonTheme.style!.shape!.resolve({})),
        HeroCorner.medium,
      );
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.appBarTheme.titleTextStyle?.fontSize, 20);
      expect(theme.tooltipTheme.textStyle?.fontSize, 12);
      expect(theme.tabBarTheme.dividerColor, Colors.transparent);
      expect(
        theme.switchTheme.trackColor!.resolve({WidgetState.selected}),
        heroPrimary,
      );
      expect(
        theme.switchTheme.trackColor!.resolve({}),
        HeroTheme.light.default200,
      );
    });
  });

  group('HeroTheme', () {
    test('lerps between the light and dark tokens', () {
      expect(HeroTheme.light.lerp(HeroTheme.dark, 0), HeroTheme.light);
      expect(HeroTheme.light.lerp(null, 0.5), HeroTheme.light);
      final middle = HeroTheme.light.lerp(HeroTheme.dark, 0.5);
      expect(
        middle.background,
        Color.lerp(HeroTheme.light.background, HeroTheme.dark.background, 0.5),
      );
    });

    test('copyWith replaces only the given tokens', () {
      final copy = HeroTheme.light.copyWith(danger: Colors.red);
      expect(copy.danger, Colors.red);
      expect(copy.content1, HeroTheme.light.content1);
      expect(HeroTheme.of(Brightness.dark), HeroTheme.dark);
      expect(HeroTheme.light.shadowSmall, hasLength(3));
      expect(HeroTheme.light.shadowMedium, hasLength(2));
      expect(copy.scrim, HeroTheme.light.scrim);
      expect(
        HeroTheme.dark.scrim.a,
        greaterThan(HeroTheme.light.scrim.a),
        reason: 'a black page needs a denser scrim to read as dimmed',
      );
    });
  });
}
