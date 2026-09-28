import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';

import 'color.dart';
import 'constant.dart';
import 'shape.dart';

ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme materialScheme,
  required PageTransitionsTheme pageTransitionsTheme,
  required ThemeProps themeProps,
}) {
  final colorScheme = brightness == Brightness.dark
      ? materialScheme.toPureBlack(themeProps.pureBlack)
      : materialScheme;
  final scrim = colorScheme.modalScrim;
  return ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: pageTransitionsTheme,
    colorScheme: colorScheme,
    bottomSheetTheme: BottomSheetThemeData(modalBarrierColor: scrim),
    dialogTheme: DialogThemeData(barrierColor: scrim),
  ).withAppShapes;
}

extension ModalScrimExt on ColorScheme {
  Color get modalScrim => scrim.withValues(alpha: 0.32);
}

const _androidGreen = Color(0xFF3DDC84);

/// The default look follows the Android design site: navy for actions, Android
/// green for selection.
ColorScheme androidBrandScheme(
  Brightness brightness,
  DynamicSchemeVariant variant,
) {
  final navy = ColorScheme.fromSeed(
    seedColor: const Color(defaultPrimaryColor),
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );
  final green = ColorScheme.fromSeed(
    seedColor: _androidGreen,
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );
  return navy.copyWith(
    primaryContainer: green.primaryContainer,
    onPrimaryContainer: green.onPrimaryContainer,
    secondary: green.primary,
    onSecondary: green.onPrimary,
    secondaryContainer: green.primaryContainer,
    onSecondaryContainer: green.onPrimaryContainer,
  );
}

ColorScheme seededColorScheme(
  Color seed,
  Brightness brightness,
  DynamicSchemeVariant variant,
) {
  if (seed.toARGB32() == defaultPrimaryColor) {
    return androidBrandScheme(brightness, variant);
  }
  return ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );
}
