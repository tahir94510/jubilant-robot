import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/achievement.dart';
import '../../state/progress_controller.dart';
import '../../state/settings_controller.dart';
import '../widgets/achievement_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/scale_safe.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // Snapshot the "seen" revision on entry so the NEW badges stay visible for
  // the whole visit, then mark the content seen so they are gone next time.
  late final int _seenSnapshot;

  @override
  void initState() {
    super.initState();
    _seenSnapshot = context
        .read<SettingsController>()
        .settings
        .seenContentVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SettingsController>().markContentSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final unlocked = progress.unlockedAchievementIds;

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
                isNew: a.addedInVersion > _seenSnapshot,
              );
            },
          ),
        ),
      ),
    );
  }
}
