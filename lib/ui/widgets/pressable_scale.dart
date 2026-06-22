import 'package:flutter/material.dart';

/// Wraps [child] with a tactile "press-down" scale: it eases to a slightly
/// smaller size while a finger is held and springs back on release, giving flat
/// tap targets (cards, tiles) a physical, button-like feel.
///
/// It does NOT consume the gesture — a [Listener] drives the animation from raw
/// pointer events, so the child's own `InkWell`/`ListTile` `onTap` still fires
/// and its ink ripple still shows. A press that turns into a scroll (the pointer
/// drags past the touch slop) releases cleanly, so a card never stays shrunk
/// while the list scrolls. Honors the platform "remove animations" setting.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;

  /// Scale applied while pressed (1.0 = no shrink).
  final double pressedScale;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: widget.pressedScale,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  // Where the finger went down, so a drag past the slop can cancel the press
  // (the gesture is becoming a scroll, not a tap).
  Offset? _downPos;
  static const double _slop = 12;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _release() {
    _downPos = null;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: with animations off, just pass the child through — its own
    // ink ripple still gives press feedback.
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return Listener(
      // Translucent so the child still receives the pointer (taps + ripple).
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _downPos = e.position;
        _controller.forward();
      },
      onPointerMove: (e) {
        final start = _downPos;
        if (start != null && (e.position - start).distance > _slop) {
          _release();
        }
      },
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
