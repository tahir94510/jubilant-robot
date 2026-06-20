import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/palette.dart';

/// A compact, centered strip of cursor + history controls shown just above the
/// keyboard: previous letter, undo, redo, next letter. Kept off the letter rows
/// so the keyboard stays roomy and never overflows; the four fixed-size icon
/// buttons can't overflow either (icons don't grow with the text scale).
class BoardControls extends StatelessWidget {
  const BoardControls({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;

    Widget btn(IconData icon, String tip, VoidCallback? onTap) => IconButton(
      tooltip: tip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 24,
        color: onTap == null ? palette.textFaint : scheme.onSurface,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.chevron_left, l10n.actionPrev, onPrev),
        btn(Icons.undo, l10n.actionUndo, canUndo ? onUndo : null),
        btn(Icons.redo, l10n.actionRedo, canRedo ? onRedo : null),
        btn(Icons.chevron_right, l10n.actionNext, onNext),
      ],
    );
  }
}
