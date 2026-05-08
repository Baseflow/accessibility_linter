import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:a11y_linter/src/utils/ast_utils.dart';

import 'color_data.dart';

const _backgroundWidgets = <String, String>{
  'Container': 'color',
  'ColoredBox': 'color',
  'Card': 'color',
  'Scaffold': 'backgroundColor',
  'AppBar': 'backgroundColor',
  'BottomNavigationBar': 'backgroundColor',
  'Drawer': 'backgroundColor',
  'Material': 'color',
  'Chip': 'backgroundColor',
  'InputDecorator': 'fillColor',
  'SnackBar': 'backgroundColor',
  'Dialog': 'backgroundColor',
  'AlertDialog': 'backgroundColor',
  'BottomSheet': 'backgroundColor',
  'NavigationBar': 'backgroundColor',
  'NavigationRail': 'backgroundColor',
  'FloatingActionButton': 'backgroundColor',
  'ElevatedButton': 'backgroundColor',
};
const _textWidgets = {'Text', 'RichText', 'SelectableText'};
const _iconWidgets = {'Icon', 'ImageIcon'};

/// Shared detection logic for the `insufficient_color_contrast` rule.
///
/// Calls [report] with each foreground node whose contrast ratio against the
/// nearest static background color falls below the WCAG AA threshold (4.5:1
/// for normal text, 3:1 for large text / icons).
void checkInsufficientColorContrast(
  InstanceCreationExpression node,
  void Function(AstNode) report,
) {
  final bgArgName = _backgroundWidgets[constructorTypeName(node)];
  if (bgArgName == null) return;

  final bgColor = _extractNamedColor(node, bgArgName);
  if (bgColor == null) return;

  _walkChildSubtree(node, (foregroundNode, fgColor, isLargeText) {
    final ratio = _contrastRatio(
      _relativeLuminance(bgColor.r, bgColor.g, bgColor.b),
      _relativeLuminance(fgColor.r, fgColor.g, fgColor.b),
    );
    final threshold = isLargeText ? 3.0 : 4.5;
    if (ratio < threshold) {
      report(foregroundNode);
    }
  });
}

// ─── Child subtree walker ─────────────────────────────────────────────────────

void _walkChildSubtree(
  InstanceCreationExpression root,
  void Function(AstNode foregroundNode, Rgb fgColor, bool isLargeText)
      onForeground,
) {
  final stack = <Expression>[];

  void enqueueArgs(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      stack.add(arg is NamedExpression ? arg.expression : arg);
    }
  }

  enqueueArgs(root);

  while (stack.isNotEmpty) {
    final current = stack.removeLast();

    if (current is ListLiteral) {
      for (final element in current.elements) {
        if (element is Expression) stack.add(element);
      }
      continue;
    }

    if (current is! InstanceCreationExpression) continue;
    final typeName = constructorTypeName(current);

    if (_textWidgets.contains(typeName)) {
      final result = _extractTextForegroundColor(current);
      if (result != null) onForeground(current, result, _isLargeText(current));
      enqueueArgs(current);
      continue;
    }
    if (_iconWidgets.contains(typeName)) {
      final color = _extractNamedColor(current, 'color');
      if (color != null) onForeground(current, color, true);
      enqueueArgs(current);
      continue;
    }
    if (typeName == 'TextSpan') {
      final color = _extractTextSpanColor(current);
      if (color != null) onForeground(current, color, false);
      enqueueArgs(current);
      continue;
    }
    if (_backgroundWidgets.containsKey(typeName)) continue;
    enqueueArgs(current);
  }
}

// ─── Color extraction helpers ─────────────────────────────────────────────────

Rgb? _extractNamedColor(InstanceCreationExpression node, String argName) {
  final arg = getNamedArg(node, argName);
  return arg != null ? _parseColor(arg.expression) : null;
}

Rgb? _extractTextForegroundColor(InstanceCreationExpression textNode) {
  final styleArg = getNamedArg(textNode, 'style');
  return styleArg != null ? _extractTextStyleColor(styleArg.expression) : null;
}

