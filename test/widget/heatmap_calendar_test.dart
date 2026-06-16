import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/l10n/app_localizations.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:quotecrack/ui/widgets/heatmap_calendar.dart';

/// Locks the stats heatmap geometry: a 16-week grid whose first column
/// starts on the Monday 15 weeks back, with future days transparent and
/// the caption naming the real month window.
void main() {
  Widget host(HeatmapCalendar heatmap) => MaterialApp(
    theme: AppThemes.light(colorblind: false),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: heatmap),
  );

  // 2026-06-11 is a Thursday; the grid then starts Monday 2026-02-23.
  final pinnedToday = DateTime(2026, 6, 11);

  testWidgets('grid spans 16 Monday-aligned weeks ending today', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        HeatmapCalendar(
          now: pinnedToday,
          dailyHistory: const {
            '2026-02-23': true, // first cell of the window
            '2026-02-22': true, // one day before the window — must not paint
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AspectRatio), findsNWidgets(16 * 7));

    final context = tester.element(find.byType(HeatmapCalendar));
    final primary = Theme.of(context).colorScheme.primary;
    final cellColors = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(AspectRatio),
            matching: find.byType(Container),
          ),
        )
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .toList();

    // Exactly one solved cell (Feb 23); Feb 22 sits outside the window.
    expect(cellColors.where((c) => c == primary).length, 1);
    // Thursday June 11 leaves Fri/Sat/Sun of the last week in the future.
    expect(cellColors.where((c) => c == Colors.transparent).length, 3);
  });

  testWidgets('caption names the real month window', (tester) async {
    await tester.pumpWidget(
      host(HeatmapCalendar(now: pinnedToday, dailyHistory: const {})),
    );
    await tester.pump();

    expect(find.text('Last 16 weeks · Feb 2026 to Jun 2026'), findsOneWidget);
  });
}
