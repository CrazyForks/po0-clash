import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

String _androidAttribute(String source, String element, String attribute) {
  final elementTag = RegExp('<$element\\b[^>]*>').firstMatch(source)!.group(0)!;
  return RegExp(
    'android:$attribute="([^"]+)"',
  ).firstMatch(elementTag)!.group(1)!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TV launcher icons meet density-specific minimum sizes', () async {
    const expectedSizes = {
      'mdpi': 80,
      'hdpi': 120,
      'xhdpi': 160,
      'xxhdpi': 240,
      'xxxhdpi': 320,
    };

    for (final MapEntry(key: density, value: size) in expectedSizes.entries) {
      final file = File(
        'android/app/src/main/res/'
        'mipmap-television-$density/ic_launcher.webp',
      );
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');

      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      expect(
        (frame.image.width, frame.image.height),
        (size, size),
        reason: file.path,
      );
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('the adaptive launcher foreground stays inside the safe zone', () async {
    for (final path in [
      'mipmap-anydpi-v26/ic_launcher.xml',
      'mipmap-television-anydpi-v26/ic_launcher.xml',
    ]) {
      final adaptiveIcon = File(
        'android/app/src/main/res/$path',
      ).readAsStringSync();
      expect(
        _androidAttribute(adaptiveIcon, 'foreground', 'drawable'),
        '@mipmap/ic_launcher_foreground',
        reason: path,
      );
      expect(
        _androidAttribute(adaptiveIcon, 'background', 'drawable'),
        '@mipmap/ic_launcher_background',
        reason: path,
      );
    }

    final file = File(
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png',
    );
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    final image = (await codec.getNextFrame()).image;
    final pixels = (await image.toByteData())!;
    final center = image.width / 2;
    var reach = 0.0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final alpha = pixels.getUint8((y * image.width + x) * 4 + 3);
        if (alpha > 8) {
          final dx = x + 0.5 - center;
          final dy = y + 0.5 - center;
          final distance = math.sqrt(dx * dx + dy * dy);
          if (distance > reach) reach = distance;
        }
      }
    }
    // Launchers crop the 108dp layer to a 66dp circle at most.
    expect(reach, lessThanOrEqualTo(image.width * 33 / 108));
    image.dispose();
    codec.dispose();
  });
}
