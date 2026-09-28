import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

ThemeData _build({
  Brightness brightness = Brightness.light,
  ThemeProps themeProps = const ThemeProps(),
}) {
  return buildAppTheme(
    brightness: brightness,
    materialScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(),
    themeProps: themeProps,
  );
}

void main() {
  group('buildAppTheme', () {
    test('uses the seeded Material 3 scheme', () {
      final theme = _build();
      expect(theme.useMaterial3, isTrue);
      expect(
        theme.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: Colors.teal).primary,
      );
    });

    test('pure black only reaches the dark theme', () {
      final dark = _build(
        brightness: Brightness.dark,
        themeProps: const ThemeProps(pureBlack: true),
      );
      expect(dark.colorScheme.surface, Colors.black);
      final light = _build(themeProps: const ThemeProps(pureBlack: true));
      expect(light.colorScheme.surface, isNot(Colors.black));
    });

    test('text fields are outlined with the extra-small corner', () {
      final border = _build().inputDecorationTheme.border;
      expect(border, isA<OutlineInputBorder>());
      expect(
        (border! as OutlineInputBorder).borderRadius,
        AppRadius.extraSmall,
      );
    });

    test('components keep the Material 3 default corners', () {
      final theme = _build();
      expect(theme.cardTheme.shape, isNull);
      expect(theme.dialogTheme.shape, isNull);
      expect(theme.menuTheme.style, isNull);
    });
  });
}
