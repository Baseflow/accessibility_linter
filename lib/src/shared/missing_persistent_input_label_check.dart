import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

const _inputWidgets = {'TextField', 'TextFormField'};

/// Shared detection logic for the `missing_persistent_input_label` rule.
///
/// Calls [report] with the violating node when a [TextField] or [TextFormField]
/// does not have a persistent [InputDecoration.labelText] or
/// [InputDecoration.label].
void checkMissingPersistentInputLabel(
  InstanceCreationExpression node,
  void Function(AstNode) report,
) {
  if (!_inputWidgets.contains(constructorTypeName(node))) return;
  if (_hasPersistentLabel(node)) return;
  report(node);
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
