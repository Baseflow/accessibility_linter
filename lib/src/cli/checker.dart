import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../shared/all_rules.dart';
import 'violation.dart';

class A11yChecker extends RecursiveAstVisitor<void> {
  final List<Violation> violations = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    for (final rule in allRules) {
      rule.checkInstanceCreation(
        node,
        (n) => violations.add(Violation(n, rule.name, rule.message)),
      );
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    for (final rule in allRules) {
      rule.checkMethodInvocation(
        node,
        (n) => violations.add(Violation(n, rule.name, rule.message)),
      );
    }
  }
}
