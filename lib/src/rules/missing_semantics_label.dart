import 'package:analyzer/dart/ast/ast.dart';

import '../shared/rule_spec.dart';
import '../utils/ast_utils.dart';

const missingSemanticsLabelSpec = RuleSpec(
  name: 'missing_semantics_label',
  message: 'Icon and Image widgets should have a semanticLabel, be wrapped '
      'with Semantics, or wrapped with ExcludeSemantics if decorative. '
      'Clickable widgets (e.g. IconButton, FloatingActionButton) that use '
      'icon-only content should provide a tooltip or ensure the icon has '
      'an accessible label.',
  correctionMessage:
      'Add a semanticLabel argument, provide a tooltip on the clickable '
      'widget, wrap with Semantics(label: "..."), or wrap with '
      'ExcludeSemantics if decorative.',
  onInstanceCreation: checkMissingSemanticsLabel,
);

const _targetWidgets = {'Icon', 'Image', 'ImageIcon'};
const _clickableWidgets = {
  'IconButton',
  'FloatingActionButton',
  'ElevatedButton',
  'OutlinedButton',
};

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
