import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class InsufficientColorContrast extends DartLintRule {
  const InsufficientColorContrast() : super(code: _code);

  static const _code = LintCode(
    name: 'insufficient_color_contrast',
    problemMessage:
        'The color contrast ratio between the foreground and background is '
        'below the WCAG AA minimum ({0}:1 required, {1}:1 found). '
        'Only statically determinable colors are checked.',
    correctionMessage:
        'Choose colors with a sufficient contrast ratio. Use a tool like '
        'https://webaim.org/resources/contrastchecker/ to verify. '
        'Note: colors from Theme, variables, or runtime expressions cannot '
        'be checked statically.',
  );

  static const _backgroundWidgets = {
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

  static const _textWidgets = {'Text', 'RichText', 'SelectableText'};
  static const _iconWidgets = {'Icon', 'ImageIcon'};

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name.lexeme;

      // Only enter from a background-providing widget.
      final bgArgName = _backgroundWidgets[typeName];
      if (bgArgName == null) return;

      final bgColor = _extractNamedColor(node, bgArgName);
      if (bgColor == null) return; // dynamic/theme color — skip

      // Walk the entire child subtree of this node looking for foreground
      // elements (Text, RichText, Icon, etc.) that carry a color.
      _walkChildSubtree(node, (foregroundNode, fgColor, isLargeText) {
        final ratio = _contrastRatio(
          _relativeLuminance(bgColor.r, bgColor.g, bgColor.b),
          _relativeLuminance(fgColor.r, fgColor.g, fgColor.b),
        );

        final threshold = isLargeText ? 3.0 : 4.5;

        if (ratio < threshold) {
          reporter.atNode(
            foregroundNode,
            _code,
            arguments: [
              threshold.toStringAsFixed(1),
              ratio.toStringAsFixed(2),
            ],
          );
        }
      });
    });
  }

  void _walkChildSubtree(
    InstanceCreationExpression root,
    void Function(
      AstNode foregroundNode,
      ({int r, int g, int b}) fgColor,
      bool isLargeText,
    ) onForeground,
  ) {
    final stack = <Expression>[];

    void enqueueArgs(InstanceCreationExpression node) {
      for (final arg in node.argumentList.arguments) {
        final expr = arg is NamedExpression ? arg.expression : arg;
        stack.add(expr);
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

      final typeName = current.constructorName.type.name.lexeme;

      if (_textWidgets.contains(typeName)) {
        final result = _extractTextForegroundColor(current);
        if (result != null) {
          final isLarge = _isLargeText(current);
          onForeground(current, result, isLarge);
        }
        enqueueArgs(current);
        continue;
      }

      if (_iconWidgets.contains(typeName)) {
        final color = _extractNamedColor(current, 'color');
        if (color != null) {
          onForeground(current, color, true);
        }
        enqueueArgs(current);
        continue;
      }

      if (typeName == 'TextSpan') {
        final color = _extractTextSpanColor(current);
        if (color != null) {
          onForeground(current, color, false);
        }
        enqueueArgs(current);
        continue;
      }

      if (_backgroundWidgets.containsKey(typeName)) {
        continue;
      }

      enqueueArgs(current);
    }
  }

  ({int r, int g, int b})? _extractNamedColor(
    InstanceCreationExpression node,
    String argName,
  ) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == argName) {
        return _parseColor(arg.expression);
      }
    }
    return null;
  }

  ({int r, int g, int b})? _extractTextForegroundColor(
    InstanceCreationExpression textNode,
  ) {
    for (final arg in textNode.argumentList.arguments) {
      if (arg is! NamedExpression || arg.name.label.name != 'style') continue;
      return _extractTextStyleColor(arg.expression);
    }
    return null;
  }

  ({int r, int g, int b})? _extractTextStyleColor(Expression expr) {
    if (expr is ParenthesizedExpression) {
      return _extractTextStyleColor(expr.expression);
    }
    if (expr is InstanceCreationExpression) {
      final name = expr.constructorName.type.name.lexeme;
      if (name == 'TextStyle') {
        return _extractNamedColor(expr, 'color');
      }
    }
    return null;
  }

  ({int r, int g, int b})? _extractTextSpanColor(
    InstanceCreationExpression span,
  ) {
    for (final arg in span.argumentList.arguments) {
      if (arg is! NamedExpression || arg.name.label.name != 'style') continue;
      return _extractTextStyleColor(arg.expression);
    }
    return null;
  }

  bool _isLargeText(InstanceCreationExpression textNode) {
    for (final arg in textNode.argumentList.arguments) {
      if (arg is! NamedExpression || arg.name.label.name != 'style') continue;
      final styleExpr = arg.expression;
      if (styleExpr is! InstanceCreationExpression) continue;
      if (styleExpr.constructorName.type.name.lexeme != 'TextStyle') continue;

      double? fontSize;
      bool isBold = false;

      for (final styleArg in styleExpr.argumentList.arguments) {
        if (styleArg is! NamedExpression) continue;
        final name = styleArg.name.label.name;
        if (name == 'fontSize') {
          final expr = styleArg.expression;
          if (expr is DoubleLiteral) fontSize = expr.value;
          if (expr is IntegerLiteral) fontSize = (expr.value ?? 0).toDouble();
        }
        if (name == 'fontWeight') {
          final expr = styleArg.expression;
          if (expr is PrefixedIdentifier) {
            final weightName = expr.identifier.name;
            isBold = weightName == 'bold' ||
                weightName == 'w700' ||
                weightName == 'w800' ||
                weightName == 'w900';
          }
        }
      }

      if (fontSize != null) {
        if (fontSize >= 18.0) return true;
        if (isBold && fontSize >= 14.0) return true;
      }
    }
    return false;
  }

  ({int r, int g, int b})? _parseColor(Expression expr) {
    if (expr is ParenthesizedExpression) return _parseColor(expr.expression);

    if (expr is InstanceCreationExpression) {
      final name = expr.constructorName.type.name.lexeme;
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
        final ints = expr.argumentList.arguments
            .whereType<IntegerLiteral>()
            .map((e) => e.value ?? 0)
            .toList();
        if (ints.length == 3) return (r: ints[0], g: ints[1], b: ints[2]);
        final allArgs = expr.argumentList.arguments;
        if (allArgs.length == 4) {
          int? r, g, b;
          if (allArgs[0] is IntegerLiteral) {
            r = (allArgs[0] as IntegerLiteral).value;
          }
          if (allArgs[1] is IntegerLiteral) {
            g = (allArgs[1] as IntegerLiteral).value;
          }
          if (allArgs[2] is IntegerLiteral) {
            b = (allArgs[2] as IntegerLiteral).value;
          }
          if (r != null && g != null && b != null) {
            return (r: r, g: g, b: b);
          }
        }
      }
    }

    if (expr is PrefixedIdentifier && expr.prefix.name == 'Colors') {
      return _knownColors[expr.identifier.name];
    }

    if (expr is IndexExpression) {
      final target = expr.target;
      final index = expr.index;
      if (target is PrefixedIdentifier &&
          target.prefix.name == 'Colors' &&
          index is IntegerLiteral) {
        final shade = index.value;
        if (shade != null) {
          return _knownColorShades[target.identifier.name]?[shade];
        }
      }
    }

    return null;
  }

  double _relativeLuminance(int r, int g, int b) {
    double linearize(int c) {
      final s = c / 255.0;
      return s <= 0.04045
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * linearize(r) +
        0.7152 * linearize(g) +
        0.0722 * linearize(b);
  }

  double _contrastRatio(double l1, double l2) {
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static const _knownColors = <String, ({int r, int g, int b})>{
    'white': (r: 255, g: 255, b: 255),
    'black': (r: 0, g: 0, b: 0),
    'transparent': (r: 0, g: 0, b: 0),
    'red': (r: 244, g: 67, b: 54),
    'redAccent': (r: 255, g: 82, b: 82),
    'pink': (r: 233, g: 30, b: 99),
    'pinkAccent': (r: 255, g: 64, b: 129),
    'purple': (r: 156, g: 39, b: 176),
    'deepPurple': (r: 103, g: 58, b: 183),
    'indigo': (r: 63, g: 81, b: 181),
    'blue': (r: 33, g: 150, b: 243),
    'blueAccent': (r: 68, g: 138, b: 255),
    'lightBlue': (r: 3, g: 169, b: 244),
    'cyan': (r: 0, g: 188, b: 212),
    'teal': (r: 0, g: 150, b: 136),
    'green': (r: 76, g: 175, b: 80),
    'lightGreen': (r: 139, g: 195, b: 74),
    'lime': (r: 205, g: 220, b: 57),
    'yellow': (r: 255, g: 235, b: 59),
    'amber': (r: 255, g: 193, b: 7),
    'orange': (r: 255, g: 152, b: 0),
    'deepOrange': (r: 255, g: 87, b: 34),
    'brown': (r: 121, g: 85, b: 72),
    'grey': (r: 158, g: 158, b: 158),
    'blueGrey': (r: 96, g: 125, b: 139),
  };

  static const _knownColorShades = <String, Map<int, ({int r, int g, int b})>>{
    'red': {
      50: (r: 255, g: 235, b: 238),
      100: (r: 255, g: 205, b: 210),
      200: (r: 239, g: 154, b: 154),
      300: (r: 229, g: 115, b: 115),
      400: (r: 239, g: 83, b: 80),
      500: (r: 244, g: 67, b: 54),
      600: (r: 229, g: 57, b: 53),
      700: (r: 211, g: 47, b: 47),
      800: (r: 198, g: 40, b: 40),
      900: (r: 183, g: 28, b: 28),
    },
    'blue': {
      50: (r: 227, g: 242, b: 253),
      100: (r: 187, g: 222, b: 251),
      200: (r: 144, g: 202, b: 249),
      300: (r: 100, g: 181, b: 246),
      400: (r: 66, g: 165, b: 245),
      500: (r: 33, g: 150, b: 243),
      600: (r: 30, g: 136, b: 229),
      700: (r: 25, g: 118, b: 210),
      800: (r: 21, g: 101, b: 192),
      900: (r: 13, g: 71, b: 161),
    },
    'green': {
      50: (r: 232, g: 245, b: 233),
      100: (r: 200, g: 230, b: 201),
      200: (r: 165, g: 214, b: 167),
      300: (r: 129, g: 199, b: 132),
      400: (r: 102, g: 187, b: 106),
      500: (r: 76, g: 175, b: 80),
      600: (r: 67, g: 160, b: 71),
      700: (r: 56, g: 142, b: 60),
      800: (r: 46, g: 125, b: 50),
      900: (r: 27, g: 94, b: 32),
    },
    'grey': {
      50: (r: 250, g: 250, b: 250),
      100: (r: 245, g: 245, b: 245),
      200: (r: 238, g: 238, b: 238),
      300: (r: 224, g: 224, b: 224),
      400: (r: 189, g: 189, b: 189),
      500: (r: 158, g: 158, b: 158),
      600: (r: 117, g: 117, b: 117),
      700: (r: 97, g: 97, b: 97),
      800: (r: 66, g: 66, b: 66),
      900: (r: 33, g: 33, b: 33),
    },
  };
}
