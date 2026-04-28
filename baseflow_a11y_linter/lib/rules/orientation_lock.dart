import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class OrientationLock extends DartLintRule {
  const OrientationLock() : super(code: _code);

  static const _code = LintCode(
    name: 'orientation_lock',
    problemMessage:
        'Locking device orientation is an accessibility issue and should be avoided.',
    correctionMessage:
        'Remove the orientation lock and allow both portrait and landscape orientations.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((MethodInvocation node) {
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

        final name = _identifierName(expr);
        if (name == null) continue;

        if (_isPortraitName(name)) hasPortrait = true;
        if (_isLandscapeName(name)) hasLandscape = true;
        if (hasPortrait && hasLandscape) break;
      }

      if (!(hasPortrait && hasLandscape)) {
        reporter.atNode(node, _code);
      }
    });
  }

  static String? _identifierName(Expression? expr) {
    if (expr is PrefixedIdentifier) return expr.identifier.name;
    if (expr is PropertyAccess) return expr.propertyName.name;
    if (expr is SimpleIdentifier) return expr.name;
    return null;
  }

  static bool _isPortraitName(String name) =>
      name == 'portraitUp' || name == 'portraitDown';

  static bool _isLandscapeName(String name) =>
      name == 'landscapeLeft' || name == 'landscapeRight';
}
