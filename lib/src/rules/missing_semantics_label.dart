import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/missing_semantics_label_check.dart';

class MissingSemanticsLabelRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'missing_semantics_label',
    'Icon and Image widgets should have a semanticLabel, be wrapped '
        'with Semantics, or wrapped with ExcludeSemantics if decorative. '
        'Clickable widgets (e.g. IconButton, FloatingActionButton) that use '
        'icon-only content should provide a tooltip or ensure the icon has '
        'an accessible label.',
    correctionMessage:
        'Add a semanticLabel argument, provide a tooltip on the clickable '
        'widget, wrap with Semantics(label: "..."), or wrap with '
        'ExcludeSemantics if decorative.',
  );

  MissingSemanticsLabelRule()
      : super(
            name: 'missing_semantics_label',
            description: 'Warn on widgets missing a semantics label');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingSemanticsLabelRule rule;
  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      checkMissingSemanticsLabel(node, rule.reportAtNode);
}
