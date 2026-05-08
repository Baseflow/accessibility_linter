import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/orientation_lock_check.dart';

class OrientationLockRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'orientation_lock',
    'Locking device orientation is an accessibility issue and should be avoided.',
    correctionMessage:
        'Remove the orientation lock and allow both orientations.',
  );

  OrientationLockRule()
      : super(
            name: 'orientation_lock',
            description: 'Warn on setPreferredOrientations');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addMethodInvocation(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final OrientationLockRule rule;
  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) =>
      checkOrientationLock(node, rule.reportAtNode);
}
