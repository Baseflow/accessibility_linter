// ignore_for_file: missing_semantics_label, missing_persistent_input_label, missing_focus_indicator

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Widget> orientationLockCorrect() {
  return [
    ElevatedButton(
      onPressed: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      child: const Text('Allow all orientations (good)'),
    ),
  ];
}
