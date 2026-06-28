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
    this.lastLockedPositions = const <int>{},
    this.lastTyped,
  });

  final PuzzleSession session;
  final String? selected;

  /// The exact focused cell position in [PuzzleSession.cipherText]. That cell
  /// gets the prominent focus frame; the other copies of the same cipher letter
  /// get the subtler "related" cue, so the player can feel which cell the cursor
  /// is actually on — layered ON TOP of the cell's color so a wrong/conflicting
  /// cell still shows it's selected.
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

  /// Board POSITIONS (cipherText indices) LOCKED by the most recent action: the
  /// cells of the word a guess just completed, or the cells a hint just revealed.
  /// Position-based so the calm "just locked" cue lands ONLY on those cells —
  /// never on copies of the same letters in other (already-locked or unfinished)
  /// words. Empty while reviewing or celebrating (no highlight then).
  final Set<int> lastLockedPositions;

  /// The most-recently TYPED still-editable cipher letter; every copy gets a
  /// quiet neutral fill that tracks the player's last keystroke after the cursor
  /// auto-advances. Independent of [lastLocked] (the gold last-LOCKED cue); null
  /// while reviewing or celebrating.
  final String? lastTyped;

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
        // Snap the rendered cell width to a whole logical pixel. A fractional
        // width put every letter (and the word Row + centered Wrap built on it)
        // at sub-pixel x-offsets, so the glyphs shimmered ("titreme") and the
        // board appeared to drift sideways while scrolling. Flooring only shrinks
        // cells, so the fit guarantee from fitCellWidth still holds.
        final cellWidth = fitCellWidth(
          preferred: preferred,
          availableWidth: available,
          words: words,
          isLetter: isLetter,
        ).floorToDouble();

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
              // Color (what the guess MEANS) and selection (WHERE the cursor is)
              // are independent: a wrong/conflicting cell must read red AND still
              // show the selection frame when it's tapped to be fixed. So the
              // color state never encodes selection, and focus/related are passed
              // as flags the cell composes on top of the color.
              final colorState = inWave
                  ? CellState.solved
                  : _colorStateFor(ch, conflicts, confirmed, boardFull);
              final focused = thisPos == selectedIndex;
              final related =
                  !focused && widget.selected != null && ch == widget.selected;
              // The just-locked cells (this exact position only): the calm "just
              // locked" cue. Position-based, so completing a word highlights only
              // that word's genuinely-new cells — not copies of its letters
              // elsewhere, and not letters already locked by another word.
              final recent = widget.lastLockedPositions.contains(thisPos);
              // The last TYPED still-editable letter (and every copy): a quiet
              // neutral cue, INDEPENDENT of the locked one. The controller only
              // ever points this at an unlocked letter; we still guard on a
              // present guess so a cleared/undone letter leaves no stray fill.
              final lastTyped =
                  widget.lastTyped != null &&
                  ch == widget.lastTyped &&
                  session.guesses.containsKey(ch);
              // Each cell carries its own stable key so the focused one can be
              // found for auto-scroll without ever migrating a key between
              // cells (which would ghost the previous letter on cursor moves).
              cells.add(
                LetterCell(
                  key: _cellKeys.putIfAbsent(thisPos, () => GlobalKey()),
                  cipherLetter: ch,
                  guess: session.guesses[ch],
                  width: cellWidth,
                  state: colorState,
                  focused: focused,
                  related: related,
                  recent: recent,
                  lastTyped: lastTyped,
                  onTap: () => widget.onSelect(thisPos),
                ),
              );
            } else {
              cells.add(
                PunctuationCell(
                  char: ch,
                  // Whole pixels: a fractional punctuation slot shifted the rest
                  // of the row off the pixel grid (the scroll shimmer/drift).
                  width: (cellWidth * kPunctuationCellFactor).floorToDouble(),
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
          // Whole-pixel word gap so the centered Wrap lays every word row out on
          // the pixel grid — a fractional gap was part of the scroll shimmer.
          spacing: (cellWidth * 0.45).floorToDouble(),
          children: wordRows,
        );
      },
    );
  }

  /// The pure COLOR meaning of a cell — independent of where the cursor is.
  /// Selection (focused/related) is layered on top by [LetterCell], so a
  /// conflicting/wrong cell can read red and still show the selection frame.
  CellState _colorStateFor(
    String cipherLetter,
    Set<String> conflicts,
    Set<String> confirmed,
    bool boardFull,
  ) {
    final session = widget.session;
    if (session.revealed.contains(cipherLetter)) return CellState.revealed;
    // A locked, fully-correct word: its own confirmed color.
    if (confirmed.contains(cipherLetter)) return CellState.confirmed;
    // Error checking governs ALL mistake feedback. A same-letter conflict reads
    // red immediately, but ONLY while error checking is on — turning it off
    // returns conflicting cells to normal (and re-enabling restores them). The
    // board rebuilds when the setting changes, so this flips live, including on
    // resumed / half-finished saved games.
    if (widget.errorChecking && conflicts.contains(cipherLetter)) {
      return CellState.conflict;
    }
    // Error checking also marks wrong guesses once the board is fully filled,
    // so it nudges instead of spoiling the deduction.
    if (widget.errorChecking &&
        boardFull &&
        session.guesses.containsKey(cipherLetter) &&
        !session.isGuessCorrect(cipherLetter)) {
      return CellState.error;
    }
    return CellState.normal;
  }
}
