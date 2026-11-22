import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:nocsis_lints/src/avoid_material_icons.dart';
import 'package:nocsis_lints/src/avoid_show_dialog.dart';
import 'package:nocsis_lints/src/avoid_width_comparison.dart';
import 'package:nocsis_lints/src/avoid_window_size_class_constant_pattern.dart';
import 'package:nocsis_lints/src/avoid_window_size_class_equality.dart';

final plugin = NocsisLintsPlugin();

class NocsisLintsPlugin extends Plugin {
  @override
  String get name => 'nocsis_lints';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(AvoidMaterialIcons());
    registry.registerWarningRule(AvoidShowDialog());
    registry.registerWarningRule(AvoidWidthComparison());
    registry.registerWarningRule(AvoidWindowSizeClassEquality());
    registry.registerWarningRule(AvoidWindowSizeClassConstantPattern());
  }
}
