import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../engine/daily_puzzle.dart';
import '../../engine/quote_repository.dart';
import '../../services/haptics_service.dart';
import '../../services/music_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';
import '../../state/progress_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/banner_ad_slot.dart';
import '../widgets/brand_mark.dart';
import '../widgets/page_body.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/streak_badge.dart';
import 'achievements_screen.dart';
import 'packs_screen.dart';
import 'paywall_screen.dart';
import 'puzzle_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/scale_safe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Double-back-to-exit guard: the first back press on the root screen shows a
  // hint and arms a ~2s window; a second press inside it actually leaves the
  // app, so a stray tap never drops the player out mid-session.
  DateTime? _lastBackPress;

  void _handleBack(BuildContext context) {
    final now = DateTime.now();
    final last = _lastBackPress;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPress = now;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.pressBackAgainToExit),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

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
    final l10n = AppLocalizations.of(context);

    final today = DateTime.now();
    // The daily follows the player's language: an English player and a Turkish
    // player each get their own deterministic puzzle of the day.
    final contentLocale = Localizations.localeOf(context).languageCode;
    final daily = selectDaily(repo.dailyPoolFor(contentLocale), today);
    final dailyDone = progress.dailySolvedTodayFor(contentLocale);

    // Packs progress is scoped to the active content language so the Home
    // summary matches the locale-scoped Packs screen — the player only ever
    // reaches their own language's catalog.
    final localeQuotes = repo.forLocale(contentLocale);
    final solvedHere = localeQuotes
        .where((q) => progress.isSolved(q.id))
        .length;

    // The "Continue" card lives in its own Consumer<GameController> below, so it
    // stays fresh without making GameController's per-keystroke notifications
    // (fired while Home sits under the puzzle route) rebuild all of Home.

    return PopScope(
      // Never let the framework pop the root route directly; route the back
      // gesture through the double-press guard instead.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
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
                                    tooltip: l10n.musicToggleTooltip,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      context.read<HapticsService>().tap();
                                      settingsCtl.setMusicAndApply(
                                        !musicOn,
                                        context.read<MusicService>(),
                                      );
                                    },
                                    icon: Icon(
                                      musicOn
                                          ? Icons.music_note_outlined
                                          : Icons.music_off_outlined,
                                    ),
                                  ),
                                  // The streak badge appears only once there is a
                                  // live streak (>=1); a "0" badge is meaningless
                                  // and just clutters the header.
                                  if (progress.displayStreakFor(
                                        contentLocale,
                                      ) >=
                                      1) ...[
                                    const SizedBox(width: 4),
                                    StreakBadge(
                                      streak: progress.displayStreakFor(
                                        contentLocale,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  IconButton(
                                    tooltip: l10n.settingsTooltip,
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
                        PressableScale(
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                context.read<GameController>().start(
                                  daily.quote,
                                  daily: true,
                                  alreadySolved: progress.isSolved(
                                    daily.quote.id,
                                  ),
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
                                        // Flexible + scaleDown: the long German
                                        // label at 320dp and 1.6x text would
                                        // otherwise overflow past the check
                                        // icon; it shrinks to fit instead
                                        // (same policy as the date line below).
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Text(
                                              l10n.homeDailyLabel,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                                color: scheme.primary,
                                              ),
                                            ),
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
                                    // Localized, and kept to a single tidy line:
                                    // long locale dates (e.g. German) scale down to
                                    // fit instead of wrapping mid-phrase.
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                          '#${daily.number} · '
                                          '${DateFormat.MMMMEEEEd(contentLocale).format(today)}',
                                          maxLines: 1,
                                          softWrap: false,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      dailyDone
                                          ? l10n.homeDailySolved
                                          : l10n.homeDailyAwaits(
                                              daily.quote.author,
                                            ),
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
                                          alreadySolved: progress.isSolved(
                                            daily.quote.id,
                                          ),
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PuzzleScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        dailyDone ? l10n.replay : l10n.playNow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- Continue (resume) card, per language ---
                        // Scoped to its own Consumer so GameController's frequent
                        // notifications during play repaint only this small card,
                        // never the whole menu list — while still recomputing
                        // lastOpen/canResume on every game change so it is always
                        // fresh on return. On-brand "Ink & Gold": the gold lives
                        // only in the play chip and overline; the surface is the
                        // theme's own card (consistent across all three themes).
                        Consumer<GameController>(
                          builder: (context, game, _) {
                            // The last non-daily puzzle opened in ANY language,
                            // shown only while it still has a saved, unsolved
                            // attempt. Global (not per-UI-locale) so it appears
                            // immediately on return for every language.
                            final lastOpen = game.lastOpenGlobal();
                            final resumeQuote = lastOpen != null
                                ? repo.byId(lastOpen.quoteId)
                                : null;
                            final canResume =
                                resumeQuote != null &&
                                !progress.isSolved(resumeQuote.id) &&
                                game.hasInProgress(resumeQuote.id);
                            if (!canResume) return const SizedBox.shrink();

                            void resume() {
                              game.start(
                                resumeQuote,
                                daily: false,
                                packId: lastOpen!.packId,
                                // The card only shows for an unsolved quote, but
                                // pass the live state rather than a hard false so
                                // the replay flag is always honest.
                                alreadySolved: progress.isSolved(
                                  resumeQuote.id,
                                ),
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PuzzleScreen(),
                                ),
                              );
                            }

                            // 12px gap below keeps it off the menu tiles (it was
                            // a sibling SizedBox before the Consumer wrap).
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PressableScale(
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: resume,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: scheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              color: scheme.onPrimary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  l10n.homeContinueLabel
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.1,
                                                    color: scheme.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  l10n.homeContinueSubtitle,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.25,
                                                    color: scheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.chevron_right,
                                            color: scheme.onSurface.withValues(
                                              alpha: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // --- Menu tiles ---
                        _MenuTile(
                          icon: Icons.grid_view_rounded,
                          title: l10n.puzzlePacks,
                          subtitle: l10n.packsSolved(
                            solvedHere,
                            localeQuotes.length,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PacksScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MenuTile(
                          icon: Icons.insights_outlined,
                          title: l10n.statistics,
                          subtitle: l10n.statisticsSubtitle,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MenuTile(
                          icon: Icons.emoji_events_outlined,
                          title: l10n.achievements,
                          subtitle: l10n.achievementsUnlocked(
                            progress.unlockedAchievementIds.length,
                          ),
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
                            title: l10n.goPremium,
                            subtitle: l10n.goPremiumSubtitleHome,
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
    return PressableScale(
      child: Card(
        // Clip the ink ripple to the card's rounded corners so taps never
        // flash a sharp rectangle past the edge.
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: palette.textSecondary),
          ),
          trailing: Icon(Icons.chevron_right, color: palette.textFaint),
        ),
      ),
    );
  }
}
