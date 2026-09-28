import 'package:fl_clash/widgets/popup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late List<String> pressed;

  setUp(() => pressed = []);

  List<CommonPopupMenuItem> items() => [
    CommonPopupMenuItem(
      icon: Icons.search,
      label: 'Search',
      onPressed: () => pressed.add('search'),
    ),
    const CommonPopupMenuItem(label: 'Disabled'),
    CommonPopupMenuItem(
      icon: Icons.delete_outline,
      label: 'Delete',
      danger: true,
      onPressed: () => pressed.add('delete'),
    ),
    CommonPopupMenuItem(
      label: 'More',
      subItems: [
        CommonPopupMenuItem(
          label: 'Nested',
          onPressed: () => pressed.add('nested'),
        ),
      ],
    ),
  ];

  Future<void> pumpMenu(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              items: items(),
              targetBuilder: (open) =>
                  TextButton(onPressed: open, child: const Text('open')),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the menu is a Material 3 menu anchor, built once opened', (
    tester,
  ) async {
    await pumpMenu(tester);
    expect(find.byType(MenuAnchor), findsOneWidget);
    expect(find.text('Search'), findsNothing);

    await open(tester);
    expect(find.widgetWithText(MenuItemButton, 'Search'), findsOneWidget);
    expect(find.widgetWithText(SubmenuButton, 'More'), findsOneWidget);
  });

  testWidgets('picking an item runs it and closes the menu', (tester) async {
    await pumpMenu(tester);
    await open(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(pressed, ['search']);
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('an item without an action is disabled', (tester) async {
    await pumpMenu(tester);
    await open(tester);

    final button = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Disabled'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('a danger item uses the error color', (tester) async {
    await pumpMenu(tester);
    await open(tester);

    final button = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Delete'),
    );
    final error = Theme.of(
      tester.element(find.text('Delete')),
    ).colorScheme.error;
    expect(button.style!.foregroundColor!.resolve({}), error);
    expect(button.style!.iconColor!.resolve({}), error);
  });

  testWidgets('sub items open in a cascading submenu', (tester) async {
    await pumpMenu(tester);
    await open(tester);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nested'));
    await tester.pumpAndSettle();

    expect(pressed, ['nested']);
    expect(find.text('Nested'), findsNothing);
  });

  testWidgets('a tap outside closes the menu', (tester) async {
    await pumpMenu(tester);
    await open(tester);
    expect(find.text('Search'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsNothing);
  });
}
