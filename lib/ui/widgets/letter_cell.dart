import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context);
    // A hint-revealed or confirmed-word cell is locked: announce it as
    // non-interactive so a screen reader doesn't invite a tap that does nothing.
    final locked = state == CellState.revealed || state == CellState.confirmed;
    final hasGuess = guess != null && guess!.isNotEmpty;
    final semanticLabel = hasGuess
        ? l10n.a11yLetterCellFilled(cipherLetter, guess!)
        : l10n.a11yLetterCellEmpty(cipherLetter);

    return Semantics(
      label: semanticLabel,
      button: !locked,
      enabled: onTap != null,
      onTap: onTap,
      // One combined label per cell; the inner cipher + guess glyphs are
      // decorative, so a screen reader reads "Letter X, answer Y" once instead
      // of announcing two stray single letters.
      child: ExcludeSemantics(
        child: GestureDetector(
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
                  // The last LOCKED letter (by a hint or by completing a word):
                  // the chess-style "last move" fill, shown ABOVE the confirmed
                  // backdrop so the latest locked letter stands out from the
                  // other confirmed ones — and never as the cursor (it has no
                  // frame).
                  : recent
                  ? palette.boardCellLastMoveBg
                  // Other letters of a fully-correct word: their own calm
                  // confirmed backdrop.
                  : state == CellState.confirmed
                  ? palette.boardCellConfirmedBg
                  // Sibling copies of the focused letter: a faint "same letter"
                  // wash, quieter than the last move.
                  : related
                  ? palette.boardCellRelatedBg
                  : playerFilled
                  ? palette.boardCellFilledBg
                  : palette.boardCellBg,
              borderRadius: BorderRadius.circular(6),
              // ONLY the focused cell carries a frame now: the last-move and
              // sibling cues moved to fills (above), so a gold frame means
              // exactly one thing — "the cursor is here" — and never competes
              // with the last-move highlight or the copies. CONSTANT 1.6px width
              // (transparent when unfocused): a BoxDecoration border is laid out
              // as padding, so a varying width would resize the cell on selection
              // and re-flow the word Row / Wrap (the "titreme" jitter).
              border: Border.all(
                color: selected ? palette.revealed : Colors.transparent,
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
    // Spaces and punctuation are layout-only; a screen reader should skip
    // straight from one playable letter to the next.
    return ExcludeSemantics(
      child: SizedBox(
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
      ),
    );
  }
}
