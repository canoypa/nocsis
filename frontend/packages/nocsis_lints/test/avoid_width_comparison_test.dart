// test_reflective_loader は test_ で始まるメソッドをテストとして拾う
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:nocsis_lints/src/avoid_width_comparison.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidWidthComparisonTest);
    defineReflectiveTests(AvoidWidthComparisonSizeTest);
  });
}

@reflectiveTest
class AvoidWidthComparisonTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidWidthComparison();
    newPackage('flutter')
      ..addFile('lib/rendering.dart', "export 'src/box.dart';")
      ..addFile('lib/src/box.dart', '''
class BoxConstraints {
  final double minWidth = 0;
  final double maxWidth = 0;
  final double maxHeight = 0;
}
''');
    super.setUp();
  }

  void test_box_constraints_width() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/rendering.dart';

bool f(BoxConstraints c) => c.maxWidth >= 1200;
''',
      [lint(70, 18)],
    );
  }

  void test_height() async {
    await assertNoDiagnostics(r'''
import 'package:flutter/rendering.dart';

bool f(BoxConstraints c) => c.maxHeight < 600;
''');
  }

  void test_own_class_width() async {
    await assertNoDiagnostics(r'''
class Size {
  final double width = 0;
}

bool f(Size size) => size.width < 600;
''');
  }

  void test_plain_number() async {
    await assertNoDiagnostics(r'''
bool f(double width) => width < 600;
''');
  }
}

/// Size は dart:ui にあるので、テストでも Flutter の SDK を模したものを読む
@reflectiveTest
class AvoidWidthComparisonSizeTest extends AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    rule = AvoidWidthComparison();
    super.setUp();
  }

  void test_size_width() async {
    await assertDiagnostics(
      r'''
import 'dart:ui';

bool f(Size size) => size.width < 600;
''',
      [lint(40, 16)],
    );
  }

  void test_size_width_from_call() async {
    await assertDiagnostics(
      r'''
import 'dart:ui';

Size g() => const Size(0, 0);

bool f() => 1200 <= g().width;
''',
      [lint(62, 17)],
    );
  }
}
