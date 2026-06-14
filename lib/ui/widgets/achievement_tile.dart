import 'package:flutter/material.dart';

import '../../models/achievement.dart';
import '../theme/palette.dart';

/// One achievement row, shared by the Achievements screen and the post-solve
/// celebration so a freshly-earned badge looks exactly like its entry in the
/// collection (same containerized icon, same type, no ad-hoc styling).
class AchievementTile extends StatelessWidget {
  const AchievementTile({
    super.key,
    required this.achievement,
    this.unlocked = true,
    this.isNew = false,
    this.justUnlocked = false,
  });

  final Achievement achievement;

  /// Whether the player has earned it (drives the icon, colour, and check).
  final bool unlocked;

  /// Newly *added* content the player has not seen listed yet (a "NEW" badge).
  final bool isNew;

  /// Earned in this very session (the solve screen): a celebratory trailing
  /// star instead of the plain check mark.
  final bool justUnlocked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final lit = unlocked || justUnlocked;

    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: lit
                ? scheme.primary.withValues(alpha: .14)
                : scheme.onSurface.withValues(alpha: .05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            lit ? achievement.icon : Icons.lock_outline,
            color: lit
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: .3),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: lit ? scheme.onSurface : palette.textSecondary,
                ),
              ),
            ),
            if (isNew) ...[const SizedBox(width: 8), const _NewBadge()],
          ],
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        trailing: justUnlocked
            ? Icon(Icons.star_rounded, color: scheme.tertiary, size: 24)
            : unlocked
            ? Icon(Icons.check_circle, color: scheme.primary, size: 22)
            : null,
      ),
    );
  }
}

/// Small attention chip for content the player has not seen before.
class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.tertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: scheme.onTertiary,
        ),
      ),
    );
  }
}
