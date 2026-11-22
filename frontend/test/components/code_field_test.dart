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

    // 3マス目の真ん中
    final origin = tester.getTopLeft(find.byType(CodeField));
    await tester.tapAt(origin + const Offset(56 + 8 + 56 + 8 + 28, 32));
    await tester.pump();
    expect(controller.selection, const TextSelection.collapsed(offset: 2));

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '1293456',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();

    expect(controller.text, '129456');
    expect(controller.selection, const TextSelection.collapsed(offset: 3));
  });
}
