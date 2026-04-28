import 'package:a11y_linter/rules/insufficient_color_contrast.dart';
import 'package:a11y_linter/rules/missing_focus_indicator.dart';
import 'package:a11y_linter/rules/missing_persistent_input_label.dart';
import 'package:a11y_linter/rules/missing_semantics_label.dart';
import 'package:a11y_linter/rules/orientation_lock.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class A11yLinterPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        MissingSemanticsLabel(),
        MissingFocusIndicator(),
        MissingPersistentInputLabel(),
        OrientationLock(),
        InsufficientColorContrast(),
      ];
}
