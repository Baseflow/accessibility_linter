import 'package:a11y_linter/src/rules/a11y_analysis_rule.dart';
import 'package:a11y_linter/src/shared/all_rules.dart';
import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

final plugin = A11yPlugin();

class A11yPlugin extends Plugin {
  @override
  String get name => 'baseflow_a11y_linter';

  @override
  void register(PluginRegistry registry) {
    for (final spec in allRules) {
      registry.registerLintRule(A11yAnalysisRule(spec));
    }
  }
}
