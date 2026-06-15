import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/ui/screens/achievements_screen.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';

import '../fakes/test_harness.dart';

/// The daily-puzzle pool asserts a year+ of quotes, so Home needs the real
/// bundled dataset rather than the single fixture.
List<Quote> _loadRealQuotes() {
  final dir = Directory('assets/data/quotes');
  return [
    for (final file in dir.listSync(recursive: true).whereType<File>())
      if (file.path.endsWith('.json'))
        ...(jsonDecode(file.readAsStringSync()) as List<dynamic>).map(
          (e) => Quote.fromJson(e as Map<String, dynamic>),
        ),
  ];
}

/// The UI must actually localize: the Settings screen renders its strings in
/// the selected language, and English remains the default.
void main() {
  testWidgets('Settings renders in Turkish when the locale is tr', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(
      h.app(const SettingsScreen(), locale: const Locale('tr')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget); // Settings (app bar)
    expect(find.text('Uygulama dili'), findsOneWidget); // App language
    expect(find.text('Sistem varsayılanı'), findsOneWidget); // System default
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('Settings renders in English by default', (tester) async {
    final h = await Harness.create();
    await tester.pumpWidget(
      h.app(const SettingsScreen(), locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);
  });

  testWidgets('Home renders in Turkish when the locale is tr', (tester) async {
    final h = await Harness.create(quotes: _loadRealQuotes());
    await tester.pumpWidget(
      h.app(const HomeScreen(), locale: const Locale('tr')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hemen oyna'), findsOneWidget); // Play now
    expect(find.text('Bulmaca paketleri'), findsOneWidget); // Puzzle packs
    expect(find.text('İstatistikler'), findsOneWidget); // Statistics
    expect(find.text('Play now'), findsNothing);
  });

  testWidgets('Achievements render localized names/descriptions in Turkish', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(
      h.app(const AchievementsScreen(), locale: const Locale('tr')),
    );
    await tester.pumpAndSettle();

    expect(find.text('İlk Kırış'), findsOneWidget); // First Crack
    expect(find.text('İlk kriptogramını çöz'), findsOneWidget); // description
    expect(find.text('First Crack'), findsNothing);
  });
}
