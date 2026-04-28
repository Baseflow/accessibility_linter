import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class MissingSemanticsLabel extends DartLintRule {
  const MissingSemanticsLabel() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_semantics_label',
    problemMessage:
        'Icon and Image widgets should have a semanticLabel, be wrapped '
        'with Semantics, or wrapped with ExcludeSemantics if decorative. '
        'Clickable widgets (e.g. IconButton, FloatingActionButton) that use '
        'icon-only content should provide a tooltip or ensure the icon has '
        'an accessible label.',
    correctionMessage:
        'Add a semanticLabel argument, provide a tooltip on the clickable '
        'widget, wrap with Semantics(label: "..."), or wrap with '
        'ExcludeSemantics if decorative.',
  );

  static const _targetWidgets = {'Icon', 'Image', 'ImageIcon'};

  static const _clickableWidgets = {
    'IconButton',
    'FloatingActionButton',
    'ElevatedButton',
    'OutlinedButton'
  };

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name2.lexeme;
      if (_targetWidgets.contains(typeName)) {
        if (_hasSemanticLabelArgument(node)) return;

        if (_isWrappedWithSemantics(node)) return;

        if (_hasClickableAncestorWithTooltipOrIconLabel(node)) return;

        reporter.atNode(node, _code);
        return;
      }

      if (_clickableWidgets.contains(typeName)) {
        if (_hasTooltipArgument(node)) return;
        if (_isWrappedWithSemantics(node)) return;
        if (_hasIconChildWithSemanticLabel(node)) return;

        reporter.atNode(node, _code);
      }
    });
  }

  bool _hasSemanticLabelArgument(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == 'semanticLabel') {
        if (argument.expression is NullLiteral) return false;
        return true;
      }
    }
    return false;
  }

  bool _isWrappedWithSemantics(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final name = current.constructorName.type.name2.lexeme;

        if (name == 'ExcludeSemantics') return true;

        if (name == 'Semantics') {
          for (final arg in current.argumentList.arguments) {
            if (arg is NamedExpression &&
                arg.name.label.name == 'label' &&
                arg.expression is! NullLiteral) {
              return true;
            }
          }
        }
      }
      current = current.parent;
    }
    return false;
  }

  bool _hasTooltipArgument(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression &&
          argument.name.label.name == 'tooltip') {
        if (argument.expression is NullLiteral) return false;
        return true;
      }
    }
    return false;
  }

  bool _hasIconChildWithSemanticLabel(InstanceCreationExpression node) {
    const candidateNames = ['icon', 'child', 'label'];

    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression &&
          candidateNames.contains(arg.name.label.name)) {
        final expr = arg.expression;
        if (_subtreeHasSemanticLabelOrDecorative(expr)) return true;
      }
    }
    return false;
  }

  bool _subtreeHasSemanticLabelOrDecorative(AstNode? node) {
    if (node == null) return false;
    final stack = <AstNode>[node];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current is InstanceCreationExpression) {
        final name = current.constructorName.type.name2.lexeme;

        if (name == 'ExcludeSemantics') return true;

        if (name == 'Semantics') {
          for (final arg in current.argumentList.arguments) {
            if (arg is NamedExpression &&
                arg.name.label.name == 'label' &&
                arg.expression is! NullLiteral) {
              return true;
            }
          }
        }

        if (_targetWidgets.contains(name)) {
          if (_hasSemanticLabelArgument(current)) return true;
        }

        for (final arg in current.argumentList.arguments) {
          if (arg is NamedExpression) {
            stack.add(arg.expression);
          } else {
            stack.add(arg);
          }
        }
      } else if (current is NamedExpression) {
        stack.add(current.expression);
      }
    }
    return false;
  }

  bool _hasClickableAncestorWithTooltipOrIconLabel(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final name = current.constructorName.type.name2.lexeme;
        if (_clickableWidgets.contains(name)) {
          if (_hasTooltipArgument(current)) return true;
          if (_hasIconChildWithSemanticLabel(current)) return true;
        }
      }
      current = current.parent;
    }
    return false;
  }
}
