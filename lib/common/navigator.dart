import 'package:material_ui/material_ui.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Android animates pages along with the predictive back gesture; the other
/// platforms use the same fade-forwards transition it falls back to.
const appPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
  },
);

class BaseNavigator {
  static Future<T?> push<T>(BuildContext context, Widget child) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute<T>(builder: (_) => child));
  }
}
