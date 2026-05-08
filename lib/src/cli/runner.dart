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

  final violationsByFile =
      <String, List<({int line, int column, String rule, String message})>>{};

  for (final context in collection.contexts) {
    final files = context.contextRoot
        .analyzedFiles()
        .where((f) => f.endsWith('.dart'))
        .toList()
      ..sort();

    for (final filePath in files) {
      final result = await context.currentSession.getResolvedUnit(filePath);
      if (result is! ResolvedUnitResult) continue;

      final fileViolations =
          <({int line, int column, String rule, String message})>[];

      for (final checker in buildCheckers()) {
        result.unit.accept(checker);
        for (final v in checker.violations) {
          final loc = result.lineInfo.getLocation(v.node.offset);
          fileViolations.add((
            line: loc.lineNumber,
            column: loc.columnNumber,
            rule: v.ruleName,
            message: v.message,
          ));
        }
      }

      if (fileViolations.isNotEmpty) {
        fileViolations.sort((a, b) {
          final lineCmp = a.line.compareTo(b.line);
          return lineCmp != 0 ? lineCmp : a.column.compareTo(b.column);
        });
        violationsByFile[result.path] = fileViolations;
      }
    }
  }

  // Print formatted output
  if (violationsByFile.isEmpty) {
    return 0;
  }

  stdout.writeln('');
  stdout.writeln('‼️ Violations Found');
  stdout.writeln('');

  var totalViolations = 0;
  final ruleCount = <String, int>{};

  for (final filePath in violationsByFile.keys) {
    final violations = violationsByFile[filePath]!;
    stdout.writeln('📄 $filePath');

    for (final v in violations) {
      stdout.writeln(
        '  ├─ ${_padRight('${v.line}:${v.column}', 8)} • ${_padRight(v.rule, 35)} • ${v.message}',
      );
      totalViolations++;
      ruleCount[v.rule] = (ruleCount[v.rule] ?? 0) + 1;
    }
  }

  stdout.writeln('');
  stdout.writeln('📋 Summary');
  stdout.writeln('');

  final sortedRules = ruleCount.keys.toList()..sort();
  for (final rule in sortedRules) {
    final count = ruleCount[rule]!;
    stdout.writeln('  • $count violation${count > 1 ? 's' : ''} — $rule');
  }

  stdout.writeln('');
  stdout.writeln(
      '  Total: $totalViolations violation${totalViolations > 1 ? 's' : ''}');
  stdout.writeln('');

  return totalViolations;
}

String _padRight(String str, int width) {
  return str.length >= width ? str : str + ' ' * (width - str.length);
}
