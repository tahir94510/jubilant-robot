@Tags(['preview'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quotecrack/l10n/app_localizations.dart';
import 'package:quotecrack/ui/screens/achievements_screen.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/packs_screen.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/stats_screen.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';

import '../fakes/test_harness.dart';

/// Throwaway: high-res app-screen renders (real fonts) IN EACH of the 7 store
/// languages, which the Python compositor frames into Play Store screenshots.
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

void main() {
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

  Future<void> cap(
    WidgetTester t,
    String lang,
    String name,
    Widget screen,
    ThemeData theme, {
    void Function(Harness)? setup,
  }) async {
    t.view.physicalSize = const Size(760, 1380);
    t.view.devicePixelRatio = 2.0;
    addTearDown(t.view.reset);
    final h = await Harness.create();
    setup?.call(h);
    await t.pumpWidget(
      MultiProvider(providers: h.providers, child: appOf(theme, screen, lang)),
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

  final light = AppThemes.light(colorblind: false);
  final dark = AppThemes.dark(colorblind: false);

  for (final lang in _locales) {
    group(lang, () {
      testWidgets(
        's_home',
        (t) => cap(t, lang, 's_home', const HomeScreen(), light),
      );
      testWidgets(
        's_puzzle',
        (t) => cap(
          t,
          lang,
          's_puzzle',
          const PuzzleScreen(),
          light,
          setup: (h) => h.game.start(shortQuote, daily: false),
        ),
      );
      testWidgets(
        's_stats',
        (t) => cap(t, lang, 's_stats', const StatsScreen(), light),
      );
      testWidgets(
        's_ach',
        (t) => cap(t, lang, 's_ach', const AchievementsScreen(), light),
      );
      testWidgets(
        's_packs',
        (t) => cap(t, lang, 's_packs', const PacksScreen(), light),
      );
      testWidgets(
        's_paywall',
        (t) => cap(t, lang, 's_paywall', const PaywallScreen(), dark),
      );
    });
  }
}
