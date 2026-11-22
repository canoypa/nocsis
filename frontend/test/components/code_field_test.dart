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
    await tester.pump();
  }

  Finder field() => find.byType(TextField);

  Offset boxCenter(WidgetTester tester, int index) {
    final origin = tester.getTopLeft(find.byType(CodeField));
    final left = index * (56 + 8) + (index >= 3 ? 24 - 8 : 0);
    return origin + Offset(left + 28.0, 32);
  }

  Future<void> tapBox(WidgetTester tester, int index) async {
    await tester.tapAt(boxCenter(tester, index));
    await tester.pump();
  }

  /// 選ばれているマス。枠が太い
  int? selectedBox(WidgetTester tester) {
    final boxes = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(CodeField),
            matching: find.byType(Container),
          ),
        )
        .where((c) => c.decoration is BoxDecoration)
        .toList();
    for (var i = 0; i < boxes.length; i++) {
      final border = (boxes[i].decoration! as BoxDecoration).border! as Border;
      if (border.top.width == 2) return i;
    }
    return null;
  }

  /// 入力欄の末尾に打ったのと同じ
  Future<void> type(WidgetTester tester, String text) async {
    final value = controller.text + text;
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      ),
    );
    await tester.pump();
  }

  Future<void> backspace(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
  }

  testWidgets('全角の数字は半角にして受け付ける', (tester) async {
    await pump(tester);

    await tester.enterText(field(), '１２３４５６');

    expect(controller.text, '123456');
  });

  testWidgets('6桁を打っても6マス目に留まり、その先へは入らない', (tester) async {
    await pump(tester);

    await type(tester, '123456');
    expect(selectedBox(tester), 5);

    await type(tester, '7');
    expect(controller.text, '123457');
    expect(selectedBox(tester), 5);
  });

  testWidgets('Backspace は選んだマスの桁を消し、前のマスへ移る', (tester) async {
    await pump(tester);
    await type(tester, '123456');

    await backspace(tester);
    expect(controller.text, '12345');
    expect(selectedBox(tester), 4);

    await backspace(tester);
    expect(controller.text, '1234');
    expect(selectedBox(tester), 3);
  });

  testWidgets('途中のマスで Backspace を押すと、その桁だけが空き、後ろは詰めない', (tester) async {
    await pump(tester);
    await type(tester, '123456');

    await tapBox(tester, 2);
    expect(selectedBox(tester), 2);

    await backspace(tester);
    expect(controller.text, '12 456');
    expect(selectedBox(tester), 1);

    await backspace(tester);
    expect(controller.text, '1  456');
    expect(selectedBox(tester), 0);
  });

  testWidgets('空いたマスで Backspace を押すと、消さずに前のマスへ移る', (tester) async {
    await pump(tester);
    await type(tester, '123456');
    await tapBox(tester, 2);
    await backspace(tester);
    await tapBox(tester, 2);

    await backspace(tester);

    expect(controller.text, '12 456');
    expect(selectedBox(tester), 1);
  });

  testWidgets('選んだマスに打つと、その桁を書き換えて次のマスへ移る', (tester) async {
    await pump(tester);
    await type(tester, '123456');

    await tapBox(tester, 2);
    await type(tester, '9');

    expect(controller.text, '129456');
    expect(selectedBox(tester), 3);
  });

  testWidgets('空いたマスより先は選べない', (tester) async {
    await pump(tester);
    await type(tester, '12');

    await tapBox(tester, 5);

    expect(selectedBox(tester), 2);
  });
}
