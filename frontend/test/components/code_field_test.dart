import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/code_field.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  var submitted = 0;

  Future<void> pump(WidgetTester tester, {double? width}) async {
    submitted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: CodeField(
                controller: controller,
                errorText: null,
                onChanged: (_) {},
                onSubmitted: () => submitted++,
              ),
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

  Future<void> key(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  testWidgets('← → で隣のマスへ移り、端と入力済みの1つ後ろで止まる', (tester) async {
    await pump(tester);
    await type(tester, '12');

    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(selectedBox(tester), 1);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    await key(tester, LogicalKeyboardKey.arrowLeft);
    expect(selectedBox(tester), 0);

    await key(tester, LogicalKeyboardKey.arrowRight);
    await key(tester, LogicalKeyboardKey.arrowRight);
    await key(tester, LogicalKeyboardKey.arrowRight);
    expect(selectedBox(tester), 2);
  });

  testWidgets('Home で1マス目、End で入力済みの1つ後ろへ移る', (tester) async {
    await pump(tester);
    await type(tester, '123');

    await key(tester, LogicalKeyboardKey.home);
    expect(selectedBox(tester), 0);
    await key(tester, LogicalKeyboardKey.end);
    expect(selectedBox(tester), 3);
  });

  testWidgets('Delete は選んだマスの桁を消し、そのマスに留まる', (tester) async {
    await pump(tester);
    await type(tester, '123456');
    await tapBox(tester, 2);

    await key(tester, LogicalKeyboardKey.delete);

    expect(controller.text, '12 456');
    expect(selectedBox(tester), 2);
  });

  testWidgets('6桁を貼り付けると、どのマスからでも全体を置き換える', (tester) async {
    await pump(tester);
    await type(tester, '123456');
    await tapBox(tester, 2);

    await type(tester, 'コード: ９８７-６５４');

    expect(controller.text, '987654');
    expect(selectedBox(tester), 5);
  });

  testWidgets('6桁未満を貼り付けると、選んだマスから上書きする', (tester) async {
    await pump(tester);
    await type(tester, '123456');
    await tapBox(tester, 1);

    await type(tester, '9-8');

    expect(controller.text, '198456');
    expect(selectedBox(tester), 3);
  });

  testWidgets('数字が無いか7桁以上の貼り付けは、何もしない', (tester) async {
    await pump(tester);
    await type(tester, '12');

    await type(tester, 'abc');
    await type(tester, '090-1234-5678');

    expect(controller.text, '12');
    expect(selectedBox(tester), 2);
  });

  testWidgets('フォーカスが入ると、入力済みの1つ後ろのマスを選ぶ', (tester) async {
    controller.text = '123';
    await pump(tester);

    expect(selectedBox(tester), 3);
  });

  testWidgets('Enter で送る', (tester) async {
    await pump(tester);
    await type(tester, '123456');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, 1);
  });

  testWidgets('狭い幅でも、マスがはみ出さない', (tester) async {
    await pump(tester, width: 280);

    expect(tester.takeException(), isNull);
    final right = tester.getTopRight(find.byType(CodeField)).dx;
    final lastBox = tester
        .getTopRight(
          find
              .descendant(
                of: find.byType(CodeField),
                matching: find.byType(Container),
              )
              .last,
        )
        .dx;
    expect(lastBox, lessThanOrEqualTo(right));

    // 縮めても、押したマスを選べる
    await type(tester, '1234');
    final origin = tester.getTopLeft(find.byType(CodeField));
    final scale = 280 / CodeField.width;
    await tester.tapAt(origin + Offset((64 + 28) * scale, 20));
    await tester.pump();
    expect(selectedBox(tester), 1);
  });
}
