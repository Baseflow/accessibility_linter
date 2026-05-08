import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/missing_focus_indicator_check.dart';

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
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MissingFocusIndicatorRule rule;
  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      checkMissingFocusIndicator(node, rule.reportAtNode);
}
