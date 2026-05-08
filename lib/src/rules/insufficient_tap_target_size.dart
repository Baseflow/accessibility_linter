import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/insufficient_tap_target_size_check.dart';

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
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final InsufficientTapTargetSizeRule rule;
  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      checkInsufficientTapTargetSize(node, rule.reportAtNode);
}
