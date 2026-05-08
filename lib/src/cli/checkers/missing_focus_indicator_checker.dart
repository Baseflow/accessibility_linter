import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/missing_focus_indicator_check.dart';

/// CLI checker for the `missing_focus_indicator` rule.
class MissingFocusIndicatorChecker extends A11yChecker {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    checkMissingFocusIndicator(
      node,
      (n) => violations.add(Violation(
        n,
        'missing_focus_indicator',
        'Interactive widgets should have a visible focus indicator.',
      )),
    );
  }
}
