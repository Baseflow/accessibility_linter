import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';

import 'checker.dart';
import 'checkers/insufficient_color_contrast_checker.dart';
import 'checkers/insufficient_tap_target_size_checker.dart';
import 'checkers/missing_focus_indicator_checker.dart';
import 'checkers/missing_persistent_input_label_checker.dart';
import 'checkers/missing_semantics_label_checker.dart';
import 'checkers/orientation_lock_checker.dart';
import 'package:path/path.dart' as p;

List<A11yChecker> buildCheckers() => [
      OrientationLockChecker(),
      MissingSemanticsLabelChecker(),
      MissingFocusIndicatorChecker(),
      MissingPersistentInputLabelChecker(),
      InsufficientTapTargetSizeChecker(),
      InsufficientColorContrastChecker(),
    ];

Future<int> runAnalysis(String targetPath) async {
  final normalizedPath = p.normalize(Directory(targetPath).absolute.path);
  final collection = AnalysisContextCollection(includedPaths: [normalizedPath]);
  var violationCount = 0;

  for (final context in collection.contexts) {
    final files = context.contextRoot
        .analyzedFiles()
        .where((f) => f.endsWith('.dart'))
        .toList()
      ..sort();

    for (final filePath in files) {
      final result = await context.currentSession.getResolvedUnit(filePath);
      if (result is! ResolvedUnitResult) continue;

      for (final checker in buildCheckers()) {
        result.unit.accept(checker);
        for (final v in checker.violations) {
          final loc = result.lineInfo.getLocation(v.node.offset);
          stdout.writeln(
            '${result.path}:${loc.lineNumber}:${loc.columnNumber}'
            ' • ${v.ruleName}'
            ' • ${v.message}',
          );
          violationCount++;
        }
      }
    }
  }

  return violationCount;
}
