import 'package:material_ui/material_ui.dart';

abstract final class AppCorner {
  static const double none = 0;
  static const double extraSmall = 8;
  static const double small = 12;
  static const double medium = 18;
  static const double large = 24;
  static const double largeIncreased = 28;
  static const double extraLarge = 32;
  static const double full = 1000;
}

abstract final class AppRadius {
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius extraSmall = BorderRadius.all(
    Radius.circular(AppCorner.extraSmall),
  );
  static const BorderRadius small = BorderRadius.all(
    Radius.circular(AppCorner.small),
  );
  static const BorderRadius medium = BorderRadius.all(
    Radius.circular(AppCorner.medium),
  );
  static const BorderRadius large = BorderRadius.all(
    Radius.circular(AppCorner.large),
  );
  static const BorderRadius extraLarge = BorderRadius.all(
    Radius.circular(AppCorner.extraLarge),
  );
  static const BorderRadius full = BorderRadius.all(
    Radius.circular(AppCorner.full),
  );

  static BorderRadius all(double corner) => BorderRadius.circular(corner);

  static BorderRadius top(double corner) =>
      BorderRadius.vertical(top: Radius.circular(corner));

  static BorderRadius vertical({
    double top = AppCorner.none,
    double bottom = AppCorner.none,
  }) => BorderRadius.vertical(
    top: Radius.circular(top),
    bottom: Radius.circular(bottom),
  );
}

abstract final class AppShape {
  static const RoundedSuperellipseBorder none = RoundedSuperellipseBorder();
  static const RoundedSuperellipseBorder extraSmall = RoundedSuperellipseBorder(
    borderRadius: AppRadius.extraSmall,
  );
  static const RoundedSuperellipseBorder small = RoundedSuperellipseBorder(
    borderRadius: AppRadius.small,
  );
  static const RoundedSuperellipseBorder medium = RoundedSuperellipseBorder(
    borderRadius: AppRadius.medium,
  );
  static const RoundedSuperellipseBorder large = RoundedSuperellipseBorder(
    borderRadius: AppRadius.large,
  );
  static const RoundedSuperellipseBorder extraLarge = RoundedSuperellipseBorder(
    borderRadius: AppRadius.extraLarge,
  );
  static const StadiumBorder full = StadiumBorder();
  static const CircleBorder circle = CircleBorder();
  static const OutlineInputBorder input = OutlineInputBorder(
    borderRadius: AppRadius.small,
    borderSide: BorderSide.none,
  );

  static RoundedSuperellipseBorder all(double corner) =>
      RoundedSuperellipseBorder(borderRadius: AppRadius.all(corner));

  static RoundedSuperellipseBorder top(double corner) =>
      RoundedSuperellipseBorder(borderRadius: AppRadius.top(corner));

  static RoundedSuperellipseBorder vertical({
    double top = AppCorner.none,
    double bottom = AppCorner.none,
  }) => RoundedSuperellipseBorder(
    borderRadius: AppRadius.vertical(top: top, bottom: bottom),
  );

  static RoundedSuperellipseBorder of(BorderRadius borderRadius) =>
      RoundedSuperellipseBorder(borderRadius: borderRadius);
}
