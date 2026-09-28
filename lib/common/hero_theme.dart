import 'package:fl_clash/models/config.dart';
import 'package:material_ui/material_ui.dart';

import 'color.dart';
import 'constant.dart';
import 'shape.dart';

const heroPrimary = Color(0xFF006FEE);

abstract final class HeroCorner {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 14;
}

/// HeroUI v2 default-theme tokens. Its presence in [ThemeData.extensions] is
/// what switches widgets to the HeroUI look, so tests on any host choose the
/// style through the theme rather than through the platform.
@immutable
class HeroTheme extends ThemeExtension<HeroTheme> {
  const HeroTheme({
    required this.background,
    required this.foreground,
    required this.content1,
    required this.content2,
    required this.default50,
    required this.default100,
    required this.default200,
    required this.default300,
    required this.default400,
    required this.default500,
    required this.divider,
    required this.ring,
    required this.scrim,
    required this.success,
    required this.warning,
    required this.danger,
    required this.secondary,
  });

  final Color background;
  final Color foreground;
  final Color content1;
  final Color content2;
  final Color default50;
  final Color default100;
  final Color default200;
  final Color default300;
  final Color default400;
  final Color default500;
  final Color divider;
  final Color ring;
  final Color scrim;
  final Color success;
  final Color warning;
  final Color danger;
  final Color secondary;

  static const light = HeroTheme(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF11181C),
    content1: Color(0xFFFFFFFF),
    content2: Color(0xFFF4F4F5),
    default50: Color(0xFFFAFAFA),
    default100: Color(0xFFF4F4F5),
    default200: Color(0xFFE4E4E7),
    default300: Color(0xFFD4D4D8),
    default400: Color(0xFFA1A1AA),
    default500: Color(0xFF71717A),
    divider: Color(0x26111111),
    ring: Color(0x17000000),
    scrim: Color(0x59000000),
    success: Color(0xFF17C964),
    warning: Color(0xFFF5A524),
    danger: Color(0xFFF31260),
    secondary: Color(0xFF7828C8),
  );

  static const dark = HeroTheme(
    background: Color(0xFF000000),
    foreground: Color(0xFFECEDEE),
    content1: Color(0xFF18181B),
    content2: Color(0xFF27272A),
    default50: Color(0xFF0E0E10),
    default100: Color(0xFF27272A),
    default200: Color(0xFF3F3F46),
    default300: Color(0xFF52525B),
    default400: Color(0xFF71717A),
    default500: Color(0xFFA1A1AA),
    divider: Color(0x26FFFFFF),
    ring: Color(0x1FFFFFFF),
    scrim: Color(0x8C000000),
    success: Color(0xFF17C964),
    warning: Color(0xFFF5A524),
    danger: Color(0xFFF31260),
    secondary: Color(0xFF9353D3),
  );

  static HeroTheme of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static HeroTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<HeroTheme>();

  List<Color> get _tokens => [
    background,
    foreground,
    content1,
    content2,
    default50,
    default100,
    default200,
    default300,
    default400,
    default500,
    divider,
    ring,
    scrim,
    success,
    warning,
    danger,
    secondary,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! HeroTheme) {
      return false;
    }
    final tokens = _tokens;
    final otherTokens = other._tokens;
    for (var i = 0; i < tokens.length; i++) {
      if (tokens[i] != otherTokens[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_tokens);

  List<BoxShadow> get shadowSoft => const [
    BoxShadow(color: Color(0x05000000), blurRadius: 5),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 2), blurRadius: 10),
  ];

  List<BoxShadow> get shadowMedium => const [
    BoxShadow(color: Color(0x08000000), blurRadius: 15),
    BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 30),
  ];

  List<BoxShadow> get shadowSmall => [
    ...shadowSoft,
    BoxShadow(color: ring, blurRadius: 1),
  ];

  @override
  HeroTheme copyWith({
    Color? background,
    Color? foreground,
    Color? content1,
    Color? content2,
    Color? default50,
    Color? default100,
    Color? default200,
    Color? default300,
    Color? default400,
    Color? default500,
    Color? divider,
    Color? ring,
    Color? scrim,
    Color? success,
    Color? warning,
    Color? danger,
    Color? secondary,
  }) {
    return HeroTheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      content1: content1 ?? this.content1,
      content2: content2 ?? this.content2,
      default50: default50 ?? this.default50,
      default100: default100 ?? this.default100,
      default200: default200 ?? this.default200,
      default300: default300 ?? this.default300,
      default400: default400 ?? this.default400,
      default500: default500 ?? this.default500,
      divider: divider ?? this.divider,
      ring: ring ?? this.ring,
      scrim: scrim ?? this.scrim,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      secondary: secondary ?? this.secondary,
    );
  }

  @override
  HeroTheme lerp(covariant HeroTheme? other, double t) {
    if (other == null) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return HeroTheme(
      background: mix(background, other.background),
      foreground: mix(foreground, other.foreground),
      content1: mix(content1, other.content1),
      content2: mix(content2, other.content2),
      default50: mix(default50, other.default50),
      default100: mix(default100, other.default100),
      default200: mix(default200, other.default200),
      default300: mix(default300, other.default300),
      default400: mix(default400, other.default400),
      default500: mix(default500, other.default500),
      divider: mix(divider, other.divider),
      ring: mix(ring, other.ring),
      scrim: mix(scrim, other.scrim),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      secondary: mix(secondary, other.secondary),
    );
  }
}

