import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../shared/insufficient_color_contrast_check.dart';

class InsufficientColorContrastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'insufficient_color_contrast',
    'The color contrast ratio between the foreground and background is '
        'below the WCAG AA minimum. Only statically determinable colors are checked.',
    correctionMessage:
        'Choose colors with a sufficient contrast ratio. Use a tool like '
        'https://webaim.org/resources/contrastchecker/ to verify. '
        'Note: colors from Theme, variables, or runtime expressions cannot '
        'be checked statically.',
  );

  InsufficientColorContrastRule()
      : super(
            name: 'insufficient_color_contrast',
            description: 'Warn on insufficient color contrast ratios');

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry, RuleContext context) {
    registry.addInstanceCreationExpression(this, _Visitor(this));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final InsufficientColorContrastRule rule;
  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) =>
      checkInsufficientColorContrast(node, rule.reportAtNode);
}
