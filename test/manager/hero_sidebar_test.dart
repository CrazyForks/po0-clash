import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/hero_sidebar.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

final _items = [
  NavigationItem(
    icon: const Icon(Icons.space_dashboard),
    label: PageLabel.dashboard,
    builder: (_) => const SizedBox(),
  ),
  NavigationItem(
    icon: const Icon(Icons.construction),
    label: PageLabel.tools,
    builder: (_) => const SizedBox(),
  ),
];

ThemeData _heroTheme() => buildAppTheme(
  brightness: Brightness.light,
  materialScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  pageTransitionsTheme: const PageTransitionsTheme(),
  themeProps: const ThemeProps(),
  heroStyle: true,
);

Widget _sidebar({
  required bool showLabel,
  required int currentIndex,
  required ValueChanged<int> onSelected,
  required VoidCallback onToggleLabel,
}) {
  return TestApp(
    child: Theme(
      data: _heroTheme(),
      child: Scaffold(
        body: Row(
          children: [
            HeroSidebar(
              hero: HeroTheme.light,
              items: _items,
              currentIndex: currentIndex,
              showLabel: showLabel,
              showAppIcon: true,
              topInset: 0,
              onSelected: onSelected,
              onToggleLabel: onToggleLabel,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows labels, highlights the page and reports taps', (
    tester,
  ) async {
    int? selected;
    var toggled = 0;
    await tester.pumpWidget(
      _sidebar(
        showLabel: true,
        currentIndex: 0,
        onSelected: (index) => selected = index,
        onToggleLabel: () => toggled++,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text(appName), findsOneWidget);
    final toolsLabel = PageLabel.tools.label;
    expect(find.text(toolsLabel), findsOneWidget);
    expect(
      tester.getSize(find.byType(HeroSidebar)).width,
      HeroSidebar.expandedWidth,
    );

    final indicator = find.byType(AnimatedPositioned);
    expect(tester.widget<AnimatedPositioned>(indicator).top, 0);
    final pill = tester.widget<DecoratedBox>(
      find.descendant(of: indicator, matching: find.byType(DecoratedBox)),
    );
    expect(
      (pill.decoration as ShapeDecoration).color,
      tester.element(find.byType(HeroSidebar)).colorScheme.primaryContainer,
    );

    await tester.tap(find.text(toolsLabel));
    expect(selected, 1);

    await tester.tap(find.byIcon(Icons.menu_open));
    expect(toggled, 1);
  });

  testWidgets('the selection pill slides to the new page', (tester) async {
    Widget build(int index) => _sidebar(
      showLabel: true,
      currentIndex: index,
      onSelected: (_) {},
      onToggleLabel: () {},
    );
    await tester.pumpWidget(build(0));
    await tester.pumpAndSettle();
    final indicator = find.byType(AnimatedPositioned);
    final start = tester.getTopLeft(indicator).dy;

    await tester.pumpWidget(build(1));
    await tester.pump(HeroSidebar.indicatorDuration ~/ 2);
    final midway = tester.getTopLeft(indicator).dy;
    await tester.pumpAndSettle();
    final end = tester.getTopLeft(indicator).dy;

    expect(end - start, HeroSidebar.itemExtent + HeroSidebar.itemGap);
    expect(midway, greaterThan(start));
    expect(midway, lessThan(end + HeroSidebar.itemGap));
  });

  testWidgets('collapses to icons with tooltips', (tester) async {
    await tester.pumpWidget(
      _sidebar(
        showLabel: false,
        currentIndex: 1,
        onSelected: (_) {},
        onToggleLabel: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(HeroSidebar)).width,
      HeroSidebar.collapsedWidth,
    );
    expect(find.text(PageLabel.tools.label), findsNothing);
    expect(find.byType(Tooltip), findsWidgets);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('cards take the HeroUI surface and radius', (tester) async {
    await tester.pumpWidget(
      TestApp(
        child: Theme(
          data: _heroTheme(),
          child: Scaffold(
            body: CommonCard(onPressed: () {}, child: const Text('card')),
          ),
        ),
      ),
    );
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final style = button.style!;
    final shape = style.shape!.resolve({}) as RoundedSuperellipseBorder;
    expect((shape.borderRadius as BorderRadius).topLeft.x, HeroCorner.large);
    expect(style.elevation!.resolve({}), 0);
    final shadow = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byType(OutlinedButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (shadow.decoration as ShapeDecoration).shadows,
      HeroTheme.light.shadowSoft,
    );
    expect(style.side!.resolve({})!.color, HeroTheme.light.ring);
    expect(style.backgroundColor!.resolve({}), HeroTheme.light.content1);
  });
}
