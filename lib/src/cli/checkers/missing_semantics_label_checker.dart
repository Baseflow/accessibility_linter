import 'package:analyzer/dart/ast/ast.dart';

import '../checker.dart';
import '../violation.dart';
import '../../shared/missing_semantics_label_check.dart';

/// CLI checker for the `missing_semantics_label` rule.
class MissingSemanticsLabelChecker extends A11yChecker {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    checkMissingSemanticsLabel(
      node,
      (n) => violations.add(Violation(
        n,
        'missing_semantics_label',
        'Icon and Image widgets should have a semanticLabel, be wrapped with '
            'Semantics, or wrapped with ExcludeSemantics if decorative.',
      )),
    );
  }
}
