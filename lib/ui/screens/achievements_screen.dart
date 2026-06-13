import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/achievement.dart';
import '../../state/progress_controller.dart';
import '../theme/palette.dart';
import '../widgets/scale_safe.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final unlocked = progress.unlockedAchievementIds;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements (${unlocked.length}/${Achievement.catalog.length})',
        ),
      ),
      body: ScaleSafe(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: Achievement.catalog.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final a = Achievement.catalog[i];
            final isUnlocked = unlocked.contains(a.id);
            return Card(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? scheme.primary.withValues(alpha: .14)
                        : scheme.onSurface.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUnlocked ? a.icon : Icons.lock_outline,
                    color: isUnlocked
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: .3),
                  ),
                ),
                title: Text(
                  a.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? scheme.onSurface
                        : palette.textSecondary,
                  ),
                ),
                subtitle: Text(
                  a.description,
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                trailing: isUnlocked
                    ? Icon(Icons.check_circle, color: scheme.primary, size: 22)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
