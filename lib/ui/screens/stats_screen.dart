import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/progress_controller.dart';
import '../theme/palette.dart';
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
    final stats = progress.stats;
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;

    // These dense 3-up cards keep a bounded text scale so a large system
    // font can't overflow or crush them on a narrow phone.
    Widget statCard(String value, String label, IconData icon) => Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: Column(
              children: [
                Icon(icon, size: 22, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final dailySolved = stats.dailyHistory.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
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
                            'Crack today’s cipher to start your stats '
                            'and streak.',
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
              Row(
                children: [
                  statCard(
                    '${stats.totalSolved}',
                    'Puzzles solved',
                    Icons.extension_outlined,
                  ),
                  const SizedBox(width: 10),
                  statCard(
                    '${progress.displayStreak}',
                    'Current streak',
                    Icons.local_fire_department_outlined,
                  ),
                  const SizedBox(width: 10),
                  statCard(
                    '${stats.bestStreak}',
                    'Best streak',
                    Icons.star_outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  statCard(
                    _fmtTime(stats.bestTimeSeconds),
                    'Fastest solve',
                    Icons.bolt_outlined,
                  ),
                  const SizedBox(width: 10),
                  statCard(
                    '${stats.noHintSolves}',
                    'No-hint solves',
                    Icons.do_not_touch_outlined,
                  ),
                  const SizedBox(width: 10),
                  statCard(
                    '$dailySolved',
                    'Dailies solved',
                    Icons.today_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily activity',
                        style: TextStyle(
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
