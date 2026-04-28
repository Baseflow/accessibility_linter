// ignore_for_file: missing_semantics_label, missing_focus_indicator, orientation_lock

import 'package:flutter/material.dart';

List<Widget> missingPersistentInputLabelViolations() {
  return [
    // TextField with hint only (not persistent) — VIOLATION
    const TextField(decoration: InputDecoration(hintText: 'Email address')),
  ];
}
