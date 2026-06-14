import 'package:flutter/material.dart';

import '../theme/palette.dart';

enum CellState { normal, selected, related, conflict, revealed, error, solved }

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
    final selected = state == CellState.selected;
    // Honor the system "remove animations" accessibility setting: snap
    // instantly instead of easing.
    final motion = !MediaQuery.of(context).disableAnimations;

    final guessColor = switch (state) {
      CellState.conflict => palette.conflict,
      CellState.error => palette.error,
      CellState.revealed => palette.revealed,
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
          color: selected ? palette.boardCellSelectedBg : palette.boardCellBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? palette.revealed : Colors.transparent,
            width: 1.4,
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
            AnimatedContainer(
              duration: Duration(milliseconds: motion ? 120 : 0),
              height: selected ? 2.4 : 1.6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: switch (state) {
                CellState.selected => palette.revealed,
                CellState.solved => palette.success,
                _ => palette.boardUnderline,
              },
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
