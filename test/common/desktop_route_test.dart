import 'package:fl_clash/common/desktop_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tunOnly = (tun: true, systemProxy: false);
  const proxyOnly = (tun: false, systemProxy: true);

  test('a state with exactly one route is left alone', () {
    expect(reconcileDesktopRoute(tunOnly), tunOnly);
    expect(reconcileDesktopRoute(proxyOnly), proxyOnly);
    expect(
      reconcileDesktopRoute(tunOnly, changed: DesktopRoute.systemProxy),
      tunOnly,
    );
  });

  test('turning one route on turns the other off', () {
    const both = (tun: true, systemProxy: true);
    expect(reconcileDesktopRoute(both, changed: DesktopRoute.tun), tunOnly);
    expect(
      reconcileDesktopRoute(both, changed: DesktopRoute.systemProxy),
      proxyOnly,
    );
  });

  test('turning the only route off turns the other on', () {
    const none = (tun: false, systemProxy: false);
    expect(reconcileDesktopRoute(none, changed: DesktopRoute.tun), proxyOnly);
    expect(
      reconcileDesktopRoute(none, changed: DesktopRoute.systemProxy),
      tunOnly,
    );
  });

  test('a loaded config in a broken state settles on TUN', () {
    expect(reconcileDesktopRoute((tun: false, systemProxy: false)), tunOnly);
    expect(reconcileDesktopRoute((tun: true, systemProxy: true)), tunOnly);
  });
}