Rgb? _extractTextStyleColor(Expression expr) {
  if (expr is ParenthesizedExpression)
    return _extractTextStyleColor(expr.expression);
  if (expr is InstanceCreationExpression &&
      constructorTypeName(expr) == 'TextStyle') {
    return _extractNamedColor(expr, 'color');
  }
  return null;
}

Rgb? _extractTextSpanColor(InstanceCreationExpression span) {
  final styleArg = getNamedArg(span, 'style');
  return styleArg != null ? _extractTextStyleColor(styleArg.expression) : null;
}

// ─── Large-text detection ─────────────────────────────────────────────────────

bool _isLargeText(InstanceCreationExpression textNode) {
  final styleArg = getNamedArg(textNode, 'style');
  if (styleArg == null) return false;
  final styleExpr = styleArg.expression;
  if (styleExpr is! InstanceCreationExpression) return false;
  if (constructorTypeName(styleExpr) != 'TextStyle') return false;

  double? fontSize;
  bool isBold = false;

  for (final arg in styleExpr.argumentList.arguments) {
    if (arg is! NamedExpression) continue;
    final name = arg.name.label.name;
    if (name == 'fontSize') {
      final expr = arg.expression;
      if (expr is DoubleLiteral) fontSize = expr.value;
      if (expr is IntegerLiteral) fontSize = (expr.value ?? 0).toDouble();
    }
    if (name == 'fontWeight') {
      final expr = arg.expression;
      if (expr is PrefixedIdentifier) {
        final w = expr.identifier.name;
        isBold = w == 'bold' || w == 'w700' || w == 'w800' || w == 'w900';
      }
    }
  }

  if (fontSize != null) {
    if (fontSize >= 18.0) return true;
    if (isBold && fontSize >= 14.0) return true;
  }
  return false;
}

// ─── Color parsing ────────────────────────────────────────────────────────────

Rgb? _parseColor(Expression expr) {
  if (expr is ParenthesizedExpression) return _parseColor(expr.expression);
  if (expr is InstanceCreationExpression) {
    final name = constructorTypeName(expr);
    final ctor = expr.constructorName.name?.name;
    if (name == 'Color' && ctor == null) {
      final arg = expr.argumentList.arguments.firstOrNull;
      if (arg is IntegerLiteral) {
        final v = arg.value ?? 0;
        return (r: (v >> 16) & 0xFF, g: (v >> 8) & 0xFF, b: v & 0xFF);
      }
    }
    if (name == 'Color' && ctor == 'fromARGB') {
      final ints = expr.argumentList.arguments
          .whereType<IntegerLiteral>()
          .map((e) => e.value ?? 0)
          .toList();
      if (ints.length == 4) return (r: ints[1], g: ints[2], b: ints[3]);
    }
    if (name == 'Color' && ctor == 'fromRGBO') {
      final args = expr.argumentList.arguments;
      if (args.length == 4) {
        final r = args[0] is IntegerLiteral
            ? (args[0] as IntegerLiteral).value
            : null;
        final g = args[1] is IntegerLiteral
            ? (args[1] as IntegerLiteral).value
            : null;
        final b = args[2] is IntegerLiteral
            ? (args[2] as IntegerLiteral).value
            : null;
        if (r != null && g != null && b != null) return (r: r, g: g, b: b);
      }
    }
  }
  if (expr is PrefixedIdentifier && expr.prefix.name == 'Colors') {
    return knownColors[expr.identifier.name];
  }
  if (expr is IndexExpression) {
    final target = expr.target;
    final index = expr.index;
    if (target is PrefixedIdentifier &&
        target.prefix.name == 'Colors' &&
        index is IntegerLiteral) {
      final shade = index.value;
      if (shade != null) {
        return knownColorShades[target.identifier.name]?[shade];
      }
    }
  }
  return null;
}

// ─── Contrast math ────────────────────────────────────────────────────────────

double _relativeLuminance(int r, int g, int b) {
  double linearize(int c) {
    final s = c / 255.0;
    return s <= 0.04045
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b);
}

double _contrastRatio(double l1, double l2) {
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}
