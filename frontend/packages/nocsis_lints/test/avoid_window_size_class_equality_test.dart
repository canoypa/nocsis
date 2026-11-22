// test_reflective_loader は test_ で始まるメソッドをテストとして拾う
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:nocsis_lints/src/avoid_window_size_class_equality.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'window_size_class_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWindowSizeClassEqualityTest);
  });
}

@reflectiveTest
class AvoidWindowSizeClassEqualityTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidWindowSizeClassEquality();
    addWindowSizeClass(this);
    super.setUp();
  }

  void test_equal() async {
    await assertDiagnostics(
      r'''
import 'package:nocsis/core/window_size_class.dart';

bool f(WindowSizeClass c) => c == .compact;
''',
      [lint(83, 13)],
    );
  }

  void test_not_equal() async {
    await assertDiagnostics(
      r'''
import 'package:nocsis/core/window_size_class.dart';

bool f(WindowSizeClass c) => c != WindowSizeClass.large;
''',
      [lint(83, 26)],
    );
  }

  void test_at_least() async {
    await assertNoDiagnostics(r'''
import 'package:nocsis/core/window_size_class.dart';

bool f(WindowSizeClass c) => c >= .expanded || c < .medium;
''');
  }

  void test_own_enum() async {
    await assertNoDiagnostics(r'''
enum WindowSizeClass { compact }

bool f(WindowSizeClass c) => c == .compact;
''');
  }
}
