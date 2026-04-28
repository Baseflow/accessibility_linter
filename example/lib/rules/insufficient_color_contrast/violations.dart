// ignore_for_file: missing_semantics_label, missing_focus_indicator, missing_persistent_input_label, orientation_lock

import 'package:flutter/material.dart';

List<Widget> insufficientColorContrastViolations() {
  return [
    // Low contrast text on a white background (Colors.grey[500] on white)
    Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Low contrast text (grey on white)',
        style: TextStyle(color: Colors.grey[500]),
      ),
    ),

    // Explicit Color literal with poor contrast on white
    Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Light gray on white',
        style: TextStyle(color: const Color(0xFF9E9E9E)),
      ),
    ),

    // Icon with insufficient contrast on a dark background
    Container(
      color: const Color(0xFF000000),
      padding: const EdgeInsets.all(8.0),
      child: const Icon(Icons.add, color: Color(0xFF222222)),
    ),

    // Nested widgets: Card with white background, ListTile title uses low-contrast color
    Card(
      color: Colors.white,
      child: ListTile(
        title: Text(
          'ListTile title with poor contrast',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    ),
  ];
}
