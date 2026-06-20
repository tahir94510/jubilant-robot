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
    this.rows = const ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'],
  });

  /// Keyboard letter rows for the active alphabet. The backspace action key
  /// attaches to the last row; undo/redo/navigation live in a separate strip
  /// (BoardControls) above, so the letter rows stay roomy and never overflow.
  final List<String> rows;

  final Set<String> usedLetters;
  final void Function(String letter) onLetter;
  final VoidCallback onBackspace;

  // The single action key (backspace) is 1.4 letter-widths wide.
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
                rows[i].length + (i == lastRow ? _actionFactor : 0.0);
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
            return _KeyButton(
              onTap: onTap,
              bg: bg ?? palette.keyBg,
              width: (keyWidth * widthFactor) - 5,
              height: keyHeight,
              child: child,
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

/// One keyboard key with a quick press-scale "pop" for tactile feedback, on top
/// of the Material ink ripple. Honors the system "reduce motion" setting.
class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.child,
    required this.onTap,
    required this.bg,
    required this.width,
    required this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color bg;
  final double width;
  final double height;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final motion = !MediaQuery.of(context).disableAnimations;
    final enabled = widget.onTap != null;
    void set(bool v) {
      if (enabled && motion) setState(() => _down = v);
    }

    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: AnimatedScale(
        scale: _down ? 0.90 : 1.0,
        duration: Duration(milliseconds: motion ? 70 : 0),
        curve: Curves.easeOut,
        child: Material(
          color: widget.bg,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: widget.onTap,
            onTapDown: (_) => set(true),
            onTapUp: (_) => set(false),
            onTapCancel: () => set(false),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
