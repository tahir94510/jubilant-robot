import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One-shot entrance for list content: a short fade + 12px rise, staggered a
/// few frames per [index] so a screenful of cards settles like dealt cards
/// instead of popping in as one block. Runs exactly once per build (a plain
/// forward tween — nothing loops, so `pumpAndSettle` and reduced-motion
/// SEMANTICS both stay honest), never intercepts pointers, and under the
/// system "disable animations" accessibility setting renders the child
/// directly with no effect at all.
class Entrance extends StatelessWidget {
  const Entrance({super.key, required this.child, this.index = 0});

  final Widget child;

  /// Position in the list; each step delays the start slightly. Capped so
  /// items far down a long list never feel laggy — by then the player is
  /// scrolling, and rows should simply be there.
  final int index;

  static const Duration _duration = Duration(milliseconds: 260);
  static const Duration _step = Duration(milliseconds: 36);
  static const int _maxSteps = 6;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final delayMs = _step.inMilliseconds * math.min<int>(index, _maxSteps);
    final totalMs = _duration.inMilliseconds + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      // The Interval holds the item invisible through its stagger delay, then
      // eases it in over the shared duration — one tween per item, no timers.
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
