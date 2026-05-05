import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

class MissingFocusIndicatorRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'missing_focus_indicator',
    'Interactive widgets should have a visible focus indicator. '
        'Provide a focusColor or a focusNode to ensure keyboard users can '
        'identify the focused element.',
    correctionMessage:
        'Add a focusColor argument or supply a FocusNode via the focusNode '
        'argument. For ElevatedButton, TextButton and OutlinedButton only '
        'focusNode is supported as a direct constructor parameter. '
        'Wrap with ExcludeSemantics if the widget is intentionally '
        'non-interactive.',
  );

  MissingFocusIndicatorRule()
      : super(
            name: 'missing_focus_indicator',
            description:
                'Warn on interactive widgets without a focus indicator');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingFocusIndicatorRule rule;
  final RuleContext context;
  _Visitor(this.rule, this.context);

  static const _fullSupportWidgets = {
    'InkWell',
    'InkResponse',
    'IconButton',
    'FloatingActionButton',
    'CupertinoButton',
  };

  static const _buttonStyleWidgets = {
    'ElevatedButton',
    'TextButton',
    'OutlinedButton',
  };

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (_isWrappedWithExcludeSemantics(node)) return;

    if (_fullSupportWidgets.contains(typeName)) {
      if (_hasNamedNonNull(node, 'focusColor') ||
          _hasNamedNonNull(node, 'focusNode')) return;
      rule.reportAtNode(node);
      return;
    }

    if (_buttonStyleWidgets.contains(typeName)) {
      if (_hasNamedNonNull(node, 'focusNode')) return;
      rule.reportAtNode(node);
      return;
    }

    if (typeName == 'GestureDetector') {
      if (!_hasNamedNonNull(node, 'onTap')) return;
      rule.reportAtNode(node);
    }
  }

  bool _hasNamedNonNull(InstanceCreationExpression node, String argName) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression && argument.name.label.name == argName) {
        return argument.expression is! NullLiteral;
      }
    }
    return false;
  }

  bool _isWrappedWithExcludeSemantics(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final name = current.constructorName.type.name.lexeme;
        if (name == 'ExcludeSemantics') return true;
      }
      current = current.parent;
    }
    return false;
  }
}
