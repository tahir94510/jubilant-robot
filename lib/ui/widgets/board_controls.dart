import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/palette.dart';
import 'hold_repeat.dart';

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
/// accelerating cadence (via [HoldRepeatDetector]). A `null` [onPressed]
/// disables it (greyed out, inert) and immediately stops any in-flight repeat.
class _HoldRepeatButton extends StatelessWidget {
  const _HoldRepeatButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    // HoldRepeatDetector drives the press/release outside the gesture arena so
    // it never competes with the IconButton's own ink response. The
    // IconButton's onPressed is a no-op when enabled — the pointer-down
    // already fired the action — but keeps the ripple and accessibility
    // semantics.
    //
    // No Tooltip: these buttons are hold-to-repeat, and a long-press tooltip
    // popped up over the board every time the player held to traverse a word —
    // distracting mid-play. The accessible name is kept via the icon's
    // [semanticLabel] so screen readers still announce the action.
    return HoldRepeatDetector(
      onPressed: onPressed,
      child: IconButton(
        onPressed: enabled ? () {} : null,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          icon,
          size: 24,
          color: enabled ? scheme.onSurface : palette.textFaint,
          semanticLabel: tooltip,
        ),
      ),
    );
  }
}
