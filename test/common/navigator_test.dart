import 'package:fl_clash/common/navigator.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  void setViewWidth(double width) {
    container.read(viewSizeProvider.notifier).value = Size(width, 900);
  }

  Future<void> pumpHost(
    WidgetTester tester, {
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(
            platform: platform,
            pageTransitionsTheme: appPageTransitionsTheme,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => BaseNavigator.push(
                  context,
                  const Scaffold(body: Text('pushed page')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('BaseNavigator.push', () {
    for (final width in [400.0, 1400.0]) {
      testWidgets('pushes a themed Material route at width $width', (
        tester,
      ) async {
        setViewWidth(width);
        await pumpHost(tester);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('pushed page'), findsOneWidget);
        final route = ModalRoute.of(tester.element(find.text('pushed page')));
        expect(route, isA<MaterialPageRoute<dynamic>>());
      });
    }

    testWidgets('animates the fade-forwards transition on desktop', (
      tester,
    ) async {
      setViewWidth(1400);
      await pumpHost(tester, platform: TargetPlatform.macOS);

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('pushed page'), findsOneWidget);
      expect(find.text('open'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('open'), findsNothing);
    });

    testWidgets('pops back to the origin', (tester) async {
      setViewWidth(1400);
      await pumpHost(tester);
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('pushed page'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('pushed page'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  test('Android follows the back gesture, the rest fade forwards', () {
    final builders = appPageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.android],
      isA<PredictiveBackPageTransitionsBuilder>(),
    );
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ]) {
      expect(
        builders[platform],
        isA<FadeForwardsPageTransitionsBuilder>(),
        reason: '$platform',
      );
    }
  });
}
