import 'package:analyzer/dart/ast/ast.dart';

import '../shared/rule_spec.dart';
import '../utils/ast_utils.dart';

const missingFocusIndicatorSpec = RuleSpec(
  name: 'missing_focus_indicator',
  message: 'Interactive widgets should have a visible focus indicator. '
      'Provide a focusColor or a focusNode to ensure keyboard users can '
      'identify the focused element.',
  correctionMessage:
      'Add a focusColor argument or supply a FocusNode via the focusNode '
      'argument. For ElevatedButton, TextButton and OutlinedButton only '
      'focusNode is supported as a direct constructor parameter. '
      'Wrap with ExcludeSemantics if the widget is intentionally '
      'non-interactive.',
  onInstanceCreation: checkMissingFocusIndicator,
);

const _fullSupportWidgets = {
  'InkWell',
  'InkResponse',
  'IconButton',
  'FloatingActionButton',
  'CupertinoButton',
};
const _buttonStyleWidgets = {
  'ElevatedButton',
  'TextButton',
  'OutlinedButton',
};

void checkMissingFocusIndicator(
  InstanceCreationExpression node,
  void Function(AstNode) report,
) {
  final typeName = constructorTypeName(node);

  if (isWrappedWith(node, 'ExcludeSemantics')) return;

  if (_fullSupportWidgets.contains(typeName)) {
    if (hasNamedNonNull(node, 'focusColor') ||
        hasNamedNonNull(node, 'focusNode')) {
      return;
    }
    report(node);
    return;
  }

  if (_buttonStyleWidgets.contains(typeName)) {
    if (hasNamedNonNull(node, 'focusNode')) return;
    report(node);
    return;
  }

  if (typeName == 'GestureDetector') {
    if (!hasNamedNonNull(node, 'onTap')) return;
    report(node);
  }
}
