import 'package:analyzer/dart/ast/ast.dart';

import '../shared/a11y_rule.dart';

class OrientationLockRule extends A11yRule {
  @override
  String get name => 'orientation_lock';

  @override
  String get message =>
      'Locking device orientation is an accessibility issue and should be avoided.';

  @override
  String get correctionMessage =>
      'Remove the orientation lock and allow both orientations.';

  @override
  void checkMethodInvocation(
    MethodInvocation node,
    void Function(AstNode) report,
  ) {
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
    if (firstArg.elements.isEmpty) return;

    var hasPortrait = false;
    var hasLandscape = false;
    for (final element in firstArg.elements) {
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
      if (name == 'landscapeLeft' || name == 'landscapeRight')
        hasLandscape = true;
      if (hasPortrait && hasLandscape) break;
    }

    if (!(hasPortrait && hasLandscape)) {
      report(node);
    }
  }
}
