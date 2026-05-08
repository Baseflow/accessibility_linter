import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/insufficient_color_contrast_check.dart';

/// CLI checker for the `insufficient_color_contrast` rule.
class InsufficientColorContrastChecker extends A11yChecker {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    checkInsufficientColorContrast(
      node,
      (n) => violations.add(Violation(
        n,
        'insufficient_color_contrast',
        'The color contrast ratio between the foreground and background is '
            'below the WCAG AA minimum.',
      )),
    );
  }
}
