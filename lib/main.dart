import 'package:a11y_linter/src/rules/insufficient_color_contrast.dart';
import 'package:a11y_linter/src/rules/missing_focus_indicator.dart';
import 'package:a11y_linter/src/rules/missing_persistent_input_label.dart';
import 'package:a11y_linter/src/rules/missing_semantics_label.dart';
import 'package:a11y_linter/src/rules/orientation_lock.dart';
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

final plugin = A11yPlugin();

class A11yPlugin extends Plugin {
  @override
  String get name => 'baseflow_a11y_linter';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(InsufficientColorContrastRule());
    registry.registerLintRule(MissingFocusIndicatorRule());
    registry.registerLintRule(MissingPersistentInputLabelRule());
    registry.registerLintRule(MissingSemanticsLabelRule());
    registry.registerLintRule(OrientationLockRule());
  }
}
