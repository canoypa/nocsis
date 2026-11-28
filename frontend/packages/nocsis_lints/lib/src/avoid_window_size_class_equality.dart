import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:nocsis_lints/src/window_size_class_type.dart';

class AvoidWindowSizeClassEquality extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_window_size_class_equality',
    'WindowSizeClass を == や != で比べると、区分が増えたときに意味が変わる。',
    correctionMessage: '>= .expanded や < .medium のように、その幅以上かどうかで比べる。',
  );

  AvoidWindowSizeClassEquality()
    : super(
        name: 'avoid_window_size_class_equality',
        description: 'WindowSizeClass は大小で比べる。',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addBinaryExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operator = node.operator.type;
    if (operator != TokenType.EQ_EQ && operator != TokenType.BANG_EQ) return;

    if (isWindowSizeClass(node.leftOperand.staticType) ||
        isWindowSizeClass(node.rightOperand.staticType)) {
      rule.reportAtNode(node);
    }
  }
}
