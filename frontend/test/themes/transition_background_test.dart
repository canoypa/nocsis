import 'package:animations/animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/themes/app.dart';

Color _transitionBackground(WidgetTester tester, Type transition) {
  return tester
      .widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(transition),
              matching: find.byType(ColoredBox),
            )
            .first,
      )
      .color;
}

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final expected =
        (mode == ThemeMode.dark ? darkTheme : lightTheme).canvasColor;

    group('画面遷移の背景がアプリのテーマに従う ($mode)', () {
      testWidgets('FadeThroughTransition', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: mode,
            home: const FadeThroughTransition(
              animation: AlwaysStoppedAnimation(0.5),
              secondaryAnimation: AlwaysStoppedAnimation(0),
              child: SizedBox(),
            ),
          ),
        );

        expect(_transitionBackground(tester, FadeThroughTransition), expected);
      });

      testWidgets('SharedAxisTransition', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: mode,
            home: const SharedAxisTransition(
              animation: AlwaysStoppedAnimation(0.5),
              secondaryAnimation: AlwaysStoppedAnimation(0),
              transitionType: SharedAxisTransitionType.vertical,
              child: SizedBox(),
            ),
          ),
        );

        expect(_transitionBackground(tester, SharedAxisTransition), expected);
      });
    });
  }
}
