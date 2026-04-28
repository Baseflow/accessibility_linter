A11y Linter — Flutter accessibility lint rules

This package provides a set of custom lint rules to help catch common
accessibility issues in Flutter code. The rules are implemented as a
custom_lint plugin so they can be run in CI or picked up by IDEs that support
the `custom_lint` runner.

Quick start

1. Add the linter to your project's dev_dependencies (use the version that
   matches this package or a released version):

```text
dev_dependencies:
  a11y_linter: ^0.1.0
  custom_lint: any
```

2. Enable the custom_lint analyzer plugin in your `analysis_options.yaml`:

```text
analyzer:
  plugins:
	- custom_lint
```

3. Install packages and run the custom linter. From your project root run:

```bash
# for Dart projects
dart pub get
dart run custom_lint

# for Flutter projects
flutter pub get
flutter pub run custom_lint
```

Editors that support the Dart analysis server (for example VS Code or
IntelliJ/Android Studio) will pick up the lint results while `custom_lint` is
running. You can also run `flutter analyze` / `dart analyze` to see lint
results once the plugin is active.

Available rules

- `missing_semantics_label`
    - Ensures `Icon`, `Image`, and `ImageIcon` provide an accessible label via
      `semanticLabel`, are wrapped with `Semantics(label: ...)`, or are marked
      decorative with `ExcludeSemantics`. Also checks clickable widgets with
      icon-only content (e.g. `IconButton`) for a `tooltip` or an accessible
      label.
      See [Non-textual elements](https://baseflow.github.io/accessibility-guidelines/labels/non-textual-elements.html)
      and [Decorative elements](https://baseflow.github.io/accessibility-guidelines/labels/decorative-elements.html) of
      the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

- `missing_focus_indicator`
    - Flags interactive widgets that do not expose a visible focus indicator.
      Suggests providing `focusColor` or a `FocusNode` (or wrapping with
      `ExcludeSemantics` if intentionally non-interactive).
      See [Focus indication](https://baseflow.github.io/accessibility-guidelines/navigation/focus-indication.html) of
      the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

- `missing_persistent_input_label`
    - Ensures input widgets (e.g. `TextField`, `TextFormField`) expose a
      persistent label via `InputDecoration(labelText: ...)` rather than relying
      solely on placeholder/hint text.
      See [Form validation & labels](https://baseflow.github.io/accessibility-guidelines/forms/form-validation.html) of
      the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

- `orientation_lock`
    - Detects calls that lock device orientation (e.g. `SystemChrome
	.setPreferredOrientations`) and warns that orientation locking should be
      avoided for accessibility.
      See [Screen orientation](https://baseflow.github.io/accessibility-guidelines/visual/screen-orientation.html) of
      the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).

- `insufficient_color_contrast`
    - Statically checks color literals for text, icons and other foreground
      elements against nearby background colors and reports when contrast is
      below the WCAG AA thresholds (4.5:1 for normal text, 3:1 for large text).
      Note: only statically determinable colors (literals, `Colors.*`, etc.) are
      checked; theme colors and runtime expressions are skipped.
      See [Color contrast](https://baseflow.github.io/accessibility-guidelines/visual/color-contrast.html) of
      the [Baseflow Accessibility Guidelines](https://baseflow.github.io/accessibility-guidelines/).