// ignore_for_file: missing_semantics_label, missing_focus_indicator, missing_persistent_input_label, orientation_lock, insufficient_color_contrast
import 'package:flutter/material.dart';

List<Widget> insufficientTapTargetSizeViolations() {
  return [
    // VIOLATION: GestureDetector constrained to 20x20 (below 24x24)
    SizedBox(
      width: 20,
      height: 20,
      child: GestureDetector(
        onTap: () {},
        child: const ColoredBox(color: Colors.blue),
      ),
    ),

    // VIOLATION: InkWell constrained to 16x16
    SizedBox(
      width: 16,
      height: 16,
      child: InkWell(
        onTap: () {},
        child: const ColoredBox(color: Colors.red),
      ),
    ),

    // VIOLATION: IconButton with minimumSize below 24x24 via ButtonStyle
    IconButton(
      onPressed: () {},
      icon: const Icon(Icons.add),
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(16, 16)),
      ),
    ),

    // VIOLATION: ElevatedButton with minimumSize below 24x24
    ElevatedButton(
      onPressed: () {},
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(20, 20)),
      ),
      child: const Text('Tap'),
    ),

    // VIOLATION: GestureDetector inside SizedBox.shrink()
    SizedBox.shrink(
      child: GestureDetector(
        onTap: () {},
        child: const ColoredBox(color: Colors.green),
      ),
    ),

    // VIOLATION: width only — width is 10, below minimum
    SizedBox(
      width: 10,
      child: InkWell(
        onTap: () {},
        child: const ColoredBox(color: Colors.orange),
      ),
    ),
  ];
}
