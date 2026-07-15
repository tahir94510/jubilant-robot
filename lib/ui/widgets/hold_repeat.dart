import 'dart:async';

import 'package:flutter/material.dart';

/// Wraps [child] so it fires [onPressed] once on tap and, while held,
/// auto-repeats with an accelerating cadence (a calm first step, then
/// steadily faster) until released or [onPressed] becomes null. Shared by
/// every hold-to-repeat control (board undo/redo/prev/next, the on-screen
/// backspace key) so they all feel identical and the timer logic lives in
/// exactly one place.
///
/// A raw [Listener] (outside the gesture arena) drives the press/release so
/// it never competes with the child's own ink/tap response — [child] should
/// treat its own tap callback as a visual-only no-op (or omit it) since the
/// actual action is driven entirely by this detector.
class HoldRepeatDetector extends StatefulWidget {
  const HoldRepeatDetector({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<HoldRepeatDetector> createState() => _HoldRepeatDetectorState();
}

class _HoldRepeatDetectorState extends State<HoldRepeatDetector> {
  // First auto-repeat waits long enough that a normal tap never triggers it;
  // then the interval ramps down to a floor so a hold accelerates but stays
  // controllable.
  static const Duration _initialDelay = Duration(milliseconds: 380);
  static const int _minIntervalMs = 70;

  Timer? _timer;
  int _intervalMs = 0;

  @override
  void didUpdateWidget(HoldRepeatDetector old) {
    super.didUpdateWidget(old);
    // Reached a boundary (or otherwise disabled) mid-hold: stop repeating.
    if (widget.onPressed == null) _stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fire() {
    final cb = widget.onPressed;
    if (cb == null) {
      _stop();
      return;
    }
    cb();
  }

  void _onTapDown() {
    if (widget.onPressed == null) return;
    _fire(); // immediate single-step response
    _intervalMs = 300;
    _timer = Timer(_initialDelay, _tick);
  }

  void _tick() {
    if (widget.onPressed == null) {
      _stop();
      return;
    }
    _fire();
    // Accelerate toward the floor.
    _intervalMs = (_intervalMs * 0.80).round();
    if (_intervalMs < _minIntervalMs) _intervalMs = _minIntervalMs;
    _timer = Timer(Duration(milliseconds: _intervalMs), _tick);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Opaque so the detector receives pointer events across its ENTIRE
      // bounds, not only where the child happens to paint. With the default
      // deferToChild, a child that paints nothing in some state (an empty or
      // fully transparent region) would swallow the press and the control
      // would silently miss taps — a real hold-to-repeat control must respond
      // anywhere inside its footprint.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onTapDown(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: widget.child,
    );
  }
}
