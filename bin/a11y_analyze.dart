import 'dart:io';

import 'package:a11y_linter/src/cli/runner.dart';

Future<void> main(List<String> args) async {
  final targetPath = Directory(args.isEmpty ? 'lib' : args.first).absolute.path;

  if (!Directory(targetPath).existsSync()) {
    stderr.writeln('❌ Error: Directory not found: $targetPath');
    exit(2);
  }

  stdout.writeln('🔍 Analyzing accessibility rules in: $targetPath');
  stdout.writeln('');

  final violationCount = await runAnalysis(targetPath);

  if (violationCount > 0) {
    stderr.writeln('❌ $violationCount accessibility violation(s) found.');
    exit(1);
  } else {
    stdout.writeln('✅ No accessibility violations found.');
    exit(0);
  }
}
