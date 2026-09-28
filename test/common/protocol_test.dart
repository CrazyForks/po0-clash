import 'package:fl_clash/common/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolRegistrationPlan', () {
    test('builds registry writes for URL protocol registration', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'po0clash',
        executable: r'C:\Program Files\po0-clash\po0-clash.exe',
      );

      expect(plan.protocolKey, r'Software\Classes\po0clash');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\Program Files\po0-clash\po0-clash.exe" "%1"');
    });
  });

  test('claims its own scheme, not the one upstream FlClash registers', () {
    expect(protocolSchemes, ['clash', 'clashmeta', 'po0clash']);
  });

  group('LinuxProtocolRegistrationPlan', () {
    const plan = LinuxProtocolRegistrationPlan(
      schemes: protocolSchemes,
      executable: '/home/me/Apps/po0-clash.AppImage',
      applicationsDir: '/home/me/.local/share/applications',
    );

    test('writes a hidden desktop entry claiming every scheme', () {
      expect(
        plan.desktopPath,
        '/home/me/.local/share/applications/po0clash-url-handler.desktop',
      );
      expect(
        plan.desktopEntry,
        '[Desktop Entry]\n'
        'Type=Application\n'
        'Name=po0-clash\n'
        'NoDisplay=true\n'
        'Exec="/home/me/Apps/po0-clash.AppImage" %u\n'
        'MimeType=x-scheme-handler/clash;x-scheme-handler/clashmeta;'
        'x-scheme-handler/po0clash;\n',
      );
    });

    test('makes the entry the default handler for every scheme', () {
      expect(plan.xdgMimeArguments, [
        'default',
        'po0clash-url-handler.desktop',
        'x-scheme-handler/clash',
        'x-scheme-handler/clashmeta',
        'x-scheme-handler/po0clash',
      ]);
    });

    test('escapes reserved characters in the executable path', () {
      const plan = LinuxProtocolRegistrationPlan(
        schemes: ['po0clash'],
        executable: r'/opt/my "apps"/$HOME/100%/Fl`Clash\bin',
        applicationsDir: '/tmp',
      );

      expect(plan.exec, r'"/opt/my \"apps\"/\$HOME/100%%/Fl\`Clash\\bin" %u');
    });
  });
}
