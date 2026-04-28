import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class MissingFocusIndicator extends DartLintRule {
  const MissingFocusIndicator() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_focus_indicator',
    problemMessage:
        'Interactive widgets should have a visible focus indicator. '
        'Provide a focusColor or a focusNode to ensure keyboard users can '
        'identify the focused element.',
    correctionMessage:
        'Add a focusColor argument or supply a FocusNode via the focusNode '
        'argument. For ElevatedButton, TextButton and OutlinedButton only '
        'focusNode is supported as a direct constructor parameter. '
        'Wrap with ExcludeSemantics if the widget is intentionally '
        'non-interactive.',
  );

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
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;

      if (_isWrappedWithExcludeSemantics(node)) return;

      if (_fullSupportWidgets.contains(typeName)) {
        if (_hasFocusColor(node) || _hasFocusNode(node)) return;
        reporter.atNode(node, _code);
        return;
      }

      if (_buttonStyleWidgets.contains(typeName)) {
        if (_hasFocusNode(node)) return;
        reporter.atNode(node, _code);
        return;
      }

      if (typeName == 'GestureDetector') {
        if (!_hasOnTap(node)) return;
        reporter.atNode(node, _code);
      }
    });
  }

  bool _hasFocusColor(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == 'focusColor') {
        if (argument.expression is NullLiteral) return false;
        return true;
      }
    }
    return false;
  }

  bool _hasFocusNode(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == 'focusNode') {
        if (argument.expression is NullLiteral) return false;
        return true;
      }
    }
    return false;
  }

  bool _hasOnTap(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression && argument.name.label.name == 'onTap') {
        if (argument.expression is NullLiteral) return false;
        return true;
      }
    }
    return false;
  }

  bool _isWrappedWithExcludeSemantics(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final name = current.constructorName.type.name.lexeme;
        if (name == 'ExcludeSemantics') return true;
      }
      current = current.parent;
    }
    return false;
  }
}
