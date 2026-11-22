import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/pages/console/displays/display_name.dart';

void main() {
  test('絵文字や濁点を合成した文字も1文字と数える', () {
    const family = '👨‍👩‍👧';
    const ga = 'が';

    expect(isValidDisplayName(family * 49 + ga), isTrue);
    expect(isValidDisplayName(family * 51), isFalse);
  });

  test('空白だけの名前は使えない', () {
    expect(isValidDisplayName('  '), isFalse);
  });
}
