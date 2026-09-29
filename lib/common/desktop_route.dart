enum DesktopRoute { tun, systemProxy }

typedef DesktopRouteState = ({bool tun, bool systemProxy});

/// Exactly one route is on: the side just flipped wins, and TUN wins a config
/// loaded in a broken state.
DesktopRouteState reconcileDesktopRoute(
  DesktopRouteState state, {
  DesktopRoute? changed,
}) {
  if (state.tun != state.systemProxy) {
    return state;
  }
  final useTun = state.tun
      ? changed != DesktopRoute.systemProxy
      : changed != DesktopRoute.tun;
  return (tun: useTun, systemProxy: !useTun);
}
