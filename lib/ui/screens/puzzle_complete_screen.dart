import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../engine/daily_puzzle.dart';
import '../../engine/quote_repository.dart';
import '../../models/achievement.dart';
import '../../models/pack.dart';
import '../../models/quote.dart';
import '../../services/ads/ads_service.dart';
import '../../services/review_service.dart';
import '../../services/share_service.dart';
import '../../state/economy_controller.dart';
import '../../state/game_controller.dart';
import '../../state/progress_controller.dart';
import '../theme/palette.dart';
import '../widgets/banner_ad_slot.dart';
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

    final fresh = await progress.recordSolve(
      quoteId: session.quote.id,
      solveTime: game.elapsed,
      hintsUsed: game.hintsUsed,
      isDaily: game.isDaily,
    );
    economy.onPuzzleCompleted();

    if (mounted && fresh.isNotEmpty) {
      setState(() => _newAchievements = fresh);
    }

    // Gentle monetization: interstitial only every Nth solve + cooldown,
    // and the review prompt exactly once after the Nth lifetime solve.
    await ads.maybeShowInterstitial(completedCount: economy.completedCount);
    await ReviewService()
        .maybeRequestReview(totalSolved: progress.stats.totalSolved);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameController>();
    final progress = context.read<ProgressController>();
    final repo = context.read<QuoteRepository>();
    final session = game.session;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;

    if (session == null) return const Scaffold(body: SizedBox.shrink());

    final quote = session.quote;
    final minutes = game.elapsed.inMinutes;
    final seconds = (game.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: Text(game.isDaily ? 'Daily solved!' : 'Solved!'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 56, color: palette.success),
                  const SizedBox(height: 20),
                  Text(
                    '\u{201C}${quote.normalizedText[0]}${quote.normalizedText.substring(1).toLowerCase()}\u{201D}',
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
                      color: scheme.onSurface.withValues(alpha: .65),
                    ),
                  ),
                  Text(
                    quote.source,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: .4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(
                          icon: Icons.timer_outlined,
                          label: '$minutes:$seconds'),
                      const SizedBox(width: 10),
                      _StatChip(
                          icon: Icons.lightbulb_outline,
                          label: game.hintsUsed == 0
                              ? 'No hints'
                              : '${game.hintsUsed} hint${game.hintsUsed == 1 ? '' : 's'}'),
                      if (game.isDaily) ...[
                        const SizedBox(width: 10),
                        _StatChip(
                            icon: Icons.local_fire_department_outlined,
                            label: '${progress.displayStreak} day streak'),
                      ],
                    ],
                  ),
                  if (_newAchievements.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    for (final a in _newAchievements)
                      Card(
                        child: ListTile(
                          leading: Icon(a.icon, color: scheme.primary),
                          title: Text('Achievement: ${a.title}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(a.description),
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                  if (game.isDaily)
                    FilledButton.icon(
                      onPressed: () => _shareDaily(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share result'),
                    )
                  else if (_nextInPack(repo, game) != null)
                    FilledButton.icon(
                      onPressed: () {
                        final next = _nextInPack(repo, game)!;
                        game.start(next,
                            daily: false, packId: game.originPackId);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const PuzzleScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next puzzle'),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('Back to menu'),
                  ),
                ],
              ),
            ),
            const BannerAdSlot(slotName: 'complete'),
          ],
        ),
      ),
    );
  }

  void _shareDaily(BuildContext context) {
    final game = context.read<GameController>();
    final progress = context.read<ProgressController>();
    const share = ShareService();
    final text = share.buildDailyShareText(
      puzzleNumber: puzzleNumberFor(DateTime.now()),
      solveTime: game.elapsed,
      hintsUsed: game.hintsUsed,
      streak: progress.displayStreak,
    );
    share.share(text);
  }

  /// Next unsolved quote in the originating pack, easiest-first.
  Quote? _nextInPack(QuoteRepository repo, GameController game) {
    final packId = game.originPackId;
    if (packId == null) return null;
    final progress = context.read<ProgressController>();
    final quotes = repo.forPack(Pack.byId(packId));
    for (final q in quotes) {
      if (!progress.isSolved(q.id) && q.id != game.session?.quote.id) {
        return q;
      }
    }
    return null;
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurface.withValues(alpha: .6)),
          const SizedBox(width: 5),
          Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
