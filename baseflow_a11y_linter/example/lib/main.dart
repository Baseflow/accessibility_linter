import 'package:flutter/material.dart';
import 'rules/missing_semantics_label/violations.dart'
    as missing_semantics_violations;
import 'rules/missing_semantics_label/correct.dart'
    as missing_semantics_correct;
import 'rules/missing_persistent_input_label/violations.dart'
    as missing_input_label_violations;
import 'rules/missing_persistent_input_label/correct.dart'
    as missing_input_label_correct;
import 'rules/missing_focus_indicator/violations.dart'
    as missing_focus_violations;
import 'rules/missing_focus_indicator/correct.dart' as missing_focus_correct;
import 'rules/orientation_lock/violations.dart' as orientation_lock_violations;
import 'rules/orientation_lock/correct.dart' as orientation_lock_correct;

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('A11y Linter Example')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================================================================
              // RULE: missing_semantics_label
              // ================================================================
              const Divider(height: 24),
              const Text(
                'RULE: missing_semantics_label',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // ---- VIOLATIONS ----
              const SizedBox(height: 12),
              const Text(
                '❌ VIOLATIONS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_semantics_violations.missingSemanticLabelViolations(),

              // ---- CORRECT ----
              const SizedBox(height: 16),
              const Text(
                '✅ CORRECT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_semantics_correct.missingSemanticLabelCorrect(),

              // ================================================================
              // RULE: missing_persistent_input_label
              // ================================================================
              const Divider(height: 24),
              const Text(
                'RULE: missing_persistent_input_label',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // ---- VIOLATIONS ----
              const SizedBox(height: 12),
              const Text(
                '❌ VIOLATIONS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_input_label_violations
                  .missingPersistentInputLabelViolations(),

              // ---- CORRECT ----
              const SizedBox(height: 16),
              const Text(
                '✅ CORRECT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_input_label_correct
                  .missingPersistentInputLabelCorrect(),

              // ================================================================
              // RULE: missing_focus_indicator
              // ================================================================
              const Divider(height: 24),
              const Text(
                'RULE: missing_focus_indicator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // ---- VIOLATIONS ----
              const SizedBox(height: 12),
              const Text(
                '❌ VIOLATIONS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_focus_violations.missingFocusIndicatorViolations(),

              // ---- CORRECT ----
              const SizedBox(height: 16),
              const Text(
                '✅ CORRECT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...missing_focus_correct.missingFocusIndicatorCorrect(),

              // ================================================================
              // RULE: orientation_lock
              // ================================================================
              const Divider(height: 24),
              const Text(
                'RULE: orientation_lock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // ---- VIOLATIONS ----
              const SizedBox(height: 12),
              const Text(
                '❌ VIOLATIONS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...orientation_lock_violations.orientationLockViolations(),

              // ---- CORRECT ----
              const SizedBox(height: 16),
              const Text(
                '✅ CORRECT',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...orientation_lock_correct.orientationLockCorrect(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
