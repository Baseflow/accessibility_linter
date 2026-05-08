import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

const _targetWidgets = {'Icon', 'Image', 'ImageIcon'};
const _clickableWidgets = {
  'IconButton',
  'FloatingActionButton',
  'ElevatedButton',
  'OutlinedButton',
};

/// Shared detection logic for the `missing_semantics_label` rule.
///
/// Calls [report] with the violating node when an [Icon], [Image], or
/// [ImageIcon] lacks a semantic label, or when a clickable icon-only widget
/// lacks a tooltip or accessible icon label.
void checkMissingSemanticsLabel(
  InstanceCreationExpression node,
  void Function(AstNode) report,
) {
  final typeName = constructorTypeName(node);

  if (_targetWidgets.contains(typeName)) {
    if (hasNamedNonNull(node, 'semanticLabel')) return;
    if (_isWrappedWithSemantics(node)) return;
    if (_hasClickableAncestorWithTooltipOrIconLabel(node)) return;
    report(node);
    return;
  }

  if (_clickableWidgets.contains(typeName)) {
    if (hasNamedNonNull(node, 'tooltip')) return;
    if (_isWrappedWithSemantics(node)) return;
    if (_hasIconChildWithSemanticLabel(node)) return;
    report(node);
  }
}

bool _isWrappedWithSemantics(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression) {
      final name = constructorTypeName(current);
      if (name == 'ExcludeSemantics') return true;
      if (name == 'Semantics' && hasNamedNonNull(current, 'label')) return true;
    }
    current = current.parent;
  }
  return false;
}

bool _hasIconChildWithSemanticLabel(InstanceCreationExpression node) {
  const candidateNames = ['icon', 'child', 'label'];
  for (final arg in node.argumentList.arguments) {
    if (arg is NamedExpression &&
        candidateNames.contains(arg.name.label.name)) {
      if (_subtreeHasSemanticLabelOrDecorative(arg.expression)) return true;
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
      final name = constructorTypeName(current);
      if (name == 'ExcludeSemantics') return true;
      if (name == 'Semantics' && hasNamedNonNull(current, 'label')) return true;
      if (_targetWidgets.contains(name) &&
          hasNamedNonNull(current, 'semanticLabel')) {
        return true;
      }
      for (final arg in current.argumentList.arguments) {
        stack.add(arg is NamedExpression ? arg.expression : arg);
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
      final name = constructorTypeName(current);
      if (_clickableWidgets.contains(name)) {
        if (hasNamedNonNull(current, 'tooltip')) return true;
        if (_hasIconChildWithSemanticLabel(current)) return true;
      }
    }
    current = current.parent;
  }
  return false;
}
