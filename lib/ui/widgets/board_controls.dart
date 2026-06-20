import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/palette.dart';

/// A compact, centered strip of cursor + history controls shown just above the
/// keyboard: previous letter, undo, redo, next letter. Kept off the letter rows
/// so the keyboard stays roomy and never overflows; the four fixed-size icon
/// buttons can't overflow either (icons don't grow with the text scale).
///
/// Each button supports hold-to-repeat: a single tap moves one step, but
/// holding it down auto-repeats with an accelerating cadence (a calm first
/// step, then steadily faster) so a long word can be traversed without
/// hammering — yet it never "flies off", because the repeat halts the moment
/// the action reaches its boundary (the disabled callback turns the button off
/// and cancels the held timer).
class BoardControls extends StatelessWidget {
  const BoardControls({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onUndo,
    required this.onRedo,
    required this.canPrev,
    required this.canNext,
    required this.canUndo,
    required this.canRedo,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canPrev;
  final bool canNext;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _HoldRepeatButton(
          icon: Icons.chevron_left,
          tooltip: l10n.actionPrev,
          onPressed: canPrev ? onPrev : null,
        ),
        _HoldRepeatButton(
          icon: Icons.undo,
          tooltip: l10n.actionUndo,
          onPressed: canUndo ? onUndo : null,
        ),
        _HoldRepeatButton(
          icon: Icons.redo,
          tooltip: l10n.actionRedo,
          onPressed: canRedo ? onRedo : null,
        ),
        _HoldRepeatButton(
          icon: Icons.chevron_right,
          tooltip: l10n.actionNext,
          onPressed: canNext ? onNext : null,
        ),
      ],
    );
  }
}

/// An [IconButton] that fires once on tap and, while held, auto-repeats with an
/// accelerating cadence. A `null` [onPressed] disables it (greyed out, inert)
/// and immediately stops any in-flight repeat.
class _HoldRepeatButton extends StatefulWidget {
  const _HoldRepeatButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  State<_HoldRepeatButton> createState() => _HoldRepeatButtonState();
}

class _HoldRepeatButtonState extends State<_HoldRepeatButton> {
  // First auto-repeat waits long enough that a normal tap never triggers it;
  // then the interval ramps down to a floor so a hold accelerates but stays
  // controllable.
  static const Duration _initialDelay = Duration(milliseconds: 380);
  static const int _minIntervalMs = 70;

  Timer? _timer;
  int _intervalMs = 0;

  @override
  void didUpdateWidget(_HoldRepeatButton old) {
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
    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;

    // A raw Listener (outside the gesture arena) drives the press/release so it
    // never competes with the IconButton's own ink response. The IconButton's
    // onPressed is a no-op when enabled — the pointer-down already fired the
    // action — but keeps the ripple, tooltip and accessibility semantics.
    return Listener(
      onPointerDown: (_) => _onTapDown(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: IconButton(
        tooltip: widget.tooltip,
        onPressed: enabled ? () {} : null,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          widget.icon,
          size: 24,
          color: enabled ? scheme.onSurface : palette.textFaint,
        ),
      ),
    );
  }
}
