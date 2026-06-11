import 'package:flutter/material.dart';

/// Caps the effective text scale for dense list/control layouts.
///
/// Reading surfaces (the puzzle board, quote reveal) honor the user's full
/// large-type preference; rows that mix labels with trailing controls
/// physically break past ~1.3x on narrow phones, so menu/settings/stats
/// screens wrap their bodies in this instead of overflowing.
class ScaleSafe extends StatelessWidget {
  const ScaleSafe({super.key, required this.child, this.max = 1.3});

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(maxScaleFactor: max, child: child);
  }
}
