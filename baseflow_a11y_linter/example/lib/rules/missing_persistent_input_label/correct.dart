// ignore_for_file: missing_semantics_label, missing_focus_indicator, orientation_lock

import 'package:flutter/material.dart';

List<Widget> missingPersistentInputLabelCorrect() {
  return [
    // TextField with labelText — CORRECT
    const TextField(decoration: InputDecoration(labelText: 'Email address')),
  ];
}
