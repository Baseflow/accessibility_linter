import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_utils.dart';

class InsufficientTapTargetSizeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'insufficient_tap_target_size',
    'Tappable widget has an insufficient tap target size. '
        'WCAG 2.5.8 requires a minimum of 24x24 logical pixels.',
    correctionMessage:
        'Ensure the tappable widget is at least 24x24 logical pixels. '
        'Use SizedBox(width: 24, height: 24, child: ...) or ensure the '
        'widget style does not override the minimum size below 24x24.',
  );

  InsufficientTapTargetSizeRule()
      : super(
            name: 'insufficient_tap_target_size',
            description:
                'Warn on tappable widgets with tap targets smaller than 24x24px (WCAG 2.5.8)');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final InsufficientTapTargetSizeRule rule;
  final RuleContext context;
  _Visitor(this.rule, this.context);

  static const double _minTapSize = 24.0;

  static const _tappableWidgets = {
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

  /// Widgets that constrain the size of their child.
  static const _sizingWidgets = {'SizedBox', 'Container'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_tappableWidgets.contains(constructorTypeName(node))) return;

    if (_isWrappedInShrinkBox(node)) {
      rule.reportAtNode(node);
      return;
    }

    if (_hasInsufficientSizingAncestor(node)) {
      rule.reportAtNode(node);
      return;
    }

    if (_hasInsufficientMinimumSizeInStyle(node)) {
      rule.reportAtNode(node);
    }
  }

  bool _isWrappedInShrinkBox(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final name = constructorTypeName(current);
        final constructorName = current.constructorName.name?.name;
        if (name == 'SizedBox' && constructorName == 'shrink') return true;
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

    for (final styleArg in styleExpr.argumentList.arguments) {
      if (styleArg is! NamedExpression) continue;
      if (styleArg.name.label.name != 'minimumSize') continue;

      final minSizeExpr = styleArg.expression;
      if (minSizeExpr is! InstanceCreationExpression) continue;

      final minSizeTypeName = constructorTypeName(minSizeExpr);
      if (minSizeTypeName != 'WidgetStatePropertyAll' &&
          minSizeTypeName != 'MaterialStatePropertyAll') {
        continue;
      }

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
}
