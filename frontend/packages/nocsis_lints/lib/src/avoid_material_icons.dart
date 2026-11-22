import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:nocsis_lints/src/flutter_element.dart';

class AvoidMaterialIcons extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_material_icons',
    'Icons ではなく Material Symbols を使う。',
    correctionMessage:
        "package:material_symbols_icons/symbols.dart の Symbols に置き換える。",
  );

  AvoidMaterialIcons()
    : super(
        name: 'avoid_material_icons',
        description: 'アイコンは Material Symbols にそろえる。',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addSimpleIdentifier(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final element = node.element;
    if (element is ClassElement &&
        element.name == 'Icons' &&
        isFromFlutter(element)) {
      rule.reportAtNode(node);
    }
  }
}
