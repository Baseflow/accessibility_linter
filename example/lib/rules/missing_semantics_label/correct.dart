// ignore_for_file: missing_focus_indicator, missing_persistent_input_label, orientation_lock

import 'package:flutter/material.dart';

List<Widget> missingSemanticLabelCorrect() {
  return [
    // Icon with a semanticLabel
    const Icon(Icons.home, semanticLabel: 'Home'),

    // Icon marked decorative via ExcludeSemantics
    const ExcludeSemantics(child: Icon(Icons.star)),

    // Icon wrapped in Semantics with a label
    Semantics(label: 'Favourite', child: const Icon(Icons.favorite)),

    // Image with a semanticLabel
    const Image(
      image: NetworkImage('https://example.com/photo.jpg'),
      semanticLabel: 'A scenic landscape',
    ),

    // Image marked decorative via ExcludeSemantics
    const ExcludeSemantics(
      child: Image(image: NetworkImage('https://example.com/bg.jpg')),
    ),

    // ImageIcon with a semanticLabel
    const ImageIcon(null, semanticLabel: 'Custom icon'),

    // Clickable widgets with accessible labels/tooltips — CORRECT
    IconButton(
      icon: const Icon(Icons.add, semanticLabel: 'Add'),
      tooltip: 'Add',
      onPressed: () {},
      focusColor: Colors.blue,
    ),

    IconButton(
      icon: const Icon(Icons.home, semanticLabel: 'Home'),
      onPressed: () {},
      focusColor: Colors.blue,
    ),

    FloatingActionButton(
      onPressed: () {},
      tooltip: 'Create',
      focusColor: Colors.blue,
      child: const Icon(Icons.add, semanticLabel: 'Create'),
    ),

    Semantics(
      label: 'Navigate',
      child: FloatingActionButton(
        onPressed: () {},
        focusColor: Colors.blue,
        child: const Icon(Icons.navigation),
      ),
    ),
  ];
}
