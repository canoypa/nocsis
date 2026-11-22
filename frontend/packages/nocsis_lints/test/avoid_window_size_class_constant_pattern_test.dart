// test_reflective_loader は test_ で始まるメソッドをテストとして拾う
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:nocsis_lints/src/avoid_window_size_class_constant_pattern.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'window_size_class_package.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWindowSizeClassConstantPatternTest);
  });
}

@reflectiveTest
class AvoidWindowSizeClassConstantPatternTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidWindowSizeClassConstantPattern();
    addWindowSizeClass(this);
    super.setUp();
  }

  void test_switch_by_name() async {
    await assertDiagnostics(
      r'''
import 'package:nocsis/core/window_size_class.dart';

int f(WindowSizeClass c) => switch (c) {
  .compact => 0,
  .medium || .expanded => 1,
  WindowSizeClass.large => 2,
};
''',
      [lint(97, 8), lint(114, 7), lint(125, 9), lint(143, 21)],
    );
  }

  void test_if_case() async {
    await assertDiagnostics(
      r'''
import 'package:nocsis/core/window_size_class.dart';

bool f(WindowSizeClass c) {
  if (c case .compact) return true;
  return false;
}
''',
      [lint(95, 8)],
    );
  }

  void test_relational() async {
    await assertNoDiagnostics(r'''
import 'package:nocsis/core/window_size_class.dart';

int f(WindowSizeClass c) => switch (c) {
  >= .large => 2,
  >= .medium => 1,
  _ => 0,
};
''');
  }
}
