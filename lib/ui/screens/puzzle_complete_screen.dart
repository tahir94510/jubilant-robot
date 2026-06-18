import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../config/app_config.dart';
import '../../engine/daily_puzzle.dart';
import '../../engine/quote_repository.dart';
import '../../models/achievement.dart';
import '../../models/pack.dart';
import '../../models/quote.dart';
import '../../services/ads/ads_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/review_service.dart';
import '../../services/share_service.dart';
import '../../services/sound_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';
import '../../state/progress_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/achievement_tile.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/scale_safe.dart';
import 'puzzle_screen.dart';

/// Post-solve celebration: full quote with attribution, solve stats, share
/// (for the daily), and the next-puzzle flow. This screen is where the
/// interstitial cadence and the review prompt live.
class PuzzleCompleteScreen extends StatefulWidget {
  const PuzzleCompleteScreen({super.key});

  @override
  State<PuzzleCompleteScreen> createState() => _PuzzleCompleteScreenState();
}

class _PuzzleCompleteScreenState extends State<PuzzleCompleteScreen> {
  bool _recorded = false;
  List<Achievement> _newAchievements = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordOnce());
  }

  Future<void> _recordOnce() async {
    if (_recorded || !mounted) return;
    _recorded = true;

    final game = context.read<GameController>();
    final progress = context.read<ProgressController>();
    final economy = context.read<EconomyController>();
    final ads = context.read<AdsService>();
    final session = game.session;
    if (session == null) return;

    // Replays of an already-solved puzzle never earn tokens, advance the
    // interstitial cadence, or trigger prompts — otherwise the shortest
    // puzzle would become a free hint-token farm.
    final firstSolve = !progress.isSolved(session.quote.id);

    final fresh = await progress.recordSolve(
      quoteId: session.quote.id,
      solveTime: game.elapsed,
      hintsUsed: game.hintsUsed,
      isDaily: game.isDaily,
      // Record into the puzzle's own language so each language keeps its own
      // solves, streak and pack progress.
      locale: session.quote.locale,
    );

    if (mounted && fresh.isNotEmpty) {
      setState(() => _newAchievements = fresh);
      context.read<SoundService>().achievement();
    }

    if (firstSolve) {
      economy.onPuzzleCompleted();
      // Gentle monetization: interstitial only every Nth solve + cooldown,
      // and the review prompt exactly once after the Nth lifetime solve.
      await ads.maybeShowInterstitial(completedCount: economy.completedCount);
      await ReviewService().maybeRequestReview(
        totalSolved: progress.aggregate.totalSolved,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameController>();
    final progress = context.read<ProgressController>();
    final repo = context.read<QuoteRepository>();
    final settingsController = context.watch<SettingsController>();
    final session = game.session;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final motion = !MediaQuery.of(context).disableAnimations;
    final l10n = AppLocalizations.of(context);

    // The one-time streak-protection invite: the moment a player finishes
    // their first daily is when a reminder is most welcome — and Settings
    // is where nobody would find it on their own.
    final showReminderNudge =
        game.isDaily &&
        context.read<NotificationService>().supported &&
        !settingsController.settings.reminderEnabled &&
        !settingsController.settings.reminderNudgeDone;

    if (session == null) return const Scaffold(body: SizedBox.shrink());

    final quote = session.quote;
    final minutes = game.elapsed.inMinutes;
    final seconds = (game.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    // A fresh achievement (or a weekly streak milestone) upgrades the
    // confetti; the key swap replays the burst when achievements land a
    // frame after entry.
    final streak = progress.displayStreakFor(quote.locale);
    final bigCelebration =
        _newAchievements.isNotEmpty ||
        (game.isDaily && streak > 0 && streak % 7 == 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: Text(
          game.isDaily ? l10n.completeDailyTitle : l10n.completeTitle,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Cap + center the celebration content on large screens; the
            // confetti below still covers the full viewport.
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                        children: [
                          // A small celebratory pop on entrance (skipped when the
                          // system "remove animations" setting is on).
                          if (motion)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.4, end: 1),
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.elasticOut,
                              builder: (context, scale, child) =>
                                  Transform.scale(scale: scale, child: child),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: palette.success,
                              ),
                            )
                          else
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: palette.success,
                            ),
                          const SizedBox(height: 14),
                          Text(
                            '\u{201C}${quote.text}\u{201D}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 22,
                              height: 1.45,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '\u{2014} ${quote.author}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: palette.textSecondary,
                            ),
                          ),
                          Text(
                            quote.source,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.textFaint,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Wrap, not Row: with three chips (daily) on a narrow
                          // phone the row overflowed; now extras flow to a new line.
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              _StatChip(
                                icon: Icons.timer_outlined,
                                label: '$minutes:$seconds',
                              ),
                              _StatChip(
                                icon: Icons.lightbulb_outline,
                                label: l10n.solveHints(game.hintsUsed),
                              ),
                              if (game.isDaily)
                                _StatChip(
                                  icon: Icons.local_fire_department_outlined,
                                  label: l10n.solveStreak(streak),
                                ),
                            ],
                          ),
                          if (_newAchievements.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              l10n.achievementsUnlockedHeader(
                                _newAchievements.length,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final e in _newAchievements.asMap().entries)
                              _AchievementEntrance(
                                index: e.key,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AchievementTile(
                                    achievement: e.value,
                                    justUnlocked: true,
                                  ),
                                ),
                              ),
                          ],
                          if (showReminderNudge) ...[
                            const SizedBox(height: 20),
                            _ReminderNudgeCard(controller: settingsController),
                          ],
                        ],
                      ),
                    ),
                    // Actions stay pinned above the banner so "Back to menu" is
                    // always reachable without scrolling — on 360x800 phones the
                    // buttons used to sit below the fold inside the list.
                    ScaleSafe(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (game.isDaily)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => _shareDaily(context),
                                  icon: const Icon(Icons.share_outlined),
                                  label: Text(l10n.shareResult),
                                ),
                              )
                            else if (_nextInPack(repo, game) != null)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    final next = _nextInPack(repo, game)!;
                                    game.start(
                                      next,
                                      daily: false,
                                      packId: game.originPackId,
                                      alreadySolved: progress.isSolved(next.id),
                                    );
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const PuzzleScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: Text(l10n.nextPuzzle),
                                ),
                              ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).popUntil((r) => r.isFirst),
                                child: Text(l10n.backToMenu),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const BannerAdSlot(slotName: 'complete'),
                  ],
                ),
              ),
            ),
            // Confetti overlays everything but never blocks taps; the key
            // swap replays a bigger burst when fresh achievements land a
            // frame after entry.
            Positioned.fill(
              child: ConfettiBurst(
                key: ValueKey(bigCelebration),
                particleCount: bigCelebration ? 150 : 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareDaily(BuildContext context) {
    final game = context.read<GameController>();
    final progress = context.read<ProgressController>();
    final l10n = AppLocalizations.of(context);
    const share = ShareService();
    final number = puzzleNumberFor(DateTime.now());
    final solvedIn = l10n.shareSolvedIn(
      ShareService.formatSolveTime(game.elapsed),
    );
    final streak = progress.displayStreakFor(
      game.session?.quote.locale ?? 'en',
    );
    final streakPart = streak >= 2
        ? '  \u{1F525} ${l10n.solveStreak(streak)}'
        : '';
    final text =
        '${AppConfig.appName} #$number \u{00B7} '
        '$solvedIn, ${l10n.solveHints(game.hintsUsed)}$streakPart\n'
        '${AppConfig.listingUrl}';
    share.share(text);
  }

  /// Next unsolved quote in the originating pack, easiest-first.
  Quote? _nextInPack(QuoteRepository repo, GameController game) {
    final packId = game.originPackId;
    if (packId == null) return null;
    final progress = context.read<ProgressController>();
    final quotes = repo.forPack(
      Pack.byId(packId),
      activeLocale: game.session?.quote.locale ?? 'en',
    );
    for (final q in quotes) {
      if (!progress.isSolved(q.id) && q.id != game.session?.quote.id) {
        return q;
      }
    }
    return null;
  }
}

/// One-time invite to enable the daily reminder, shown right after a daily
/// solve. Either answer dismisses it forever; the time (default 9:00) can
/// be changed later in Settings.
class _ReminderNudgeCard extends StatelessWidget {
  const _ReminderNudgeCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alarm_outlined, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reminderNudgeTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.reminderNudgeBody,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: .6),
              ),
            ),
            const SizedBox(height: 14),
            // Full-width stacked actions: the primary choice is prominent and
            // both buttons share one clean alignment at any text size (the old
            // right-wrapped pair stacked unevenly on some devices).
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final ok = await controller.setReminder(enabled: true);
                  await controller.markReminderNudgeDone();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.reminderNudgeDenied)),
                    );
                  }
                },
                child: Text(l10n.remindMeDaily),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => controller.markReminderNudgeDone(),
                child: Text(l10n.reminderNudgeNo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
      ),
      // The chip shrinks gracefully instead of overflowing when huge system
      // text meets a narrow phone (the on-device "26 px" stripe).
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: .6)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// A staggered fade-and-rise entrance for each freshly unlocked achievement
/// tile, so they cascade in instead of popping. Honors the system
/// "reduce motion" setting by rendering the child instantly.
class _AchievementEntrance extends StatelessWidget {
  const _AchievementEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    final start = (index * 0.18).clamp(0.0, 0.8).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Interval(start, 1, curve: Curves.easeOutBack),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
