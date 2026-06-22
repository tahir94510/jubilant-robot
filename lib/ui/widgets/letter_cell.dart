import 'package:flutter/material.dart';

import '../theme/palette.dart';

enum CellState {
  normal,
  selected,
  related,
  conflict,
  revealed,
  confirmed,
  error,
  solved,
}

/// One letter slot: player's guess on top, the cipher letter below an
/// underline — the classic newspaper cryptogram layout.
///
/// The selected state uses a light fill + accent border + thick underline
/// (an opaque slab looked heavy and hid the cipher letter on dark themes),
/// and state changes ease over 120ms so selection feels alive.
class LetterCell extends StatelessWidget {
  const LetterCell({
    super.key,
    required this.cipherLetter,
    required this.guess,
    required this.state,
    required this.onTap,
    this.focused = false,
    this.related = false,
    this.recent = false,
    this.width = 26,
  });

  final String cipherLetter;
  final String? guess;

  /// The COLOR meaning of the cell (normal/conflict/error/revealed/confirmed/
  /// solved) — independent of selection so a red cell can still look selected.
  final CellState state;

  /// This exact cell holds the cursor (accent frame + thick underline).
  final bool focused;

  /// A sibling copy of the focused letter (quiet "same letter" cue).
  final bool related;

  /// This cell holds the player's most-recently-entered letter (that letter,
  /// wherever it appears): a soft gold highlight — stronger than [related],
  /// quieter than the live cursor — that keeps the eye anchored on the last
  /// guess after the cursor auto-advances. The controller drops it the moment
  /// the puzzle is solved, so a finished board reads clean.
  final bool recent;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    // Selection is now a flag composed over the color state, so a wrong/
    // conflicting cell still shows the cursor frame when tapped to be fixed.
    final selected = focused;
    // A letter the player typed (a plain guess, not a hint reveal or a
    // celebration cell): mark it with a faint fill so your own progress reads
    // at a glance. Never implies correctness.
    final playerFilled =
        state == CellState.normal && guess != null && guess!.isNotEmpty;
    // Honor the system "remove animations" accessibility setting: snap
    // instantly instead of easing.
    final motion = !MediaQuery.of(context).disableAnimations;

    final guessColor = switch (state) {
      CellState.conflict => palette.conflict,
      CellState.error => palette.error,
      CellState.revealed => palette.revealed,
      // A word the player completed correctly: locked, in its own color.
      CellState.confirmed => palette.confirmed,
      // The post-solve wave: letters light up in success green one by one.
      CellState.solved => palette.success,
      _ => palette.guessText,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: motion ? 120 : 0),
        curve: Curves.easeOut,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: selected
              ? palette.boardCellSelectedBg
              : related
              ? palette.boardCellRelatedBg
              : state == CellState.confirmed
              ? palette.boardCellConfirmedBg
              // The last-entered letter: a gold tint between "related" and the
              // live cursor, so the just-typed answer stays visible at a glance.
              : recent
              ? palette.revealed.withValues(alpha: 0.13)
              : playerFilled
              ? palette.boardCellFilledBg
              : palette.boardCellBg,
          borderRadius: BorderRadius.circular(6),
          // Focused cell: full accent border. Sibling copies: a faint accent
          // so they read as "same letter" without competing with the cursor.
          // CONSTANT width on every state: a BoxDecoration border is laid out
          // as padding around the child, so a varying width would change the
          // cell's size on selection and re-flow the word Row / Wrap (the
          // "titreme" jitter). Only the COLOR changes between states now —
          // unfocused cells keep a transparent 1.6px border so geometry is
          // identical to the focused cell.
          border: Border.all(
            color: selected
                ? palette.revealed
                : related
                ? palette.revealed.withValues(alpha: 0.30)
                : recent
                ? palette.revealed.withValues(alpha: 0.50)
                : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: width * 0.96,
              child: Center(
                // New guesses pop in with a quick scale for tactile feel.
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: motion ? 140 : 0),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    guess ?? '',
                    key: ValueKey(guess),
                    style: TextStyle(
                      fontSize: width * 0.62,
                      fontWeight: FontWeight.w700,
                      color: guessColor,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            // The underline lives in a FIXED-height slot so selecting a cell
            // can never change the cell's total height. Earlier the height
            // animated 1.6<->2.4, and since selection moves on every keystroke
            // (auto-advance) and on delete, that 0.8px change re-flowed the
            // word Row and rippled through the Wrap — the "git-gel" jitter.
            // Now only the visible thickness animates inside the constant slot.
            SizedBox(
              height: 2.4,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: motion ? 120 : 0),
                  height: selected ? 2.4 : 1.6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: state == CellState.confirmed
                      ? palette.confirmed
                      : state == CellState.solved
                      ? palette.success
                      : selected
                      ? palette.revealed
                      : palette.boardUnderline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 2),
              child: Text(
                cipherLetter,
                style: TextStyle(
                  fontSize: width * 0.40,
                  fontWeight: FontWeight.w600,
                  color: selected ? palette.revealed : palette.cipherText,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Punctuation/space rendered inline with the cells.
class PunctuationCell extends StatelessWidget {
  const PunctuationCell({super.key, required this.char, this.width = 14});

  final String char;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    return SizedBox(
      width: char == ' ' ? width * 0.6 : width,
      child: Padding(
        padding: EdgeInsets.only(top: width * 0.5),
        child: Text(
          char == ' ' ? '' : char,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: width * 1.1,
            fontWeight: FontWeight.w700,
            color: palette.guessText,
          ),
        ),
      ),
    );
  }
}