/// HeroUI's "flat" variant: the accent at 20% over the surface, with a text
/// colour pushed towards the surface's contrast.
({Color container, Color onContainer}) heroFlat(
  Color accent,
  Brightness brightness,
) {
  final hero = HeroTheme.of(brightness);
  final isDark = brightness == Brightness.dark;
  return (
    container: Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.24 : 0.16),
      hero.content1,
    ),
    onContainer: Color.lerp(
      accent,
      isDark ? Colors.white : Colors.black,
      isDark ? 0.35 : 0.2,
    )!,
  );
}

ColorScheme heroColorScheme(
  Brightness brightness, {
  Color primary = heroPrimary,
}) {
  final hero = HeroTheme.of(brightness);
  final isDark = brightness == Brightness.dark;
  final primaryFlat = heroFlat(primary, brightness);
  final secondaryFlat = heroFlat(hero.secondary, brightness);
  final dangerFlat = heroFlat(hero.danger, brightness);
  return ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryFlat.container,
    onPrimaryContainer: primaryFlat.onContainer,
    secondary: primary,
    onSecondary: Colors.white,
    secondaryContainer: primaryFlat.container,
    onSecondaryContainer: primaryFlat.onContainer,
    tertiary: hero.secondary,
    onTertiary: Colors.white,
    tertiaryContainer: secondaryFlat.container,
    onTertiaryContainer: secondaryFlat.onContainer,
    error: hero.danger,
    onError: Colors.white,
    errorContainer: dangerFlat.container,
    onErrorContainer: dangerFlat.onContainer,
    surface: hero.background,
    onSurface: hero.foreground,
    onSurfaceVariant: hero.default500,
    surfaceDim: hero.content2,
    surfaceBright: hero.content1,
    surfaceContainerLowest: hero.background,
    surfaceContainerLow: hero.content1,
    surfaceContainer: isDark ? hero.content1 : hero.default50,
    surfaceContainerHigh: hero.default100,
    surfaceContainerHighest: hero.default200,
    outline: hero.default300,
    outlineVariant: hero.default200,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: hero.foreground,
    onInverseSurface: hero.background,
    inversePrimary: Color.lerp(primary, Colors.white, 0.4)!,
    surfaceTint: Colors.transparent,
  );
}

/// FlClash's stock accent maps to HeroUI blue; any other picked accent is kept.
ThemeData buildAppTheme({
  required Brightness brightness,
  required ColorScheme materialScheme,
  required PageTransitionsTheme pageTransitionsTheme,
  required ThemeProps themeProps,
  required bool heroStyle,
}) {
  if (!heroStyle) {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: brightness == Brightness.dark
          ? materialScheme.toPureBlack(themeProps.pureBlack)
          : materialScheme,
    ).withAppShapes;
  }
  final primaryColor = themeProps.primaryColor;
  final primary = primaryColor == null || primaryColor == defaultPrimaryColor
      ? heroPrimary
      : Color(primaryColor);
  return ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: pageTransitionsTheme,
    colorScheme: heroColorScheme(brightness, primary: primary),
  ).withAppShapes.withHeroStyle;
}

