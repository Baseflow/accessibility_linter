import 'package:analyzer/dart/ast/ast.dart';

import '../shared/a11y_rule.dart';
import '../utils/ast_utils.dart';

class InsufficientTapTargetSizeRule extends A11yRule {
  @override
  String get name => 'insufficient_tap_target_size';

  @override
  String get message => 'Tappable widget has an insufficient tap target size. '
      'WCAG 2.5.8 requires a minimum of 24x24 logical pixels.';

  @override
  String get correctionMessage =>
      'Ensure the tappable widget is at least 24x24 logical pixels. '
      'Use SizedBox(width: 24, height: 24, child: ...) or ensure the '
      'widget style does not override the minimum size below 24x24.';

  @override
  void checkInstanceCreation(
    InstanceCreationExpression node,
    void Function(AstNode) report,
  ) {
    if (!_tappableWidgets.contains(constructorTypeName(node))) return;

    if (_isWrappedInShrinkBox(node) ||
        _hasInsufficientSizingAncestor(node) ||
        _hasInsufficientMinimumSizeInStyle(node)) {
      report(node);
    }
  }
}

const _minTapSize = 24.0;
const _tappableWidgets = {
  'GestureDetector',
  'InkWell',
  'InkResponse',
  'TextButton',
  'ElevatedButton',
  'OutlinedButton',
  'FilledButton',
  'IconButton',
  'FloatingActionButton',
  'ExtendedFloatingActionButton',
};
const _sizingWidgets = {'SizedBox', 'Container'};

bool _isWrappedInShrinkBox(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression) {
      final name = constructorTypeName(current);
      final ctor = current.constructorName.name?.name;
      if (name == 'SizedBox' && ctor == 'shrink') return true;
      if (_sizingWidgets.contains(name)) break;
    }
    current = current.parent;
  }
  return false;
}

bool _hasInsufficientSizingAncestor(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is InstanceCreationExpression) {
      final name = constructorTypeName(current);
      if (_sizingWidgets.contains(name)) {
        final width = _getNamedDoubleArg(current, 'width');
        final height = _getNamedDoubleArg(current, 'height');
        final widthViolation = width != null && width < _minTapSize;
        final heightViolation = height != null && height < _minTapSize;
        if (widthViolation || heightViolation) return true;
        if (width != null || height != null) break;
      }
    }
    current = current.parent;
  }
  return false;
}

bool _hasInsufficientMinimumSizeInStyle(InstanceCreationExpression node) {
  final styleArg = getNamedArg(node, 'style');
  if (styleArg == null) return false;
  final styleExpr = styleArg.expression;
  if (styleExpr is! InstanceCreationExpression) return false;
  if (constructorTypeName(styleExpr) != 'ButtonStyle') return false;

  for (final sa in styleExpr.argumentList.arguments) {
    if (sa is! NamedExpression) continue;
    if (sa.name.label.name != 'minimumSize') continue;
    final minSizeExpr = sa.expression;
    if (minSizeExpr is! InstanceCreationExpression) continue;
    final minSizeTypeName = constructorTypeName(minSizeExpr);
    if (minSizeTypeName != 'WidgetStatePropertyAll' &&
        minSizeTypeName != 'MaterialStatePropertyAll') continue;
    final args = minSizeExpr.argumentList.arguments;
    if (args.isEmpty) continue;
    final sizeArg = args.first;
    if (sizeArg is! InstanceCreationExpression) continue;
    if (constructorTypeName(sizeArg) != 'Size') continue;
    final positional = sizeArg.argumentList.arguments
        .whereType<Expression>()
        .where((e) => e is! NamedExpression)
        .toList();
    if (positional.length < 2) continue;
    final w = _toDouble(positional[0]);
    final h = _toDouble(positional[1]);
    if ((w != null && w < _minTapSize) || (h != null && h < _minTapSize)) {
      return true;
    }
  }
  return false;
}

double? _getNamedDoubleArg(InstanceCreationExpression node, String argName) {
  final arg = getNamedArg(node, argName);
  return arg != null ? _toDouble(arg.expression) : null;
}

double? _toDouble(Expression expr) {
  if (expr is IntegerLiteral) return expr.value?.toDouble();
  if (expr is DoubleLiteral) return expr.value;
  if (expr is PrefixExpression && expr.operator.lexeme == '-') {
    final operand = _toDouble(expr.operand);
    if (operand != null) return -operand;
  }
  return null;
}
