import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/code_field.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CodeField(
              controller: controller,
              errorText: null,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  Finder field() => find.byType(TextField);

  /// 左から index 番目のマスを押す
  Future<void> tapBox(WidgetTester tester, int index) async {
    final origin = tester.getTopLeft(find.byType(CodeField));
    final left = index * (56 + 8) + (index >= 3 ? 24 - 8 : 0);
    await tester.tapAt(origin + Offset(left + 28.0, 32));
    await tester.pump();
  }

  testWidgets('全角の数字は半角にして受け付ける', (tester) async {
    await pump(tester);

    await tester.enterText(field(), '１２３４５６');

    expect(controller.text, '123456');
  });

  testWidgets('6桁より先は入らない', (tester) async {
    await pump(tester);

    await tester.enterText(field(), '1234567');

    expect(controller.text, '123456');
  });

  testWidgets('押したマスの桁を、打ち直した数字で書き換える', (tester) async {
    await pump(tester);
    await tester.enterText(field(), '123456');
    await tester.pump();

    await tapBox(tester, 2);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 2, extentOffset: 3),
    );

    // 選んだ1文字を、打った数字で置き換えたのと同じ
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '129456',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();

    expect(controller.text, '129456');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 3, extentOffset: 4),
    );
  });

  testWidgets('押したマスで Backspace を押すと、その桁だけが空き、後ろは詰めない', (tester) async {
    await pump(tester);
    await tester.enterText(field(), '123456');
    await tester.pump();

    await tapBox(tester, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(controller.text, '12 456');
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsOneWidget);

    // 空いた桁でもう一度押すと、1つ前の桁を消して戻る
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(controller.text, '1  456');
    expect(
      controller.selection,
      const TextSelection(baseOffset: 1, extentOffset: 2),
    );
  });

  testWidgets('末尾から Backspace を押すと、1桁ずつ消える', (tester) async {
    await pump(tester);
    await tester.enterText(field(), '123');
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(controller.text, '12');
  });
}
