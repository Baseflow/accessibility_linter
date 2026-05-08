import '../rules/insufficient_color_contrast.dart';
import '../rules/insufficient_tap_target_size.dart';
import '../rules/missing_focus_indicator.dart';
import '../rules/missing_persistent_input_label.dart';
import '../rules/missing_semantics_label.dart';
import '../rules/orientation_lock.dart';
import 'a11y_rule.dart';

final List<A11yRule> allRules = [
  OrientationLockRule(),
  MissingSemanticsLabelRule(),
  MissingFocusIndicatorRule(),
  MissingPersistentInputLabelRule(),
  InsufficientTapTargetSizeRule(),
  InsufficientColorContrastRule(),
];
