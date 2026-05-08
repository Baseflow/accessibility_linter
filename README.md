# A11y Linter — Flutter accessibility lint rules

This package provides a set of custom lint rules to help catch common accessibility issues in Flutter code. Rules run via the `analysis_server_plugin` integration for IDE support, and via a standalone CLI tool (`a11y_analyze`) for use in CI pipelines.

## Quick start

### 1. Add the dependency

In your project's `pubspec.yaml`:

```yaml
dependencies:
  a11y_linter:
    git:
      url: https://github.com/baseflow/accessibility_linter.git
```

### 2. Enable the plugin in `analysis_options.yaml`

```yaml
plugins:
  a11y_linter:
    path: <path-to-package> # or use pub cache path resolved by pub get
    diagnostics:
      orientation_lock: true
      missing_persistent_input_label: true
      missing_focus_indicator: true
      missing_semantics_label: true
      insufficient_color_contrast: true
      insufficient_tap_target_size: true
```

This enables IDE integration in VS Code and IntelliJ/Android Studio via the Dart analysis server.

### 3. Run in CI

Add the following steps to your GitHub Actions workflow (or equivalent):

```yaml
- name: Install deps
  run: flutter pub get

- name: Generate code
  run: dart run build_runner build

- name: Run a11y linter
  run: dart run a11y_linter:a11y_analyze lib/
```

The `a11y_analyze` script exits with code `1` if any violations are found, making it suitable as a CI gate. It does not depend on the analysis server plugin infrastructure and works reliably in headless environments.

### 4. Run locally via CLI

To run the linter from your local machine or CI environment, use:

```bash
dart run a11y_linter:a11y_analyze lib/
```

Or for a Dart project (not Flutter):

```bash
dart run a11y_linter:a11y_analyze lib/
```

You can also specify a custom path:

```bash
dart run a11y_linter:a11y_analyze src/
```

The script will analyze all `.dart` files in the specified directory (default: `lib/`) and report any violations found. Output includes the file path, line number, column number, rule name, and message for each violation.

---

## Available rules

### `missing_semantics_label`

Ensures `Icon`, `Image`, and `ImageIcon` provide an accessible label via `semanticLabel`, are wrapped with `Semantics(label: ...)`, or are marked decorative with `ExcludeSemantics`. Also checks clickable widgets with icon-only content (e.g. `IconButton`) for a `tooltip` or an accessible icon label.

See [Non-textual elements](https://baseflow.github.io/accessibility-guidelines/labels/non-textual-elements.html) and [Decorative elements](https://baseflow.github.io/accessibility-guidelines/labels/decorative-elements.html) of the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

### `missing_focus_indicator`

Flags interactive widgets that do not expose a visible focus indicator. Suggests providing `focusColor` or a `FocusNode`, or wrapping with `ExcludeSemantics` if intentionally non-interactive.

See [Focus indication](https://baseflow.github.io/accessibility-guidelines/navigation/focus-indication.html) of the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

### `missing_persistent_input_label`

Ensures input widgets (`TextField`, `TextFormField`) expose a persistent label via `InputDecoration(labelText: ...)` or `InputDecoration(label: ...)` rather than relying solely on placeholder/hint text.

See [Form validation & labels](https://baseflow.github.io/accessibility-guidelines/forms/form-validation.html) of the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

### `orientation_lock`

Detects calls that lock device orientation via `SystemChrome.setPreferredOrientations` and warns that orientation locking should be avoided for accessibility.

See [Screen orientation](https://baseflow.github.io/accessibility-guidelines/visual/screen-orientation.html) of the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

### `insufficient_color_contrast`

Statically checks color literals for text, icons, and other foreground elements against nearby background colors and reports when contrast falls below WCAG AA thresholds (4.5:1 for normal text, 3:1 for large text). Only statically determinable colors (literals, `Colors.*`, `Color(0x...)`, etc.) are checked; theme colors and runtime expressions are skipped.

See [Color contrast](https://baseflow.github.io/accessibility-guidelines/visual/color-contrast.html) of the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

### `insufficient_tap_target_size`

Warns when tappable widgets (`GestureDetector`, `InkWell`, buttons, etc.) are constrained below 24×24 logical pixels, per WCAG 2.5.8.

---

## Adding a new rule

Each rule lives entirely in a single self-contained file under `lib/src/rules/`. Adding a new rule requires touching exactly two files:

### 1. Create `lib/src/rules/my_new_rule.dart`

Create a class extending `A11yRule`. Override `name`, `message`, `correctionMessage`, and whichever check method(s) apply:

```dart
import 'package:analyzer/dart/ast/ast.dart';

import '../shared/a11y_rule.dart';

class MyNewRule extends A11yRule {
  @override
  String get name => 'my_new_rule';

  @override
  String get message => 'Short description of what is wrong.';

  @override
  String get correctionMessage => 'Suggestion shown in the IDE on how to fix it.';

  @override
  void checkInstanceCreation(
    InstanceCreationExpression node,
    void Function(AstNode) report,
  ) {
    // Inspect the AST node. Call report(node) when a violation is detected.
  }
}
```

Override `checkInstanceCreation` for widget constructor calls, `checkMethodInvocation` for static/instance method calls, or both if needed. Unneeded methods can be omitted — the default implementations are no-ops.

### 2. Register it in `lib/src/shared/all_rules.dart`

Add one import and one instance to the list:

```dart
import '../rules/my_new_rule.dart';

final List<A11yRule> allRules = [
  // ... existing rules ...
  MyNewRule(),
];
```

That's it. Both the IDE plugin and the CLI `a11y_analyze` tool pick it up automatically — no other changes needed.

### 3. Enable it in `analysis_options.yaml` (for IDE use)

```yaml
plugins:
  a11y_linter:
    diagnostics:
      my_new_rule: true
```

---

## Architecture

```
lib/
  main.dart                        # IDE plugin entry point — loops over allRules
  src/
    rules/
      a11y_analysis_rule.dart      # Generic AnalysisRule wrapper (IDE only)
      orientation_lock.dart        # A11yRule subclass (one file per rule)
      missing_semantics_label.dart
      missing_focus_indicator.dart
      missing_persistent_input_label.dart
      insufficient_tap_target_size.dart
      insufficient_color_contrast.dart
    shared/
      a11y_rule.dart               # Abstract base class for all rules
      all_rules.dart               # Canonical list — the only registration point
      color_data.dart              # Known Flutter color values
    cli/
      checker.dart                 # RecursiveAstVisitor driven by allRules
      runner.dart                  # AnalysisContextCollection setup
      violation.dart               # Violation data class
    utils/
      ast_utils.dart               # Shared AST helpers
bin/
  a11y_analyze.dart                # CLI entry point
```

`A11yRule` is the bridge between both entry points. The CLI drives a `RecursiveAstVisitor` from `allRules`, calling `checkInstanceCreation` and `checkMethodInvocation` on each rule directly. The IDE wraps each rule in a generic `A11yAnalysisRule` that registers `SimpleAstVisitor` callbacks with the analysis server registry. The default no-op implementations on `A11yRule` mean rules only override the methods they need.
