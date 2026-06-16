import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/clock.dart';
import '../theme/palette.dart';

/// GitHub-style heatmap of the last ~16 weeks of daily-puzzle activity.
class HeatmapCalendar extends StatelessWidget {
  const HeatmapCalendar({super.key, required this.dailyHistory, this.now});

  /// 'yyyy-MM-dd' -> solved.
  final Map<String, bool> dailyHistory;

  /// Injectable "today" so tests can pin the grid; defaults to the clock.
  final DateTime? now;

  static const int _weeks = 16;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = now ?? DateTime.now();
    // Last day of the grid = today; grid starts weeks back on a Monday.
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: 7 * (_weeks - 1) + (today.weekday - 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var w = 0; w < _weeks; w++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: Column(
                    children: [
                      for (var d = 0; d < 7; d++)
                        _cell(
                          context,
                          start.add(Duration(days: w * 7 + d)),
                          today,
                          scheme,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            // Month labels follow the active locale ("Şub 2026", "févr. 2026").
            final localeName = Localizations.localeOf(context).toString();
            final fmt = DateFormat.yMMM(localeName);
            return Text(
              AppLocalizations.of(context).statsHeatmapCaption(
                _weeks,
                fmt.format(start),
                fmt.format(today),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).extension<GamePalette>()!.textSecondary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime day,
    DateTime today,
    ColorScheme scheme,
  ) {
    final isFuture = day.isAfter(today);
    final solved = dailyHistory[dateKey(day)] == true;
    final color = isFuture
        ? Colors.transparent
        : solved
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: .07);
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
