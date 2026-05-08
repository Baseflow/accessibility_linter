import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/missing_persistent_input_label_check.dart';

/// CLI checker for the `missing_persistent_input_label` rule.
class MissingPersistentInputLabelChecker extends A11yChecker {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    checkMissingPersistentInputLabel(
      node,
      (n) => violations.add(Violation(
        n,
        'missing_persistent_input_label',
        'Input widgets should expose a persistent label. Placeholders/hints '
            'alone are not sufficient because they disappear during entry.',
      )),
    );
  }
}
