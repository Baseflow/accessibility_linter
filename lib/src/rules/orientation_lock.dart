import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

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
    registry.addMethodInvocation(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final OrientationLockRule rule;
  final RuleContext context;
  _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'setPreferredOrientations') return;
    final targetExpr = node.target;
    String? targetName;
    if (targetExpr is SimpleIdentifier) {
      targetName = targetExpr.name;
    } else if (targetExpr is PrefixedIdentifier) {
      targetName = targetExpr.identifier.name;
    } else if (targetExpr is PropertyAccess) {
      targetName = targetExpr.propertyName.name;
    }
    if (targetName != 'SystemChrome') return;
    if (node.argumentList.arguments.isEmpty) return;
    final firstArg = node.argumentList.arguments.first;
    if (firstArg is! ListLiteral) return;
    final list = firstArg;
    if (list.elements.isEmpty) return;

    var hasPortrait = false;
    var hasLandscape = false;
    for (final element in list.elements) {
      Expression? expr;
      if (element is Expression) {
        expr = element;
      } else if (element is SpreadElement) {
        expr = element.expression;
      } else {
        continue;
      }
      String? name;
      if (expr is PrefixedIdentifier) name = expr.identifier.name;
      if (expr is PropertyAccess) name = expr.propertyName.name;
      if (expr is SimpleIdentifier) name = expr.name;
      if (name == null) continue;
      if (name == 'portraitUp' || name == 'portraitDown') hasPortrait = true;
      if (name == 'landscapeLeft' || name == 'landscapeRight') {
        hasLandscape = true;
      }
      if (hasPortrait && hasLandscape) break;
    }

    if (!(hasPortrait && hasLandscape)) {
      rule.reportAtNode(node);
    }
  }
}
