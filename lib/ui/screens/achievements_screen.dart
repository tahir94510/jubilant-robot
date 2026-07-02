import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/achievement.dart';
import '../../state/progress_controller.dart';
import '../../state/settings_controller.dart';
import '../widgets/achievement_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/scale_safe.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final unlocked = progress.unlockedAchievementIds;
    // Time-based NEW badges: the controller keeps them for a fixed discovery
    // window after an update ships new content, then they normalize on their
    // own — opening this screen neither reveals nor clears anything.
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(
            context,
          ).achievementsCountTitle(unlocked.length, Achievement.catalog.length),
        ),
      ),
      body: PageBody(
        child: ScaleSafe(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: Achievement.catalog.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = Achievement.catalog[i];
              return AchievementTile(
                achievement: a,
                unlocked: unlocked.contains(a.id),
                isNew: settings.isContentNew(a.addedInVersion),
              );
            },
          ),
        ),
      ),
    );
  }
}
