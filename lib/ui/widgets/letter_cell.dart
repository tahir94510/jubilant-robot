import 'package:flutter/material.dart';

import '../theme/palette.dart';

enum CellState { normal, selected, related, conflict, revealed, error }

/// One letter slot: player's guess on top, the cipher letter below an
/// underline — the classic newspaper cryptogram layout.
class LetterCell extends StatelessWidget {
  const LetterCell({
    super.key,
    required this.cipherLetter,
    required this.guess,
    required this.state,
    required this.onTap,
    this.width = 26,
  });

  final String cipherLetter;
  final String? guess;
  final CellState state;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;

    final bg = switch (state) {
      CellState.selected => palette.boardCellSelectedBg,
      CellState.related => palette.boardCellRelatedBg,
      _ => palette.boardCellBg,
    };
    final guessColor = switch (state) {
      CellState.conflict => palette.conflict,
      CellState.error => palette.error,
      CellState.revealed => palette.revealed,
      _ => palette.guessText,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: width * 0.96,
              child: Center(
                child: Text(
                  guess ?? '',
                  style: TextStyle(
                    fontSize: width * 0.62,
                    fontWeight: FontWeight.w700,
                    color: guessColor,
                    height: 1,
                  ),
                ),
              ),
            ),
            Container(
              height: 1.6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: state == CellState.selected
                  ? palette.revealed
                  : palette.boardUnderline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 2),
              child: Text(
                cipherLetter,
                style: TextStyle(
                  fontSize: width * 0.40,
                  fontWeight: FontWeight.w600,
                  color: palette.cipherText,
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
