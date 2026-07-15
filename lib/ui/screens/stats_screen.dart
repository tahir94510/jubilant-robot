import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/progress_controller.dart';
import '../theme/palette.dart';
import '../widgets/count_up_text.dart';
import '../widgets/heatmap_calendar.dart';
import '../widgets/page_body.dart';
import '../widgets/scale_safe.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _fmtTime(int? seconds) {
    if (seconds == null) return '--:--'; // no solve recorded yet
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    // Stats are per content language: a player's Turkish profile is separate
    // from their English one.
    final locale = Localizations.localeOf(context).languageCode;
    final stats = progress.statsFor(locale);
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);

    // These dense 3-up cards keep a bounded text scale so a large system
    // font can't overflow or crush them on a narrow phone. Explicit line
    // heights so the fixed slots below can be sized exactly.
    const valueStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    const labelFontSize = 12.0;
    const labelLineHeight = 1.3;
    // [animateTo] != null renders an animated count-up; otherwise [value]
    // (used for the non-numeric fastest-time "m:ss" / "--:--").
    //
    // Every element sits in a FIXED-HEIGHT slot (icon, value, a two-line label
    // area) so all six cards are pixel-identical in height and the numbers sit
    // on the same baseline across the whole grid — regardless of whether a
    // language's label wraps to one line or two. Centering the whole column
    // instead (the old layout) shifted the numbers up and down per card.
    Widget statCard(
      String value,
      String label,
      IconData icon, {
      int? animateTo,
    }) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: Builder(
              builder: (context) {
                // Slot heights follow the effective (clamped) text scale so
                // large-font users get taller — but still uniform — cards.
                final scaler = MediaQuery.textScalerOf(context);
                final valueSlot = scaler.scale(valueStyle.fontSize!) * 1.2;
                final labelSlot =
                    scaler.scale(labelFontSize) * labelLineHeight * 2;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 22, color: scheme.primary),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: valueSlot,
                      child: Center(
                        child: animateTo != null
                            ? CountUpText(value: animateTo, style: valueStyle)
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  value,
                                  maxLines: 1,
                                  style: valueStyle,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: labelSlot,
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: labelFontSize,
                            height: labelLineHeight,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    final dailySolved = stats.dailyHistory.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: PageBody(
        child: ScaleSafe(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // First run: a friendly note so the all-zero grid reads as a
              // fresh start, not a broken screen.
              if (stats.totalSolved == 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          color: scheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.statsFirstRun,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              // IntrinsicHeight + stretch keeps all three cards the same height
              // even when a translated label wraps to two lines (common in
              // TR/DE/FR/PT) — otherwise the longer card grows and the row
              // reads ragged.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statCard(
                      '${stats.totalSolved}',
                      l10n.statPuzzlesSolved,
                      Icons.extension_outlined,
                      animateTo: stats.totalSolved,
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      '${progress.displayStreakFor(locale)}',
                      l10n.statCurrentStreak,
                      Icons.local_fire_department_outlined,
                      animateTo: progress.displayStreakFor(locale),
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      '${stats.bestStreak}',
                      l10n.statBestStreak,
                      Icons.star_outline,
                      animateTo: stats.bestStreak,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statCard(
                      _fmtTime(stats.bestTimeSeconds),
                      l10n.statFastestSolve,
                      Icons.bolt_outlined,
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      '${stats.noHintSolves}',
                      l10n.statNoHintSolves,
                      Icons.do_not_touch_outlined,
                      animateTo: stats.noHintSolves,
                    ),
                    const SizedBox(width: 10),
                    statCard(
                      '$dailySolved',
                      l10n.statDailiesSolved,
                      Icons.today_outlined,
                      animateTo: dailySolved,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statsDailyActivity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      HeatmapCalendar(dailyHistory: stats.dailyHistory),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
