// ignore_for_file: missing_semantics_label, missing_persistent_input_label, missing_focus_indicator

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Widget> orientationLockViolations() {
  return [
    ElevatedButton(
      onPressed: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      child: const Text('Lock to portrait (bad)'),
    ),

    ElevatedButton(
      onPressed: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      child: const Text('Lock to landscape (bad)'),
    ),
  ];
}
