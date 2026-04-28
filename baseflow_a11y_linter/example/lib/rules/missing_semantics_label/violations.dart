// ignore_for_file: missing_focus_indicator, missing_persistent_input_label, orientation_lock

import 'package:flutter/material.dart';

List<Widget> missingSemanticLabelViolations() {
  return [
    // Icon with no semanticLabel
    const Icon(Icons.home),

    // Icon with semanticLabel explicitly set to null
    const Icon(Icons.search, semanticLabel: null),

    // Image with no semanticLabel
    const Image(image: NetworkImage('https://example.com/photo.jpg')),

    // ImageIcon with no semanticLabel
    const ImageIcon(null),

    // Semantics wrapper with no label argument
    Semantics(child: const Icon(Icons.warning)),

    // Semantics wrapper with label explicitly null
    Semantics(label: null, child: const Icon(Icons.error)),

    // Clickable widgets with icon-only content — VIOLATIONS
    // (no tooltip, inner semanticLabel, or Semantics wrapper)
    IconButton(icon: const Icon(Icons.add), onPressed: () {}),

    FloatingActionButton(onPressed: () {}, child: const Icon(Icons.navigation)),
  ];
}
