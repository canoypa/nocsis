// test_reflective_loader は test_ で始まるメソッドをテストとして拾う
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:nocsis_lints/src/avoid_show_dialog.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidShowDialogTest);
  });
}

@reflectiveTest
class AvoidShowDialogTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidShowDialog();
    newPackage('material_ui')
      ..addFile('lib/material_ui.dart', "export 'src/dialog.dart';")
      ..addFile('lib/src/dialog.dart', '''
void showDialog() {}
void showAdaptiveDialog() {}
''');
    newPackage('flutter')
      ..addFile('lib/widgets.dart', "export 'src/widgets/routes.dart';")
      ..addFile('lib/src/widgets/routes.dart', 'void showGeneralDialog() {}');
    newPackage('cupertino_ui')
      ..addFile('lib/cupertino_ui.dart', "export 'src/route.dart';")
      ..addFile('lib/src/route.dart', 'void showCupertinoDialog() {}');
    super.setUp();
  }

  void test_show_dialog() async {
    await assertDiagnostics(
      r'''
import 'package:material_ui/material_ui.dart';

void f() => showDialog();
''',
      [
        lint(60, 10, messageContainsAll: ['showDialog']),
      ],
    );
  }

  void test_show_adaptive_dialog() async {
    await assertDiagnostics(
      r'''
import 'package:material_ui/material_ui.dart';

void f() => showAdaptiveDialog();
''',
      [lint(60, 18)],
    );
  }

  void test_show_general_dialog() async {
    await assertDiagnostics(
      r'''
import 'package:flutter/widgets.dart';

void f() => showGeneralDialog();
''',
      [lint(52, 17)],
    );
  }

  void test_show_cupertino_dialog() async {
    await assertDiagnostics(
      r'''
import 'package:cupertino_ui/cupertino_ui.dart';

void f() => showCupertinoDialog();
''',
      [lint(62, 19)],
    );
  }

  void test_own_function_named_show_dialog() async {
    await assertNoDiagnostics(r'''
void showDialog() {}

void f() => showDialog();
''');
  }
}
