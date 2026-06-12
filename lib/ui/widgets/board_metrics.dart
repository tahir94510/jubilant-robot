/// Pure geometry helpers for the cipher board. No Flutter imports so the
/// fitting math stays trivially unit-testable.
///
/// These constants mirror the real render geometry: every [LetterCell] adds
/// a 1dp margin on each side and a [PunctuationCell] occupies half a cell.
/// If letter_cell.dart changes, change these together.
library;

const double kLetterCellMargin = 2.0;
const double kPunctuationCellFactor = 0.5;

/// Hard readability floor: below this the guess letters become squinty even
/// on the smallest supported phones.
const double kMinBoardCellWidth = 14.0;

bool isBoardLetter(String ch) =>
    ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90;

/// Width one word occupies on the board at [cellWidth]: letters cost a cell
/// plus margins, punctuation rides along at half a cell.
double wordWidthAt(String word, double cellWidth) {
  var letters = 0;
  var puncts = 0;
  for (final ch in word.split('')) {
    if (isBoardLetter(ch)) {
      letters++;
    } else {
      puncts++;
    }
  }
  return letters * (cellWidth + kLetterCellMargin) +
      puncts * cellWidth * kPunctuationCellFactor;
}

/// Largest uniform cell width (capped at [preferred]) at which every word in
/// [words] fits on a single line of [availableWidth]. Long words shrink the
/// whole board evenly instead of overflowing — the classic 15-letter
/// "generalizations" must never spill off a 360dp phone. A 1px slack absorbs
/// floating-point rounding at exact-fit widths.
double fitCellWidth({
  required double preferred,
  required double availableWidth,
  required Iterable<String> words,
  double minWidth = kMinBoardCellWidth,
}) {
  var cell = preferred;
  for (final word in words) {
    var letters = 0;
    var puncts = 0;
    for (final ch in word.split('')) {
      if (isBoardLetter(ch)) {
        letters++;
      } else {
        puncts++;
      }
    }
    final units = letters + puncts * kPunctuationCellFactor;
    if (units <= 0) continue;
    final fit = (availableWidth - 1.0 - kLetterCellMargin * letters) / units;
    if (fit < cell) cell = fit;
  }
  if (cell < minWidth) return minWidth;
  return cell;
}
