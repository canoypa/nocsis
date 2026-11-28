import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart';
import 'package:nocsis_lints/src/flutter_element.dart';

class AvoidShowDialog extends AnalysisRule {
  static const LintCode code = LintCode(
    'avoid_show_dialog',
    '{0} で開いたダイアログは、ブラウザの戻るで閉じない。',
    correctionMessage: 'ダイアログを DialogPage の子ルートにして push で開き、closeDialog で閉じる。',
  );

  static const _functions = {
    'showDialog',
    'showAdaptiveDialog',
    'showGeneralDialog',
    'showCupertinoDialog',
  };

  AvoidShowDialog()
    : super(name: 'avoid_show_dialog', description: 'ダイアログはルートにして push で開く。');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;
    if (element is! TopLevelFunctionElement) return;

    if (AvoidShowDialog._functions.contains(element.name) &&
        isFromFlutter(element)) {
      rule.reportAtNode(node.methodName, arguments: [element.name!]);
    }
  }
}
