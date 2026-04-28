// ignore_for_file: missing_semantics_label, missing_persistent_input_label, orientation_lock

import 'package:flutter/material.dart';

List<Widget> missingFocusIndicatorCorrect() {
  return [
    // InkWell with a focusColor
    InkWell(
      onTap: () {},
      focusColor: Colors.blue,
      child: const Text('InkWell — focusColor set'),
    ),

    // InkWell with a focusNode
    InkWell(
      onTap: () {},
      focusNode: FocusNode(),
      child: const Text('InkWell — focusNode set'),
    ),

    // ElevatedButton with a focusNode
    ElevatedButton(
      onPressed: () {},
      focusNode: FocusNode(),
      child: const Text('ElevatedButton — focusNode set'),
    ),

    // TextButton with a focusNode
    TextButton(
      onPressed: () {},
      focusNode: FocusNode(),
      child: const Text('TextButton — focusNode set'),
    ),

    // OutlinedButton with a focusNode
    OutlinedButton(
      onPressed: () {},
      focusNode: FocusNode(),
      child: const Text('OutlinedButton — focusNode set'),
    ),

    // IconButton with a focusColor
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {},
      focusColor: Colors.blue,
    ),

    // FloatingActionButton with a focusColor
    FloatingActionButton(
      onPressed: () {},
      focusColor: Colors.blue,
      child: const Icon(Icons.add),
    ),

    // Materialbutton with a focusColor
    MaterialButton(
      onPressed: () {},
      focusColor: Colors.blue,
      child: const Text('MaterialButtons — focusColor set'),
    ),

    // GestureDetector without onTap — not flagged (rule only fires for onTap)
    GestureDetector(
      onLongPress: () {},
      child: const Text('GestureDetector — no onTap, not flagged'),
    ),

    // MouseRegion — always skipped by the rule
    MouseRegion(
      onEnter: (_) {},
      child: const Text('MouseRegion — always skipped'),
    ),

    // InkWell inside ExcludeSemantics — escape hatch suppresses warning
    const ExcludeSemantics(
      child: InkWell(
        child: Text('InkWell inside ExcludeSemantics — suppressed'),
      ),
    ),

    // GestureDetector inside ExcludeSemantics — escape hatch suppresses warning
    ExcludeSemantics(
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          'GestureDetector inside ExcludeSemantics — suppressed',
        ),
      ),
    ),
  ];
}
