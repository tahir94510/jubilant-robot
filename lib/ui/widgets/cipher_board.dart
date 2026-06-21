import 'package:flutter/material.dart';

import '../../models/puzzle.dart';
import 'board_metrics.dart';
import 'letter_cell.dart';

/// The puzzle board: the cipher text laid out word by word, wrapping lines,
/// each letter as a tappable [LetterCell]. Identical cipher letters render
/// from one shared guess map, so auto-fill is free.
class CipherBoard extends StatefulWidget {
  const CipherBoard({
    super.key,
    required this.session,
    required this.selected,
    required this.errorChecking,
    required this.onSelect,
    this.selectedIndex,
    this.solveWave,
  });

  final PuzzleSession session;
  final String? selected;

  /// The exact focused cell position in [PuzzleSession.cipherText]. That cell
  /// renders as the prominent [CellState.selected]; the other copies of the
  /// same cipher letter render as the subtler [CellState.related], so the
  /// player can feel which cell the cursor is actually on.
  final int? selectedIndex;
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
  State<CipherBoard> createState() => _CipherBoardState();
}

class _CipherBoardState extends State<CipherBoard> {
  /// One STABLE key per board position, attached to that position's cell so the
  /// focused cell can be scrolled into view. Stable-per-position (never a single
  /// key that migrates between cells) is essential: a migrating GlobalKey would
  /// reparent the cell's AnimatedSwitcher onto a different slot and flash the
  /// previous letter into it ("delete & rewrite" ghosting).
  final Map<int, GlobalKey> _cellKeys = {};

  @override
  void didUpdateWidget(CipherBoard old) {
    super.didUpdateWidget(old);
    // A new puzzle: positions no longer mean the same cells, drop stale keys.
    if (widget.session != old.session) _cellKeys.clear();
    // When the cursor moves (◀ ▶, arrow keys, a tap, or typing auto-advance),
    // keep the focused letter comfortably on screen. The board sits in a scroll
    // viewport ABOVE the controls + keyboard, so centering it there never hides
    // it behind them — a long quote no longer strands the cursor off-screen.
    if (widget.selectedIndex != old.selectedIndex &&
        widget.selectedIndex != null) {
      _scrollFocusedIntoView();
    }
  }

  void _scrollFocusedIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _cellKeys[widget.selectedIndex]?.currentContext;
      if (ctx == null) return;
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5, // center the active letter in the visible area
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final selectedIndex = widget.selectedIndex;
    final solveWave = widget.solveWave;

    final conflicts = session.conflicts;
    final confirmed = session.confirmedLetters;
    final boardFull = session.progress >= 1.0;
    final isLetter = session.alphabet.isLetter;

    final words = session.cipherText.split(' ');
    final totalLetters = session.cipherText.split('').where(isLetter).length;

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
          isLetter: isLetter,
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
            if (isLetter(ch)) {
              final inWave =
                  solveWave != null &&
                  totalLetters > 0 &&
                  letterIndex / totalLetters <= solveWave;
              letterIndex++;
              var state = inWave
                  ? CellState.solved
                  : _stateFor(ch, conflicts, confirmed, boardFull);
              // All copies of the selected letter come back as `selected`;
              // demote every copy except the focused cell to `related` so the
              // cursor's actual position stands out from its siblings.
              if (state == CellState.selected &&
                  selectedIndex != null &&
                  thisPos != selectedIndex) {
                state = CellState.related;
              }
              // Each cell carries its own stable key so the focused one can be
              // found for auto-scroll without ever migrating a key between
              // cells (which would ghost the previous letter on cursor moves).
              cells.add(
                LetterCell(
                  key: _cellKeys.putIfAbsent(thisPos, () => GlobalKey()),
                  cipherLetter: ch,
                  guess: session.guesses[ch],
                  width: cellWidth,
                  state: state,
                  onTap: () => widget.onSelect(thisPos),
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
    Set<String> confirmed,
    bool boardFull,
  ) {
    final session = widget.session;
    if (session.revealed.contains(cipherLetter)) return CellState.revealed;
    // A locked, fully-correct word: shown in its own confirmed color and never
    // mistaken for an in-progress guess. Takes precedence over selection since
    // the cell can't be edited anyway.
    if (confirmed.contains(cipherLetter)) return CellState.confirmed;
    // Error feedback OUTRANKS the selection cue: a conflicting (or, on a full
    // board, a wrong) guess turns red the instant it is typed — even while it
    // is the focused cell — instead of only reddening after the cursor advances.
    if (conflicts.contains(cipherLetter)) return CellState.conflict;
    // Error checking only marks wrong guesses once the board is fully
    // filled, so it nudges instead of spoiling the deduction.
    if (widget.errorChecking &&
        boardFull &&
        session.guesses.containsKey(cipherLetter) &&
        !session.isGuessCorrect(cipherLetter)) {
      return CellState.error;
    }
    // Every instance of the selected cipher letter lights up together —
    // that's the "aha, these are all the same letter" cue.
    if (cipherLetter == widget.selected) return CellState.selected;
    return CellState.normal;
  }
}
