import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A whole number that animates the delta when [value] CHANGES while on screen,
/// but shows its value immediately on first appearance — entering a screen no
/// longer makes every stat visibly count up from zero (which read as a glitch).
/// Honors the platform "reduce motion" setting by snapping straight to value.
///
/// Rendered with the locale's digit grouping (1.234 / 1,234 / 1 234) and
/// wrapped in a [FittedBox], so a six-figure lifetime stat shrinks to fit its
/// card instead of truncating to an ellipsis.
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

  Widget _number(BuildContext context, int v) {
    final format = NumberFormat.decimalPattern(
      Localizations.maybeLocaleOf(context)?.toString(),
    );
    // scaleDown only: a short number renders at its natural size; a long one
    // shrinks smoothly instead of ellipsizing (stat cards are narrow thirds).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(format.format(v), maxLines: 1, style: widget.style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || _from == widget.value) {
      return _number(context, widget.value);
    }
    return TweenAnimationBuilder<int>(
      // Keyed by the target so a new value re-runs the tween from [_from].
      key: ValueKey(widget.value),
      tween: IntTween(begin: _from, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => _number(context, v),
    );
  }
}
