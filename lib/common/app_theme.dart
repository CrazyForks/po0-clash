import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';

import 'glass.dart';
import 'shape.dart';

ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme materialScheme,
  required PageTransitionsTheme pageTransitionsTheme,
  required ThemeProps themeProps,
}) {
  final pureBlack = brightness == Brightness.dark && themeProps.pureBlack;
  final glass = GlassStyle.of(materialScheme, pureBlack: pureBlack);
  final colorScheme = materialScheme.toGlass(glass);
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    pageTransitionsTheme: pageTransitionsTheme,
    extensions: [glass],
  );
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    dividerColor: glass.divider,
    textTheme: _glassTextTheme(base.textTheme),
    appBarTheme: _appBarTheme(base, colorScheme),
    cardTheme: CardThemeData(
      color: glass.tile,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: AppShape.medium.copyWith(side: BorderSide(color: glass.rimShade)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: glass.menu,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: AppShape.extraLarge.copyWith(
        side: BorderSide(color: glass.rimLight.withValues(alpha: 0.5)),
      ),
      barrierColor: colorScheme.modalScrim,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: glass.menu,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      modalBarrierColor: colorScheme.modalScrim,
      shape: AppShape.top(AppCorner.extraLarge),
    ),
    dividerTheme: DividerThemeData(color: glass.divider, thickness: 1),
    inputDecorationTheme: _inputTheme(glass, colorScheme),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(AppShape.full),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(AppShape.full),
        backgroundColor: WidgetStatePropertyAll(glass.tile),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled)
                ? glass.divider
                : glass.rimLight,
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ),
    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(shape: WidgetStatePropertyAll(AppShape.full)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(AppShape.full),
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(glass.tile),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: AppShape.full,
    ),
    segmentedButtonTheme: _segmentedTheme(glass, colorScheme),
    switchTheme: _switchTheme(glass, colorScheme),
    chipTheme: ChipThemeData(
      backgroundColor: glass.tile,
      selectedColor: glass.selected,
      side: BorderSide(color: glass.rimShade),
      shape: AppShape.full,
    ),
    menuTheme: MenuThemeData(style: _menuStyle(glass)),
    popupMenuTheme: PopupMenuThemeData(
      color: glass.menu,
      surfaceTintColor: Colors.transparent,
      shadowColor: glass.shadow,
      elevation: 12,
      shape: AppShape.medium.copyWith(side: BorderSide(color: glass.rimShade)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: ShapeDecoration(
        color: glass.isDark
            ? Colors.white.withValues(alpha: 0.92)
            : const Color(0xE6161A2A),
        shape: AppShape.small,
      ),
      textStyle: base.textTheme.bodySmall?.copyWith(
        color: glass.isDark ? Colors.black : Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: glass.menu,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      elevation: 0,
      shape: AppShape.medium.copyWith(side: BorderSide(color: glass.rimShade)),
    ),
    listTileTheme: ListTileThemeData(iconColor: colorScheme.onSurfaceVariant),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      linearTrackColor: glass.divider,
      borderRadius: AppRadius.full,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(AppCorner.full),
      thumbColor: WidgetStatePropertyAll(
        colorScheme.onSurface.withValues(alpha: 0.2),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: ShapeDecoration(
        color: glass.selected,
        shape: AppShape.full.copyWith(
          side: BorderSide(color: glass.selectedRim),
        ),
      ),
      indicatorAnimation: TabIndicatorAnimation.elastic,
      splashBorderRadius: AppRadius.full,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      labelStyle: base.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

TextTheme _glassTextTheme(TextTheme text) {
  TextStyle? weight(TextStyle? style, FontWeight weight) =>
      style?.copyWith(fontWeight: weight);
  return text.copyWith(
    displaySmall: weight(text.displaySmall, FontWeight.w700),
    headlineLarge: weight(text.headlineLarge, FontWeight.w700),
    headlineMedium: weight(text.headlineMedium, FontWeight.w700),
    headlineSmall: weight(text.headlineSmall, FontWeight.w700),
    titleLarge: weight(text.titleLarge, FontWeight.w700),
    titleMedium: weight(text.titleMedium, FontWeight.w600),
    titleSmall: weight(text.titleSmall, FontWeight.w600),
  );
}

AppBarThemeData _appBarTheme(ThemeData base, ColorScheme colorScheme) {
  return AppBarThemeData(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
  );
}

InputDecorationThemeData _inputTheme(GlassStyle glass, ColorScheme scheme) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      AppShape.input.copyWith(
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecorationThemeData(
    filled: true,
    fillColor: glass.tile,
    border: AppShape.input,
    enabledBorder: border(glass.rimShade),
    disabledBorder: border(glass.divider),
    focusedBorder: border(scheme.primary, 1.5),
    errorBorder: border(scheme.error),
    focusedErrorBorder: border(scheme.error, 1.5),
  );
}

SegmentedButtonThemeData _segmentedTheme(GlassStyle glass, ColorScheme scheme) {
  return SegmentedButtonThemeData(
    style: ButtonStyle(
      shape: const WidgetStatePropertyAll(AppShape.full),
      side: WidgetStatePropertyAll(BorderSide(color: glass.rimShade)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? glass.selected : glass.tile,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.onSurfaceVariant,
      ),
    ),
  );
}

SwitchThemeData _switchTheme(GlassStyle glass, ColorScheme scheme) {
  return SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return scheme.onSurface.withValues(alpha: 0.3);
      }
      return states.contains(WidgetState.selected)
          ? scheme.onPrimary
          : Colors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? scheme.primary
          : scheme.onSurface.withValues(alpha: glass.isDark ? 0.18 : 0.14),
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  );
}

MenuStyle _menuStyle(GlassStyle glass) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(glass.menu),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(glass.shadow),
    elevation: const WidgetStatePropertyAll(12),
    padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
    shape: WidgetStatePropertyAll(
      AppShape.medium.copyWith(side: BorderSide(color: glass.rimShade)),
    ),
  );
}

extension GlassSchemeExt on ColorScheme {
  Color get modalScrim => scrim.withValues(alpha: 0.18);

  /// Containers turn into white veils so every Material surface reads as
  /// glass over the aurora; [surface] stays opaque as the floor behind it.
  ColorScheme toGlass(GlassStyle glass) {
    Color veil(double light, double dark) =>
        Colors.white.withValues(alpha: glass.isDark ? dark : light);
    return copyWith(
      surface: glass.aurora.base.first,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: veil(0.3, 0.03),
      surfaceContainerLow: veil(0.42, 0.05),
      surfaceContainer: veil(0.52, 0.07),
      surfaceContainerHigh: veil(0.62, 0.09),
      surfaceContainerHighest: veil(0.7, 0.11),
      outlineVariant: onSurface.withValues(alpha: glass.isDark ? 0.14 : 0.1),
      secondaryContainer: glass.selected,
      onSecondaryContainer: primary,
    );
  }
}

ColorScheme seededColorScheme(
  Color seed,
  Brightness brightness,
  DynamicSchemeVariant variant,
) {
  return ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );
}
