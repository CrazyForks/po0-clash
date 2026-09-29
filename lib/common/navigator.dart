import 'package:fl_clash/widgets/glass.dart';
import 'package:material_ui/material_ui.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Android animates pages along with the predictive back gesture; the other
/// platforms use the fade-forwards transition it falls back to, with a clear
/// background so a page pushed inside a glass panel never flashes opaque.
const appPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    TargetPlatform.windows: _glassFadeForwards,
    TargetPlatform.linux: _glassFadeForwards,
    TargetPlatform.macOS: _glassFadeForwards,
  },
);

const _glassFadeForwards = FadeForwardsPageTransitionsBuilder(
  backgroundColor: Colors.transparent,
);

class BaseNavigator {
  /// A page pushed over the whole window brings its own aurora; one pushed
  /// inside a workspace panel stays glass over the panel.
  static Future<T?> push<T>(BuildContext context, Widget child) {
    final navigator = Navigator.of(context);
    final coversWindow =
        navigator == Navigator.of(context, rootNavigator: true);
    return navigator.push<T>(
      MaterialPageRoute<T>(
        builder: (_) => coversWindow ? AuroraFloor(child: child) : child,
      ),
    );
  }
}