extension HeroThemeDataExt on ThemeData {
  ThemeData get withHeroStyle {
    final hero = HeroTheme.of(brightness);
    final scheme = colorScheme;
    final medium = AppShape.all(HeroCorner.medium);
    final large = AppShape.all(HeroCorner.large);
    final buttonText = textTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 16);
    const buttonSize = Size(64, 40);
    final hover = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return hero.default200.withValues(alpha: 0.6);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return hero.default100.withValues(alpha: 0.8);
      }
      return null;
    });
    return copyWith(
      extensions: [...extensions.values, hero],
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerColor: hero.divider,
      hoverColor: hero.default100.withValues(alpha: 0.6),
      dividerTheme: DividerThemeData(color: hero.divider, thickness: 1),
      appBarTheme: appBarTheme.copyWith(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        // textTheme has no sizes until Theme.of merges the typography in.
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.4,
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: cardTheme.copyWith(
        color: hero.content1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        elevation: 1,
        shape: large.copyWith(side: BorderSide(color: hero.ring)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: medium,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: medium,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: buttonText,
          elevation: 0,
          backgroundColor: hero.default100,
          foregroundColor: scheme.onSurface,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: medium,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: buttonText,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: hero.default200, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: medium,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: buttonText,
        ).copyWith(overlayColor: hover),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: medium,
        ).copyWith(overlayColor: hover),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: medium,
          side: BorderSide(color: hero.default200),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
        ),
      ),
      switchTheme: SwitchThemeData(
        // A non-null icon keeps the thumb full-size in both states, as the
        // HeroUI switch does; Material shrinks an unselected bare thumb.
        thumbIcon: const WidgetStatePropertyAll(Icon(null)),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : hero.default200,
        ),
      ),
      checkboxTheme: checkboxTheme.copyWith(
        shape: AppShape.all(6),
        side: BorderSide(color: hero.default300, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : hero.default400,
        ),
      ),
      inputDecorationTheme: inputDecorationTheme.copyWith(
        filled: true,
        fillColor: hero.default100,
        hoverColor: hero.default200.withValues(alpha: 0.5),
        border: const AppInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(HeroCorner.medium)),
        ),
        enabledBorder: const AppInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(HeroCorner.medium)),
        ),
        focusedBorder: AppInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
          borderRadius: const BorderRadius.all(
            Radius.circular(HeroCorner.medium),
          ),
        ),
        errorBorder: AppInputBorder(
          borderSide: BorderSide(color: hero.danger),
          borderRadius: const BorderRadius.all(
            Radius.circular(HeroCorner.medium),
          ),
        ),
        focusedErrorBorder: AppInputBorder(
          borderSide: BorderSide(color: hero.danger, width: 2),
          borderRadius: const BorderRadius.all(
            Radius.circular(HeroCorner.medium),
          ),
        ),
      ),
      dialogTheme: dialogTheme.copyWith(
        backgroundColor: hero.content1,
        surfaceTintColor: Colors.transparent,
        shape: large,
      ),
      bottomSheetTheme: bottomSheetTheme.copyWith(
        backgroundColor: hero.content1,
        surfaceTintColor: Colors.transparent,
        shape: AppShape.top(HeroCorner.large),
      ),
      popupMenuTheme: popupMenuTheme.copyWith(
        color: hero.content1,
        surfaceTintColor: Colors.transparent,
        shape: medium.copyWith(side: BorderSide(color: hero.ring)),
      ),
      menuTheme: MenuThemeData(
        style: (menuTheme.style ?? const MenuStyle()).copyWith(
          backgroundColor: WidgetStatePropertyAll(hero.content1),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            medium.copyWith(side: BorderSide(color: hero.ring)),
          ),
        ),
      ),
      tooltipTheme: tooltipTheme.copyWith(
        decoration: ShapeDecoration(
          color: hero.content1,
          shape: AppShape.all(HeroCorner.small),
          shadows: hero.shadowSmall,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: hero.foreground,
        ),
      ),
      chipTheme: chipTheme.copyWith(
        shape: AppShape.full,
        side: BorderSide.none,
        backgroundColor: hero.default100,
        selectedColor: scheme.primaryContainer,
      ),
      snackBarTheme: snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        shape: medium,
      ),
      tabBarTheme: tabBarTheme.copyWith(
        indicator: ShapeDecoration(
          color: scheme.primaryContainer,
          shape: medium,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: hero.default500,
      ),
      navigationRailTheme: navigationRailTheme.copyWith(
        indicatorShape: medium,
        indicatorColor: scheme.primaryContainer,
      ),
      navigationBarTheme: navigationBarTheme.copyWith(
        indicatorShape: medium,
        indicatorColor: scheme.primaryContainer,
      ),
      floatingActionButtonTheme: floatingActionButtonTheme.copyWith(
        shape: large,
        elevation: 2,
      ),
      progressIndicatorTheme: progressIndicatorTheme.copyWith(
        linearTrackColor: hero.default200,
      ),
      scrollbarTheme: scrollbarTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(hero.default300),
        radius: const Radius.circular(HeroCorner.small),
      ),
    );
  }
}
