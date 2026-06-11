import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/progress_controller.dart';
import '../widgets/heatmap_calendar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _fmtTime(int? seconds) {
    if (seconds == null) return '\u{2014}';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final stats = progress.stats;
    final scheme = Theme.of(context).colorScheme;

    Widget statCard(String value, String label, IconData icon) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(icon, size: 22, color: scheme.primary),
                  const SizedBox(height: 8),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurface.withValues(alpha: .55))),
                ],
              ),
            ),
          ),
        );

    final dailySolved = stats.dailyHistory.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            statCard('${stats.totalSolved}', 'Puzzles solved',
                Icons.extension_outlined),
            const SizedBox(width: 10),
            statCard('${progress.displayStreak}', 'Current streak',
                Icons.local_fire_department_outlined),
            const SizedBox(width: 10),
            statCard(
                '${stats.bestStreak}', 'Best streak', Icons.star_outline),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            statCard(_fmtTime(stats.bestTimeSeconds), 'Fastest solve',
                Icons.bolt_outlined),
            const SizedBox(width: 10),
            statCard('${stats.noHintSolves}', 'No-hint solves',
                Icons.do_not_touch_outlined),
            const SizedBox(width: 10),
            statCard('$dailySolved', 'Dailies solved',
                Icons.today_outlined),
          ]),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily activity',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  HeatmapCalendar(dailyHistory: stats.dailyHistory),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
