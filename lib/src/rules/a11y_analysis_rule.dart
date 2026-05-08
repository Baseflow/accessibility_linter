import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/a11y_rule.dart';

class A11yAnalysisRule extends AnalysisRule {
  final A11yRule rule;
  late final LintCode _code;

  A11yAnalysisRule(this.rule)
      : super(name: rule.name, description: rule.message) {
    _code = LintCode(
      rule.name,
      rule.message,
      correctionMessage: rule.correctionMessage,
    );
  }

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(
        this, _InstanceCreationVisitor(this, rule));
    registry.addMethodInvocation(this, _MethodInvocationVisitor(this, rule));
  }
}

class _InstanceCreationVisitor extends SimpleAstVisitor<void> {
  final A11yAnalysisRule analysisRule;
  final A11yRule rule;
  _InstanceCreationVisitor(this.analysisRule, this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      rule.checkInstanceCreation(node, analysisRule.reportAtNode);
}

class _MethodInvocationVisitor extends SimpleAstVisitor<void> {
  final A11yAnalysisRule analysisRule;
  final A11yRule rule;
  _MethodInvocationVisitor(this.analysisRule, this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) =>
      rule.checkMethodInvocation(node, analysisRule.reportAtNode);
}
