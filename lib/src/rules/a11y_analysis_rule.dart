import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/rule_spec.dart';

class A11yAnalysisRule extends AnalysisRule {
  final RuleSpec spec;
  late final LintCode _code;

  A11yAnalysisRule(this.spec)
      : super(name: spec.name, description: spec.message) {
    _code = LintCode(
      spec.name,
      spec.message,
      correctionMessage: spec.correctionMessage,
    );
  }

  @override
  LintCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    if (spec.onInstanceCreation != null) {
      registry.addInstanceCreationExpression(
          this, _InstanceCreationVisitor(this, spec));
    }
    if (spec.onMethodInvocation != null) {
      registry.addMethodInvocation(this, _MethodInvocationVisitor(this, spec));
    }
  }
}

class _InstanceCreationVisitor extends SimpleAstVisitor<void> {
  final A11yAnalysisRule rule;
  final RuleSpec spec;
  _InstanceCreationVisitor(this.rule, this.spec);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      spec.onInstanceCreation!(node, rule.reportAtNode);
}

class _MethodInvocationVisitor extends SimpleAstVisitor<void> {
  final A11yAnalysisRule rule;
  final RuleSpec spec;
  _MethodInvocationVisitor(this.rule, this.spec);

  @override
  void visitMethodInvocation(MethodInvocation node) =>
      spec.onMethodInvocation!(node, rule.reportAtNode);
}
