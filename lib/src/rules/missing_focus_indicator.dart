import 'package:analyzer/dart/ast/ast.dart';

import '../shared/a11y_rule.dart';
import '../utils/ast_utils.dart';

class MissingFocusIndicatorRule extends A11yRule {
  @override
  String get name => 'missing_focus_indicator';

  @override
  String get message =>
      'Interactive widgets should have a visible focus indicator. '
      'Provide a focusColor or a focusNode to ensure keyboard users can '
      'identify the focused element.';

  @override
  String get correctionMessage =>
      'Add a focusColor argument or supply a FocusNode via the focusNode '
      'argument. For ElevatedButton, TextButton and OutlinedButton only '
      'focusNode is supported as a direct constructor parameter. '
      'Wrap with ExcludeSemantics if the widget is intentionally '
      'non-interactive.';

  @override
  void checkInstanceCreation(
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
}

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
