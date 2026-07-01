@Tags(['preview'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quotecrack/l10n/app_localizations.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/ui/screens/achievements_screen.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/packs_screen.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/stats_screen.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';

import '../fakes/test_harness.dart';

/// Local-only store-asset generator (excluded from CI via the `preview` tag):
/// renders 6 app screens IN EACH of the 7 store languages, seeded with an
/// engaged player profile (solves, streaks, achievements) so the store never
/// shows a hollow first-run screen. tool/make_screenshots.py frames the output.
/// Run: flutter test test/preview/shots_hires_test.dart --update-goldens --tags preview
Future<void> _f(String fam, List<String> paths) async {
  final l = FontLoader(fam);
  for (final p in paths) {
    l.addFont(
      Future.value(
        ByteData.view(Uint8List.fromList(File(p).readAsBytesSync()).buffer),
      ),
    );
  }
  await l.load();
}

const _locales = ['en', 'tr', 'es', 'de', 'fr', 'it', 'pt'];

/// Full real catalog, so packs/counts look like the shipped game.
List<Quote> loadRealQuotes() {
  final dir = Directory('assets/data/quotes');
  return [
    for (final file in dir.listSync(recursive: true).whereType<File>())
      if (file.path.endsWith('.json'))
        ...(jsonDecode(file.readAsStringSync()) as List<dynamic>).map(
          (e) => Quote.fromJson(e as Map<String, dynamic>),
        ),
  ];
}

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// An engaged, believable profile: a two-digit streak, a healthy heatmap and
/// pack progress — what a happy player's app actually looks like.
Map<String, Map<String, dynamic>> seedFor(List<Quote> catalog) {
  final today = DateTime.now();
  final history = <String, bool>{};
  for (var i = 0; i < 70; i++) {
    final d = today.subtract(Duration(days: i));
    // Miss roughly one day in five, but keep the recent 23 days unbroken so
    // the current streak matches the numbers below.
    history[_day(d)] = i < 23 || d.day % 5 != 0;
  }
  Map<String, dynamic> statsFor(String locale) {
    final ids = catalog
        .where((q) => q.locale == locale)
        .map((q) => q.id)
        .take(47)
        .toList();
    return {
      'totalSolved': ids.length + 80,
      'noHintSolves': 58,
      'bestTimeSeconds': 74,
      'totalTimeSeconds': (ids.length + 80) * 210,
      'hintsUsed': 41,
      'currentStreak': 23,
      'bestStreak': 41,
      'lastDailyDate': _day(today),
      'solvedIds': ids,
      'dailyHistory': history,
    };
  }

  return {
    StorageService.statsByLocaleKey: {
      'byLocale': {for (final l in _locales) l: statsFor(l)},
    },
    StorageService.achievementsKey: {
      'ids': [
        'first_solve', 'solve_10', 'solve_25', 'solve_50', 'solve_100', //
        'streak_3', 'streak_7', 'streak_14', 'no_hints_10', 'no_hints_25',
        'speed_60', 'speed_120', 'daily_10', 'daily_25',
      ],
    },
    StorageService.economyKey: {
      'tokens': 12,
      'premium': false,
      'completedCount': 127,
    },
  };
}

void main() {
  final catalog = loadRealQuotes();
  final seed = seedFor(catalog);

  setUpAll(() async {
    await _f('Inter', [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ]);
    await _f('Lora', ['assets/fonts/Lora-Variable.ttf']);
    const mi =
        '/root/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
    if (File(mi).existsSync()) await _f('MaterialIcons', [mi]);
  });

  Widget appOf(ThemeData theme, Widget child, String lang) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: Locale(lang),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, c) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: c!,
    ),
    home: child,
  );

  /// 1520x2760 physical (logical 380x690 at dpr 4): the compositor always
  /// DOWNSCALES this onto every canvas (phone card ~734px, 10" tablet card
  /// ~1420px), so the framed screenshots stay crisp — never upscaled/blurry.
  Future<void> cap(
    WidgetTester t,
    String lang,
    String name,
    Widget screen, {
    void Function(Harness)? setup,
  }) async {
    t.view.physicalSize = const Size(1520, 2760);
    t.view.devicePixelRatio = 4.0;
    addTearDown(t.view.reset);
    final h = await Harness.create(quotes: catalog, seedJson: seed);
    await h.settings.setLanguage(lang); // content locale follows the language
    setup?.call(h);
    await t.pumpWidget(
      MultiProvider(
        providers: h.providers,
        child: appOf(AppThemes.light(colorblind: false), screen, lang),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    await expectLater(
      find.byType(screen.runtimeType),
      matchesGoldenFile('shots/$lang/$name.png'),
    );
    if (setup != null) h.game.stopTimer();
  }

  /// A mid-length native quote reads as a real session on the board.
  Quote puzzleFor(String lang) => catalog.firstWhere(
    (q) => q.locale == lang && q.text.length >= 40 && q.text.length <= 70,
    orElse: () => catalog.firstWhere((q) => q.locale == lang),
  );

  for (final lang in _locales) {
    group(lang, () {
      testWidgets('s_home', (t) => cap(t, lang, 's_home', const HomeScreen()));
      testWidgets(
        's_puzzle',
        (t) => cap(
          t,
          lang,
          's_puzzle',
          const PuzzleScreen(),
          setup: (h) => h.game.start(puzzleFor(lang), daily: false),
        ),
      );
      testWidgets(
        's_stats',
        (t) => cap(t, lang, 's_stats', const StatsScreen()),
      );
      testWidgets(
        's_ach',
        (t) => cap(t, lang, 's_ach', const AchievementsScreen()),
      );
      testWidgets(
        's_packs',
        (t) => cap(t, lang, 's_packs', const PacksScreen()),
      );
      testWidgets(
        's_paywall',
        (t) => cap(t, lang, 's_paywall', const PaywallScreen()),
      );
    });
  }
}
