import 'package:analyzer/dart/ast/ast.dart';

import '../shared/a11y_rule.dart';
import '../utils/ast_utils.dart';

class MissingPersistentInputLabelRule extends A11yRule {
  @override
  String get name => 'missing_persistent_input_label';

  @override
  String get message =>
      'Input widgets should expose a persistent label. Placeholders/hints '
      'alone are not sufficient because they disappear during entry.';

  @override
  String get correctionMessage =>
      'Provide a persistent label using InputDecoration(labelText: "...") '
      'or InputDecoration(label: Text("...")).';

  @override
  void checkInstanceCreation(
    InstanceCreationExpression node,
    void Function(AstNode) report,
  ) {
    if (!_inputWidgets.contains(constructorTypeName(node))) return;
    if (_hasPersistentLabel(node)) return;
    report(node);
  }
}

const _inputWidgets = {'TextField', 'TextFormField'};

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
