import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/core/window_size_class.dart';

void main() {
  test('幅を M3 の境目で分ける', () {
    expect(WindowSizeClass.fromWidth(599), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(839), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
    expect(WindowSizeClass.fromWidth(1199), WindowSizeClass.expanded);
    expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
  });
}
