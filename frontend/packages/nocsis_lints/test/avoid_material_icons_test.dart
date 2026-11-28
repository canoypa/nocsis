// test_reflective_loader は test_ で始まるメソッドをテストとして拾う
// ignore_for_file: non_constant_identifier_names

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:nocsis_lints/src/avoid_material_icons.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidMaterialIconsTest);
  });
}

@reflectiveTest
class AvoidMaterialIconsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidMaterialIcons();
    newPackage('material_ui')
      ..addFile('lib/material_ui.dart', "export 'src/icons.dart';")
      ..addFile(
        'lib/src/icons.dart',
        'abstract final class Icons { static const int add = 0; }',
      );
    super.setUp();
  }

  void test_icons() async {
    await assertDiagnostics(
      r'''
import 'package:material_ui/material_ui.dart';

final icon = Icons.add;
''',
      [lint(61, 5)],
    );
  }

  void test_prefixed_import() async {
    await assertDiagnostics(
      r'''
import 'package:material_ui/material_ui.dart' as m;

final icon = m.Icons.add;
''',
      [lint(68, 5)],
    );
  }

  void test_other_class_named_icons() async {
    await assertNoDiagnostics(r'''
abstract final class Icons { static const int add = 0; }

final icon = Icons.add;
''');
  }
}
