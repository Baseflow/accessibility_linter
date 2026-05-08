import 'package:analyzer/dart/ast/ast.dart';

import '../shared/rule_spec.dart';
import '../utils/ast_utils.dart';

const missingPersistentInputLabelSpec = RuleSpec(
  name: 'missing_persistent_input_label',
  message: 'Input widgets should expose a persistent label. Placeholders/hints '
      'alone are not sufficient because they disappear during entry.',
  correctionMessage:
      'Provide a persistent label using InputDecoration(labelText: "...") '
      'or InputDecoration(label: Text("...")).',
  onInstanceCreation: checkMissingPersistentInputLabel,
);

const _inputWidgets = {'TextField', 'TextFormField'};

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
