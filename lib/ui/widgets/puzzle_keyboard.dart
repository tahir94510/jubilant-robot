import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Custom on-screen A-Z keyboard with large tap targets (the audience skews
/// older) and dimming for letters already assigned somewhere on the board.
class PuzzleKeyboard extends StatelessWidget {
  const PuzzleKeyboard({
    super.key,
    required this.usedLetters,
    required this.onLetter,
    required this.onBackspace,
    required this.onUndo,
    required this.canUndo,
  });

  static const _rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  final Set<String> usedLetters;
  final void Function(String letter) onLetter;
  final VoidCallback onBackspace;
  final VoidCallback onUndo;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    final width = MediaQuery.sizeOf(context).width;
    final keyWidth = ((width - 24) / 10).clamp(28.0, 46.0);
    final keyHeight = (keyWidth * 1.42).clamp(42.0, 58.0);

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
              width: keyWidth * widthFactor,
              height: keyHeight,
              child: Center(child: child),
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
          for (final (i, row) in _rows.indexed)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (i == 2)
                  key(
                    child: Icon(
                      Icons.undo,
                      size: 22,
                      color: canUndo ? palette.keyText : palette.keyUsedText,
                    ),
                    onTap: canUndo ? onUndo : null,
                    widthFactor: 1.4,
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
                if (i == 2)
                  key(
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 22,
                      color: palette.keyText,
                    ),
                    onTap: onBackspace,
                    widthFactor: 1.4,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
