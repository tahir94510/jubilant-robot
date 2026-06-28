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
import '../widgets/stat_chip.dart';
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

  /// The daily streak AFTER this solve is recorded. Captured post-record (the
  /// screen reads controllers, so it would otherwise show the pre-solve value —
  /// e.g. "0 day streak" on a first daily). Drives the streak chip, which is
  /// hidden until this is >= 1 so a meaningless "0-day streak" never shows.
  int _streak = 0;

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

    // Capture the streak AFTER recording so the chip shows the post-solve value
    // (e.g. "1 day streak" on a first daily, never the pre-solve "0").
    final streak = progress.displayStreakFor(session.quote.locale);
    if (mounted) {
      setState(() {
        _newAchievements = fresh;
        _streak = streak;
      });
      if (fresh.isNotEmpty) context.read<SoundService>().achievement();
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
    final streak = _streak;
    final bigCelebration =
        _newAchievements.isNotEmpty ||
        (game.isDaily && streak > 0 && streak % 7 == 0);

    return Stack(
      children: [
        Scaffold(
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
            child:
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
                                      Transform.scale(
                                        scale: scale,
                                        child: child,
                                      ),
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
                              _StaggeredEntrance(
                                index: 1,
                                child: Text(
                                  '\u{201C}${quote.text}\u{201D}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 22,
                                    height: 1.45,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _StaggeredEntrance(
                                index: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                  ],
                                ),
                              ),
                              // Optional "About this quote" context — rendered
                              // only when the quote carries a note, so the screen
                              // stays clean for the (current) majority without one.
                              if (quote.note != null &&
                                  quote.note!.trim().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _StaggeredEntrance(
                                  index: 3,
                                  child: _AboutQuoteCard(
                                    note: quote.note!.trim(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              // Wrap, not Row: with three chips (daily) on a narrow
                              // phone the row overflowed; now extras flow to a new line.
                              _StaggeredEntrance(
                                index: 3,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    StatChip(
                                      icon: Icons.timer_outlined,
                                      label: '$minutes:$seconds',
                                    ),
                                    StatChip(
                                      icon: Icons.lightbulb_outline,
                                      label: l10n.solveHints(game.hintsUsed),
                                    ),
                                    // Only show the streak chip once there is a
                                    // real streak (>=1) — a "0 day streak" is
                                    // meaningless.
                                    if (game.isDaily && streak >= 1)
                                      StatChip(
                                        icon: Icons
                                            .local_fire_department_outlined,
                                        label: l10n.solveStreak(streak),
                                      ),
                                  ],
                                ),
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
                                for (final e
                                    in _newAchievements.asMap().entries)
                                  _StaggeredEntrance(
                                    index: e.key,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: AchievementTile(
                                        achievement: e.value,
                                        justUnlocked: true,
                                      ),
                                    ),
                                  ),
                              ],
                              if (showReminderNudge) ...[
                                const SizedBox(height: 20),
                                _ReminderNudgeCard(
                                  controller: settingsController,
                                ),
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
                                          alreadySolved: progress.isSolved(
                                            next.id,
                                          ),
                                        );
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PuzzleScreen(),
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
          ),
        ),
        // Celebration confetti overlays the WHOLE screen — including the
        // AppBar — so the burst is never clipped under the header. It ignores
        // pointers and skips entirely for reduced-motion users; the key swap
        // replays a bigger burst when fresh achievements land a frame later.
        Positioned.fill(
          child: ConfettiBurst(
            key: ValueKey(bigCelebration),
            particleCount: bigCelebration ? 150 : 100,
          ),
        ),
      ],
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
    final palette = Theme.of(context).extension<GamePalette>()!;
    final cardColor = Theme.of(context).cardColor;
    final l10n = AppLocalizations.of(context);
    return Container(
      // A branded, on-"Ink & Gold" card: a faint gold sheen over the card
      // surface and a soft gold hairline, so the invite reads as a crafted
      // moment instead of the plain grey panel it used to be.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.primary.withValues(alpha: .28),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(scheme.primary.withValues(alpha: .08), cardColor),
            cardColor,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _GoldMedallion(
                icon: Icons.notifications_active_rounded,
                size: 46,
                iconSize: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.reminderNudgeTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.reminderNudgeBody,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              // AA-compliant on every theme (replaces onSurface@.6).
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Full-width stacked actions: the primary choice is prominent and
          // both buttons share one clean alignment at any text size (the old
          // right-wrapped pair stacked unevenly on some devices).
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final ok = await controller.setReminder(enabled: true);
                await controller.markReminderNudgeDone();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.reminderNudgeDenied)),
                  );
                }
              },
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text(l10n.remindMeDaily),
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
    );
  }
}

/// A circular champagne-gold medallion built from the app's REAL brand golds
/// (the streak flame + the primary accent), not Material's seed-derived
/// `tertiary` — which resolves to an off-brand hue and made the old crown/icon
/// gradients look inconsistent. Shared by the reminder invite and the premium
/// celebration so both wear the same badge.
class _GoldMedallion extends StatelessWidget {
  const _GoldMedallion({
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.streakFlame, scheme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .32),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: scheme.onPrimary),
    );
  }
}

/// "About this quote": a quiet, optional context card shown after a solve when
/// the quote carries a [Quote.note] — who said it, from where, why it matters.
/// Absent for most quotes today, so the screen stays uncluttered until the
/// dataset is enriched language by language.
class _AboutQuoteCard extends StatelessWidget {
  const _AboutQuoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 15, color: palette.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.aboutThisQuote,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // A hairline separates the label from the context, giving the card a
          // quiet "card within the card" structure without a heavy border.
          Container(height: 1, color: scheme.onSurface.withValues(alpha: .07)),
          const SizedBox(height: 10),
          Text(
            note,
            style: TextStyle(
              fontFamily: 'Lora', // echo the quote's own literary serif voice
              fontSize: 14.5,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// A staggered fade-and-rise entrance: each indexed child cascades in (later
/// indices start later) instead of popping — used for the celebration's quote
/// block and for freshly unlocked achievement tiles. Honors the system
/// "reduce motion" setting by rendering the child instantly.
class _StaggeredEntrance extends StatelessWidget {
  const _StaggeredEntrance({required this.index, required this.child});

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
