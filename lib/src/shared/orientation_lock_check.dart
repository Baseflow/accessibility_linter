import 'package:analyzer/dart/ast/ast.dart';

/// Shared detection logic for the `orientation_lock` rule.
///
/// Calls [report] with the violating [MethodInvocation] node when
/// [SystemChrome.setPreferredOrientations] is called with a list that does not
/// include both portrait and landscape orientations.
void checkOrientationLock(
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
