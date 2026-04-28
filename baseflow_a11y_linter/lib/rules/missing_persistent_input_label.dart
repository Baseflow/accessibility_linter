import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class MissingPersistentInputLabel extends DartLintRule {
  const MissingPersistentInputLabel() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_persistent_input_label',
    problemMessage:
        'Input widgets should expose a persistent label. Placeholders/hints '
        'alone are not sufficient because they disappear during entry.',
    correctionMessage:
        'Provide a persistent label using InputDecoration(labelText: "...") '
        'or InputDecoration(label: Text("...")).',
  );

  static const _inputWidgets = {'TextField', 'TextFormField'};

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;
      if (!_inputWidgets.contains(typeName)) return;

      if (_hasPersistentLabel(node)) return;

      reporter.atNode(node, _code);
    });
  }

  bool _hasPersistentLabel(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) continue;
      if (argument.name.label.name != 'decoration') continue;

      if (argument.expression is NullLiteral) return false;
      return _decorationHasPersistentLabel(argument.expression);
    }

    return false;
  }

  bool _decorationHasPersistentLabel(Expression expression) {
    if (expression is ParenthesizedExpression) {
      return _decorationHasPersistentLabel(expression.expression);
    }

    if (expression is InstanceCreationExpression) {
      final typeName = expression.constructorName.type.name.lexeme;
      if (typeName != 'InputDecoration') return false;

      return _inputDecorationHasLabel(expression);
    }

    return false;
  }

  bool _inputDecorationHasLabel(InstanceCreationExpression decoration) {
    for (final argument in decoration.argumentList.arguments) {
      if (argument is! NamedExpression) continue;

      final name = argument.name.label.name;
      if (name != 'labelText' && name != 'label') continue;

      if (argument.expression is NullLiteral) return false;
      return true;
    }

    return false;
  }
}
