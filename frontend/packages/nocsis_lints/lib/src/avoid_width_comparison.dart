import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:nocsis_lints/src/flutter_element.dart';

class AvoidWidthComparison extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_width_comparison',
    '幅を数値と比べて、画面ごとに境目を決めている。',
    correctionMessage:
        'context.windowSizeClass か WindowSizeClass.fromWidth で幅を分ける。',
  );

  static const _comparisons = {
    TokenType.LT,
    TokenType.LT_EQ,
    TokenType.GT,
    TokenType.GT_EQ,
  };

  static const _properties = {'width', 'minWidth', 'maxWidth'};

  /// Size は dart:ui、BoxConstraints は flutter にある
  static const _types = {'Size', 'BoxConstraints'};

  AvoidWidthComparison()
    : super(
        name: 'avoid_width_comparison',
        description: '幅の境目は WindowSizeClass で決める。',
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
    if (!AvoidWidthComparison._comparisons.contains(node.operator.type)) {
      return;
    }
    if (_isWidth(node.leftOperand) || _isWidth(node.rightOperand)) {
      rule.reportAtNode(node);
    }
  }

  bool _isWidth(Expression expression) {
    final (target, name) = switch (expression) {
      PropertyAccess(:final target?, :final propertyName) => (
        target.staticType,
        propertyName.name,
      ),
      PrefixedIdentifier(:final prefix, :final identifier) => (
        prefix.staticType,
        identifier.name,
      ),
      _ => (null, null),
    };
    if (target is! InterfaceType ||
        !AvoidWidthComparison._properties.contains(name)) {
      return false;
    }
    final element = target.element;
    return AvoidWidthComparison._types.contains(element.name) &&
        (isFromFlutter(element) || element.library.uri.toString() == 'dart:ui');
  }
}
