import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

import '../checker.dart';
import '../violation.dart';

class MissingFocusIndicatorChecker extends A11yChecker {
  static const _fullSupportWidgets = {
    'InkWell',
    'InkResponse',
    'IconButton',
    'FloatingActionButton',
    'CupertinoButton',
  };
  static const _buttonStyleWidgets = {
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
  };

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    final typeName = constructorTypeName(node);

    if (isWrappedWith(node, 'ExcludeSemantics')) return;

    if (_fullSupportWidgets.contains(typeName)) {
      if (hasNamedNonNull(node, 'focusColor') ||
          hasNamedNonNull(node, 'focusNode')) {
        return;
      }
      violations.add(Violation(
        node,
        'missing_focus_indicator',
        'Interactive widgets should have a visible focus indicator.',
      ));
      return;
    }

    if (_buttonStyleWidgets.contains(typeName)) {
      if (hasNamedNonNull(node, 'focusNode')) return;
      violations.add(Violation(
        node,
        'missing_focus_indicator',
        'Interactive widgets should have a visible focus indicator.',
      ));
      return;
    }

    if (typeName == 'GestureDetector') {
      if (!hasNamedNonNull(node, 'onTap')) return;
      violations.add(Violation(
        node,
        'missing_focus_indicator',
        'Interactive widgets should have a visible focus indicator.',
      ));
    }
  }
}
