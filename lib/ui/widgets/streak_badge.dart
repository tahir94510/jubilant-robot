import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// The flame + day count shown on the home screen.
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<GamePalette>()!;
    final scheme = Theme.of(context).colorScheme;
    final active = streak > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? palette.streakFlame.withValues(alpha: .14)
            : scheme.onSurface.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 20,
            color: active
                ? palette.streakFlame
                : scheme.onSurface.withValues(alpha: .35),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: active
                  ? palette.streakFlame
                  : scheme.onSurface.withValues(alpha: .45),
            ),
          ),
        ],
      ),
    );
  }
}
