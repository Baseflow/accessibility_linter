// ignore_for_file: missing_semantics_label, missing_focus_indicator, missing_persistent_input_label, orientation_lock, insufficient_color_contrast
import 'package:flutter/material.dart';

List<Widget> insufficientTapTargetSizeCorrect() {
  return [
    // OK: GestureDetector at exactly the minimum 24x24
    SizedBox(
      width: 24,
      height: 24,
      child: GestureDetector(
        onTap: () {},
        child: const ColoredBox(color: Colors.blue),
      ),
    ),

    // OK: InkWell constrained to 48x48 (well above minimum)
    SizedBox(
      width: 48,
      height: 48,
      child: InkWell(
        onTap: () {},
        child: const ColoredBox(color: Colors.red),
      ),
    ),

    // OK: GestureDetector with no explicit size constraint (inherits from layout)
    GestureDetector(
      onTap: () {},
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.home),
      ),
    ),

    // OK: ElevatedButton with sufficient minimumSize
    ElevatedButton(
      onPressed: () {},
      style: const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(44, 44)),
      ),
      child: const Text('Tap'),
    ),

    // OK: TextButton — no explicit size restriction
    TextButton(onPressed: () {}, child: const Text('Press me')),

    // OK: Container width >= 24, height >= 24
    Container(
      width: 44,
      height: 44,
      child: InkWell(
        onTap: () {},
        child: const ColoredBox(color: Colors.green),
      ),
    ),
  ];
}
