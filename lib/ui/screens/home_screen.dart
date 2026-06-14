import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../engine/daily_puzzle.dart';
import '../../engine/quote_repository.dart';
import '../../services/music_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';
import '../../state/progress_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/brand_mark.dart';
import '../widgets/page_body.dart';
import '../widgets/streak_badge.dart';
import 'achievements_screen.dart';
import 'packs_screen.dart';
import 'paywall_screen.dart';
import 'puzzle_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/scale_safe.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<QuoteRepository>();
    final progress = context.watch<ProgressController>();
    final economy = context.watch<EconomyController>();
    final settingsCtl = context.read<SettingsController>();
    // Listen to ONLY the music flag so toggling it repaints just the icon,
    // not the whole home screen.
    final musicOn = context.select<SettingsController, bool>(
      (s) => s.settings.music,
    );
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;

    final today = DateTime.now();
    final daily = selectDaily(repo.dailyPool, today);
    final dailyDone = progress.dailySolvedToday;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageBody(
                child: ScaleSafe(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Just the serif wordmark: the logo already greets
                          // the player on the launch screen and the app icon,
                          // so the home header stays clean and uncrowded. It
                          // scales down rather than pushing the controls off a
                          // narrow phone when large system text is on.
                          const Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: BrandWordmark(fontSize: 26),
                            ),
                          ),
                          // The controls keep a bounded text scale so a large
                          // system font can't balloon the streak number and
                          // squeeze the wordmark off a narrow phone. A little
                          // space around the streak badge keeps the three
                          // controls from reading as one cramped cluster.
                          MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // One-tap music mute, mirrored by Settings.
                                IconButton(
                                  tooltip: 'Music on/off',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => settingsCtl.setMusicAndApply(
                                    !musicOn,
                                    context.read<MusicService>(),
                                  ),
                                  icon: Icon(
                                    musicOn
                                        ? Icons.music_note_outlined
                                        : Icons.music_off_outlined,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                StreakBadge(streak: progress.displayStreak),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: 'Settings',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // --- Daily puzzle card ---
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            context.read<GameController>().start(
                              daily.quote,
                              daily: true,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PuzzleScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.today_outlined,
                                      size: 18,
                                      color: scheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DAILY PUZZLE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (dailyDone)
                                      Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: palette.success,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '#${daily.number} · ${DateFormat.MMMMEEEEd().format(today)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dailyDone
                                      ? 'Solved! Come back tomorrow for a new one.'
                                      : 'A ${daily.quote.difficulty.name} cipher by ${daily.quote.author} awaits.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: palette.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: () {
                                    context.read<GameController>().start(
                                      daily.quote,
                                      daily: true,
                                    );
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const PuzzleScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    dailyDone ? 'Replay' : 'Play now',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // --- Menu tiles ---
                      _MenuTile(
                        icon: Icons.grid_view_rounded,
                        title: 'Puzzle packs',
                        subtitle:
                            '${progress.stats.solvedIds.length} of ${repo.all.length} solved',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PacksScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.insights_outlined,
                        title: 'Statistics',
                        subtitle: 'Streaks, times, and your heatmap',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.emoji_events_outlined,
                        title: 'Achievements',
                        subtitle:
                            '${progress.unlockedAchievementIds.length} unlocked',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        ),
                      ),
                      if (!economy.premium) ...[
                        const SizedBox(height: 10),
                        _MenuTile(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Go Premium',
                          subtitle:
                              'Remove ads · unlimited hints · bonus packs',
                          accent: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PaywallScreen(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const BannerAdSlot(slotName: 'home'),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Card(
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (accent ? scheme.tertiary : scheme.primary).withValues(
              alpha: .12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accent ? scheme.tertiary : scheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: palette.textSecondary),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: scheme.onSurface.withValues(alpha: .3),
        ),
      ),
    );
  }
}
