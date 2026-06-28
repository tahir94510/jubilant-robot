import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/ui/screens/achievements_screen.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/onboarding_screen.dart';
import 'package:quotecrack/ui/screens/pack_detail_screen.dart';
import 'package:quotecrack/ui/screens/packs_screen.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';
import 'package:quotecrack/ui/screens/stats_screen.dart';

import '../fakes/test_harness.dart';

/// Interaction sweep over every screen with the REAL bundled dataset:
/// each screen must build cleanly and every primary control must respond.
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

void main() {
  late final List<Quote> realQuotes;

  setUpAll(() {
    realQuotes = loadRealQuotes();
  });

  testWidgets('home screen renders and launches the daily puzzle', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);

    await tester.pumpWidget(h.app(const HomeScreen()));
    await tester.pump();

    expect(find.text('Quotecrack'), findsOneWidget);
    expect(find.text('DAILY PUZZLE'), findsOneWidget);
    expect(find.text('Puzzle packs'), findsOneWidget);

    // Menu tiles below the fold exist once scrolled into view (lazy list).
    for (final title in ['Statistics', 'Achievements', 'Go Premium']) {
      await tester.scrollUntilVisible(find.text(title), 150);
      expect(find.text(title), findsOneWidget);
    }

    // Scroll back up to reach the daily card's button again.
    await tester.drag(find.byType(ListView), const Offset(0, 800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play now'));
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(h.game.isDaily, isTrue);

    h.game.stopTimer();
  });

  testWidgets('home hides the premium tile for premium owners', (tester) async {
    final h = await Harness.create(quotes: realQuotes, premium: true);
    await tester.pumpWidget(h.app(const HomeScreen()));
    await tester.pump();
    expect(find.text('Go Premium'), findsNothing);
  });

  testWidgets('packs screen lists all 9 packs and opens a detail grid', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);
    await tester.pumpWidget(h.app(const PacksScreen()));
    await tester.pump();

    for (final title in [
      'Beginner',
      'Casual',
      'Skilled',
      'Expert',
      'Proverbs',
      'Wisdom',
      'Wit',
      'Literature',
      'Classics',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 150);
      expect(find.text(title), findsOneWidget, reason: 'pack "$title" missing');
    }

    // Back to the top of the lazy list before tapping the first pack.
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();
    expect(find.byType(PackDetailScreen), findsOneWidget);

    // Tapping a puzzle tile starts that puzzle.
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(h.game.originPackId, 'beginner');

    h.game.stopTimer();
  });

  testWidgets('locked premium pack routes free users to the paywall', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);
    await tester.pumpWidget(h.app(const PacksScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Classics'), 200);
    await tester.ensureVisible(find.text('Classics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Classics'));
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(h.economy.premium, isFalse);
  });

  testWidgets('premium owners open premium packs directly', (tester) async {
    final h = await Harness.create(quotes: realQuotes, premium: true);
    await tester.pumpWidget(h.app(const PacksScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Classics'), 200);
    await tester.ensureVisible(find.text('Classics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Classics'));
    await tester.pumpAndSettle();
    expect(find.byType(PackDetailScreen), findsOneWidget);
  });

  testWidgets('stats and achievements screens render with fresh data', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);

    await tester.pumpWidget(h.app(const StatsScreen()));
    await tester.pump();
    expect(find.text('Puzzles solved'), findsOneWidget);
    expect(find.text('Daily activity'), findsOneWidget);
    // First run: the friendly empty-state banner shows so the all-zero
    // grid never reads as broken.
    expect(find.textContaining('start your stats'), findsOneWidget);

    await tester.pumpWidget(h.app(const AchievementsScreen()));
    await tester.pump();
    expect(find.textContaining('Achievements (0/'), findsOneWidget);
    expect(find.text('First Crack'), findsOneWidget);
  });

  testWidgets('stats empty-state banner disappears after the first solve', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);
    await h.progress.recordSolve(
      quoteId: realQuotes.first.id,
      solveTime: const Duration(seconds: 30),
      hintsUsed: 0,
      isDaily: false,
    );
    await tester.pumpWidget(h.app(const StatsScreen()));
    await tester.pump();
    expect(find.textContaining('start your stats'), findsNothing);
    expect(find.text('Puzzles solved'), findsOneWidget);
  });

  testWidgets('every settings control responds', (tester) async {
    final h = await Harness.create(quotes: realQuotes);
    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    final settings = h.settings.settings;

    // Theme: switch to dark via the segmented button.
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();
    expect(settings.themeMode, AppThemeMode.dark);

    // Text size slider.
    final before = settings.textScale;
    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pump();
    expect(settings.textScale, isNot(before));

    // Toggles.
    await tester.tap(find.text('Colorblind-friendly colors'));
    await tester.pump();
    expect(settings.colorblindMode, isTrue);

    // The labelled theme grid made Appearance taller, so the gameplay
    // toggles start below the 600dp test viewport — scroll to each first.
    await tester.scrollUntilVisible(find.text('Error checking'), 150);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Error checking'));
    await tester.pump();
    expect(settings.errorChecking, isFalse);

    await tester.scrollUntilVisible(find.text('Show timer'), 150);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show timer'));
    await tester.pump();
    expect(settings.showTimer, isFalse);

    await tester.scrollUntilVisible(find.text('Haptic feedback'), 150);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haptic feedback'));
    await tester.pump();
    expect(settings.haptics, isFalse);

    await tester.scrollUntilVisible(find.text('Sound effects'), 150);
    await tester.ensureVisible(find.text('Sound effects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sound effects'));
    await tester.pump();
    expect(settings.soundEffects, isFalse);

    // Daily reminder: enabling schedules a notification via the service.
    await tester.scrollUntilVisible(find.text('Remind me daily'), 200);
    await tester.ensureVisible(find.text('Remind me daily'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remind me daily'));
    await tester.pumpAndSettle();
    expect(settings.reminderEnabled, isTrue);
    expect(h.notifications.scheduledAt, isNotNull);
    // The reminder is on/off only now — the time is chosen automatically per
    // language, so there is no in-app "Reminder time" picker row.
    expect(find.text('Reminder time'), findsNothing);

    // Disabling cancels it.
    await tester.tap(find.text('Remind me daily'));
    await tester.pumpAndSettle();
    expect(settings.reminderEnabled, isFalse);
    expect(h.notifications.cancelCalls, greaterThan(0));

    // Restore purchases row delegates to the store service.
    await tester.scrollUntilVisible(find.text('Restore purchases'), 200);
    await tester.ensureVisible(find.text('Restore purchases'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore purchases'));
    await tester.pump();
    expect(h.purchases.restoreCalls, 1);
  });

  testWidgets('denied notification permission keeps the reminder off', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);
    // A genuine block: the OS refuses the request AND reports notifications
    // off, so there is no real grant to fall back to.
    h.notifications.permissionGranted = false;
    h.notifications.osEnabled = false;

    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Remind me daily'), 200);
    await tester.tap(find.text('Remind me daily'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.reminderEnabled, isFalse);
    expect(h.notifications.scheduledAt, isNull);
    // A denied toggle no longer dead-ends in a snackbar: it offers a route to
    // the OS notification settings (the only Android 13+ recovery).
    expect(find.text('Notifications are off'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('onboarding walks through and starts the tutorial puzzle', (
    tester,
  ) async {
    final h = await Harness.create(quotes: realQuotes);
    await tester.pumpWidget(h.app(const OnboardingScreen()));
    await tester.pump();

    expect(find.text('Every letter is swapped'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try one (30 seconds)'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.onboardingDone, isTrue);
    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(h.game.session!.quote.id, 'tutorial-en');

    // Home was placed under the puzzle (no animated flash): backing out of
    // the tutorial lands on it, not on a dead end.
    h.game.stopTimer();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('onboarding skip lands on home', (tester) async {
    final h = await Harness.create(quotes: realQuotes);
    await tester.pumpWidget(h.app(const OnboardingScreen()));
    await tester.pump();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.onboardingDone, isTrue);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
