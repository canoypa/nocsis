import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:nocsis_lints/src/window_size_class_type.dart';

class AvoidWindowSizeClassConstantPattern extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_window_size_class_constant_pattern',
    'WindowSizeClass を区分の名前で振り分けると、区分が増えたときに意味が変わる。',
    correctionMessage:
        '>= .large => …, >= .medium => …, _ => … のように、大きい方から幅の下限で振り分ける。',
  );

  AvoidWindowSizeClassConstantPattern()
    : super(
        name: 'avoid_window_size_class_constant_pattern',
        description: 'WindowSizeClass は幅の下限で振り分ける。',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addConstantPattern(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitConstantPattern(ConstantPattern node) {
    if (isWindowSizeClass(node.expression.staticType)) {
      rule.reportAtNode(node);
    }
  }
}
