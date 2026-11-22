import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';

void main() {
  Future<ThemeData> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(children: [PageTitle('ページ'), SectionTitle('節')]),
      ),
    );
    return Theme.of(tester.element(find.text('ページ')));
  }

  TextStyle? styleOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style;

  testWidgets('1200 未満では Headline と Title に下げる', (tester) async {
    final theme = await pumpAt(tester, 1199);

    expect(styleOf(tester, 'ページ'), theme.textTheme.headlineLarge);
    expect(styleOf(tester, '節'), theme.textTheme.titleLarge);
  });

  testWidgets('1200 以上では Display と Headline にする', (tester) async {
    final theme = await pumpAt(tester, 1200);

    expect(styleOf(tester, 'ページ'), theme.textTheme.displayMedium);
    expect(styleOf(tester, '節'), theme.textTheme.headlineMedium);
  });
}
