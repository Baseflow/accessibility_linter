import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/insufficient_tap_target_size_check.dart';

/// CLI checker for the `insufficient_tap_target_size` rule.
class InsufficientTapTargetSizeChecker extends A11yChecker {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    checkInsufficientTapTargetSize(
      node,
      (n) => violations.add(Violation(
        n,
        'insufficient_tap_target_size',
        'Tappable widget has an insufficient tap target size. '
            'WCAG 2.5.8 requires a minimum of 24x24 logical pixels.',
      )),
    );
  }
}
