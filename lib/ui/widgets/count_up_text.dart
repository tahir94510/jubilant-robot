import 'package:flutter/material.dart';

/// A whole number that briefly counts up to [value] when it first appears (and
/// animates the delta whenever it changes). Pure [TweenAnimationBuilder], no
/// controller to manage. Honors the platform "reduce motion" setting by
/// snapping straight to the value.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 650),
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || value == 0) {
      return Text('$value', maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    return TweenAnimationBuilder<int>(
      // A fresh key per target so a changed value re-runs the tween from the
      // previous number rather than restarting from zero.
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('$v', maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
    );
  }
}
