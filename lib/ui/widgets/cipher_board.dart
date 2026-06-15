import 'package:flutter/material.dart';

import '../../models/puzzle.dart';
import 'board_metrics.dart';
import 'letter_cell.dart';

/// The puzzle board: the cipher text laid out word by word, wrapping lines,
/// each letter as a tappable [LetterCell]. Identical cipher letters render
/// from one shared guess map, so auto-fill is free.
class CipherBoard extends StatelessWidget {
  const CipherBoard({
    super.key,
    required this.session,
    required this.selected,
    required this.errorChecking,
    required this.onSelect,
    this.solveWave,
  });

  final PuzzleSession session;
  final String? selected;
  final bool errorChecking;

  /// Called with the tapped cell's POSITION in [PuzzleSession.cipherText], not
  /// its letter: the cursor must pin to the exact cell so typing advances from
  /// there rather than from a repeated letter's first occurrence.
  final void Function(int charIndex) onSelect;

  /// 0..1 progress of the post-solve celebration: cells up to this share of
  /// the text light up in success color, sweeping left to right. Null when
  /// the puzzle is still being solved.
  final double? solveWave;

  @override
  Widget build(BuildContext context) {
    final conflicts = session.conflicts;
    final boardFull = session.progress >= 1.0;

    final words = session.cipherText.split(' ');
    final totalLetters = session.cipherText
        .split('')
        .where(isBoardLetter)
        .length;

    // Cell width adapts to screen and quote length so long quotes still fit
    // comfortably; text scale is applied by MediaQuery at app level. The
    // longest word then caps the width further so a single 15-letter word
    // shrinks the whole board evenly instead of overflowing the row
    // (words render as non-wrapping Rows inside the Wrap below).
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final preferred = (screenWidth / 13.5).clamp(22.0, 34.0);
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenWidth;
        final cellWidth = fitCellWidth(
          preferred: preferred,
          availableWidth: available,
          words: words,
        );

        var letterIndex = 0;
        // Absolute position in cipherText. words come from split(' '), which
        // drops one space between each pair, so we step over that separator
        // after every word to keep the index aligned with the real string.
        var charPos = 0;
        final wordRows = <Widget>[];
        for (final word in words) {
          final cells = <Widget>[];
          for (final ch in word.split('')) {
            final thisPos = charPos;
            charPos++;
            if (isBoardLetter(ch)) {
              final inWave =
                  solveWave != null &&
                  totalLetters > 0 &&
                  letterIndex / totalLetters <= solveWave!;
              letterIndex++;
              cells.add(
                LetterCell(
                  cipherLetter: ch,
                  guess: session.guesses[ch],
                  width: cellWidth,
                  state: inWave
                      ? CellState.solved
                      : _stateFor(ch, conflicts, boardFull),
                  onTap: () => onSelect(thisPos),
                ),
              );
            } else {
              cells.add(
                PunctuationCell(
                  char: ch,
                  width: cellWidth * kPunctuationCellFactor,
                ),
              );
            }
          }
          charPos++; // the space separator that split(' ') removed
          wordRows.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
        }

        return Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 14,
          spacing: cellWidth * 0.45,
          children: wordRows,
        );
      },
    );
  }

  CellState _stateFor(
    String cipherLetter,
    Set<String> conflicts,
    bool boardFull,
  ) {
    if (session.revealed.contains(cipherLetter)) return CellState.revealed;
    // Every instance of the selected cipher letter lights up together —
    // that's the "aha, these are all the same letter" cue.
    if (cipherLetter == selected) return CellState.selected;
    if (conflicts.contains(cipherLetter)) return CellState.conflict;
    // Error checking only marks wrong guesses once the board is fully
    // filled, so it nudges instead of spoiling the deduction.
    if (errorChecking &&
        boardFull &&
        session.guesses.containsKey(cipherLetter) &&
        !session.isGuessCorrect(cipherLetter)) {
      return CellState.error;
    }
    return CellState.normal;
  }
}
