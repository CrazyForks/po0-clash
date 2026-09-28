import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';

import 'color.dart';
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
