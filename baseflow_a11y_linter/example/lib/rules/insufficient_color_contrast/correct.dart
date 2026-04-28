// ignore_for_file: missing_semantics_label, missing_focus_indicator, missing_persistent_input_label, orientation_lock

import 'package:flutter/material.dart';

List<Widget> insufficientColorContrastCorrect() {
  return [
    // High contrast black on white
    Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'High contrast text (black on white)',
        style: TextStyle(color: Colors.black),
      ),
    ),

    // High contrast white on dark background
    Container(
      color: const Color(0xFF0B0B0B),
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'High contrast text (white on dark)',
        style: TextStyle(color: Colors.white),
      ),
    ),

    // Icon with sufficient contrast
    Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8.0),
      child: const Icon(Icons.add, color: Colors.white),
    ),

    // Large text qualifies for the lower 3:1 threshold and can use moderate contrast
    Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'Large text with moderate contrast',
        style: TextStyle(fontSize: 20.0, color: Color(0xFF6E6E6E)),
      ),
    ),
  ];
}
