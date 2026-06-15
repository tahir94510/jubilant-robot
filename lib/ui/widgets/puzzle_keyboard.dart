import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Custom on-screen A-Z keyboard with large tap targets (the audience skews
/// older) and dimming for letters already assigned somewhere on the board.
///
/// Sizing comes from LayoutBuilder constraints (not MediaQuery) and key
/// glyphs sit in FittedBoxes, so neither narrow screens nor large system
/// text can overflow this widget.
class PuzzleKeyboard extends StatelessWidget {
  const PuzzleKeyboard({
    super.key,
    required this.usedLetters,
    required this.onLetter,
    required this.onBackspace,
    required this.onUndo,
    required this.canUndo,
    this.rows = const ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'],
  });

  /// Keyboard letter rows for the active alphabet. The undo/backspace action
  /// keys attach to the last row.
  final List<String> rows;

  final Set<String> usedLetters;
  final void Function(String letter) onLetter;
  final VoidCallback onBackspace;
  final VoidCallback onUndo;
  final bool canUndo;

  // Each action key (undo, backspace) is 1.4 letter-widths wide.
  static const double _actionFactor = 1.4;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    final lastRow = rows.length - 1;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Derive the key width from the widest row so any alphabet (10-key
          // QWERTY, 27-letter Spanish, 29-letter Turkish) fits without
          // overflow. The last row also carries the two action keys.
          var maxUnits = 1.0;
          for (var i = 0; i < rows.length; i++) {
            final double units =
                rows[i].length + (i == lastRow ? _actionFactor * 2 : 0.0);
            if (units > maxUnits) maxUnits = units;
          }
          final keyWidth = ((constraints.maxWidth - 12) / maxUnits).clamp(
            20.0,
            46.0,
          );
          final keyHeight = (keyWidth * 1.42).clamp(40.0, 58.0);

          Widget key({
            required Widget child,
            required VoidCallback? onTap,
            Color? bg,
            double widthFactor = 1,
          }) {
            return Padding(
              padding: const EdgeInsets.all(2.5),
              child: Material(
                color: bg ?? palette.keyBg,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: onTap,
                  child: SizedBox(
                    width: (keyWidth * widthFactor) - 5,
                    height: keyHeight,
                    child: Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: child),
                    ),
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, row) in rows.indexed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (i == lastRow)
                        key(
                          child: Icon(
                            Icons.undo,
                            size: 22,
                            color: canUndo
                                ? palette.keyText
                                : palette.keyUsedText,
                          ),
                          onTap: canUndo ? onUndo : null,
                          widthFactor: _actionFactor,
                        ),
                      for (final ch in row.split(''))
                        key(
                          child: Text(
                            ch,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: usedLetters.contains(ch)
                                  ? palette.keyUsedText
                                  : palette.keyText,
                            ),
                          ),
                          bg: usedLetters.contains(ch)
                              ? palette.keyUsedBg
                              : palette.keyBg,
                          onTap: () => onLetter(ch),
                        ),
                      if (i == lastRow)
                        key(
                          child: Icon(
                            Icons.backspace_outlined,
                            size: 22,
                            color: palette.keyText,
                          ),
                          onTap: onBackspace,
                          widthFactor: _actionFactor,
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
