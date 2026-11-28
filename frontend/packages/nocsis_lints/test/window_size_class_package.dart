import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

/// frontend の WindowSizeClass と同じ場所に、同じ名前の enum を置く
void addWindowSizeClass(AnalysisRuleTest test) {
  test.newPackage('nocsis').addFile('lib/core/window_size_class.dart', '''
enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large;

  bool operator <(WindowSizeClass other) => index < other.index;
  bool operator >=(WindowSizeClass other) => index >= other.index;
}
''');
}
