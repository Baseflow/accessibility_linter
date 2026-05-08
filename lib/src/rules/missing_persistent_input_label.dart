import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/missing_persistent_input_label_check.dart';

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
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingPersistentInputLabelRule rule;
  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      checkMissingPersistentInputLabel(node, rule.reportAtNode);
}
