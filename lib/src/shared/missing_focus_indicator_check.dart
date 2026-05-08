import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

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

/// Shared detection logic for the `missing_focus_indicator` rule.
///
/// Calls [report] with the violating node when an interactive widget does not
/// provide a visible focus indicator via [focusColor] or [focusNode].
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
