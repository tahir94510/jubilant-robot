import 'package:flutter/material.dart';

/// A whole number that animates the delta when [value] CHANGES while on screen,
/// but shows its value immediately on first appearance — entering a screen no
/// longer makes every stat visibly count up from zero (which read as a glitch).
/// Honors the platform "reduce motion" setting by snapping straight to value.
class CountUpText extends StatefulWidget {
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
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> {
  // The number the next animation should start FROM. Initialized to the first
  // value so the initial build renders it directly (no count-up on entry).
  late int _from = widget.value;

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    // Only a real change animates; the tween runs from the previous value.
    if (old.value != widget.value) _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || _from == widget.value) {
      return Text(
        '${widget.value}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.style,
      );
    }
    return TweenAnimationBuilder<int>(
      // Keyed by the target so a new value re-runs the tween from [_from].
      key: ValueKey(widget.value),
      tween: IntTween(begin: _from, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '$v',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.style,
      ),
    );
  }
}
