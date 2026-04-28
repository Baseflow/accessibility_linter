// ignore_for_file: missing_semantics_label, missing_persistent_input_label, orientation_lock

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> missingFocusIndicatorViolations() {
  return [
    // InkWell with no focusColor or focusNode
    InkWell(onTap: () {}, child: const Text('InkWell — no focus indicator')),

    // InkWell with focusColor explicitly null
    InkWell(
      onTap: () {},
      focusColor: null,
      child: const Text('InkWell — focusColor: null'),
    ),

    // InkResponse with no focusColor or focusNode
    InkResponse(
      onTap: () {},
      child: const Text('InkResponse — no focus indicator'),
    ),

    // TextButton with no focusNode
    TextButton(
      onPressed: () {},
      child: const Text('TextButton — no focus indicator'),
    ),

    // ElevatedButton with no focusNode
    ElevatedButton(
      onPressed: () {},
      child: const Text('ElevatedButton — no focus indicator'),
    ),

    // OutlinedButton with no focusNode
    OutlinedButton(
      onPressed: () {},
      child: const Text('OutlinedButton — no focus indicator'),
    ),

    // IconButton with no focusColor or focusNode
    IconButton(icon: const Icon(Icons.add), onPressed: () {}),

    // FloatingActionButton with no focusColor or focusNode
    FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),

    // CupertinoButton with no focusColor or focusNode
    CupertinoButton(
      onPressed: () {},
      child: const Text('CupertinoButton — no focus indicator'),
    ),

    // GestureDetector with onTap — always flagged (no focus params exist)
    GestureDetector(
      onTap: () {},
      child: const Text('GestureDetector — onTap, always flagged'),
    ),
  ];
}
