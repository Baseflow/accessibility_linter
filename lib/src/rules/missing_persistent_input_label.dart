import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../utils/ast_utils.dart';

class MissingPersistentInputLabelRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'missing_persistent_input_label',
    'Input widgets should expose a persistent label. Placeholders/hints '
        'alone are not sufficient because they disappear during entry.',
    correctionMessage:
        'Provide a persistent label using InputDecoration(labelText: "...") '
        'or InputDecoration(label: Text("...")).',
  );

  MissingPersistentInputLabelRule()
      : super(
            name: 'missing_persistent_input_label',
            description: 'Warn on input widgets without a persistent label');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingPersistentInputLabelRule rule;
  final RuleContext context;
  _Visitor(this.rule, this.context);

  static const _inputWidgets = {'TextField', 'TextFormField'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_inputWidgets.contains(constructorTypeName(node))) return;
    if (_hasPersistentLabel(node)) return;
    rule.reportAtNode(node);
  }

  bool _hasPersistentLabel(InstanceCreationExpression node) {
    final decorationArg = getNamedArg(node, 'decoration');
    if (decorationArg == null || decorationArg.expression is NullLiteral) {
      return false;
    }
    return _decorationHasPersistentLabel(decorationArg.expression);
  }

  bool _decorationHasPersistentLabel(Expression expression) {
    if (expression is ParenthesizedExpression) {
      return _decorationHasPersistentLabel(expression.expression);
    }
    if (expression is InstanceCreationExpression) {
      if (constructorTypeName(expression) != 'InputDecoration') return false;
      return hasNamedNonNull(expression, 'labelText') ||
          hasNamedNonNull(expression, 'label');
    }
    return false;
  }
}
