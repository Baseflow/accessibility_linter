import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

import '../checker.dart';
import '../violation.dart';

class MissingPersistentInputLabelChecker extends A11yChecker {
  static const _inputWidgets = {'TextField', 'TextFormField'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    if (!_inputWidgets.contains(constructorTypeName(node))) return;
    if (_hasPersistentLabel(node)) return;
    violations.add(Violation(
      node,
      'missing_persistent_input_label',
      'Input widgets should expose a persistent label. Placeholders/hints '
          'alone are not sufficient because they disappear during entry.',
    ));
  }

  bool _hasPersistentLabel(InstanceCreationExpression node) {
    final decorationArg = getNamedArg(node, 'decoration');
    if (decorationArg == null || decorationArg.expression is NullLiteral) {
      return false;
    }
    return _decorationHasPersistentLabel(decorationArg.expression);
  }

  bool _decorationHasPersistentLabel(Expression expression) {
    if (expression is ParenthesizedExpression) {
      return _decorationHasPersistentLabel(expression.expression);
    }
    if (expression is InstanceCreationExpression) {
      if (constructorTypeName(expression) != 'InputDecoration') return false;
      return hasNamedNonNull(expression, 'labelText') ||
          hasNamedNonNull(expression, 'label');
    }
    return false;
  }
}
