import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/models/pack.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/ui/screens/achievements_screen.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/onboarding_screen.dart';
import 'package:quotecrack/ui/screens/pack_detail_screen.dart';
import 'package:quotecrack/ui/screens/packs_screen.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';
import 'package:quotecrack/ui/screens/stats_screen.dart';
import 'package:quotecrack/ui/widgets/cipher_board.dart';
import 'package:quotecrack/ui/widgets/letter_cell.dart';
import 'package:quotecrack/ui/widgets/page_body.dart';
import 'package:quotecrack/ui/widgets/puzzle_keyboard.dart';

import '../fakes/test_harness.dart';
import 'puzzle_flow_test.dart' show solveByTapping;
import 'screens_smoke_test.dart' show loadRealQuotes;

/// The longest word in the live dataset is 15 letters; at the old fixed
/// cell width this overflowed every phone narrower than ~460dp (the
/// on-device "RIGHT OVERFLOWED BY N PIXELS" stripes).
final Quote longWordQuote = Quote(
  id: 'test-longword',
  text: 'All generalizations are false, including this one.',
  author: 'Anonymous',
  source: 'Folk saying',
  category: 'humor',
);

/// Regression suite for the issues found during on-device testing:
/// layout overflow near the keyboard, the lying theme selector, slider
/// jank, and the new sound-effect hooks.
void main() {
  testWidgets('puzzle screen fits a narrow phone with huge system text', (
    tester,
  ) async {
    // 320x640 logical (small budget phone) + 1.6 OS text scale used to
    // produce "BOTTOM OVERFLOWED BY N PIXELS" before the fix. Overflow
    // throws inside tests, so reaching the expects proves the layout fits.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen(), textScale: 1.6));
    await tester.pump();

    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    h.game.stopTimer();
  });

  testWidgets(
    'puzzle screen fits a narrow phone with huge text in long languages '
    '(de/fr/pt) — the hint button label shrinks instead of breaking',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // German/French/Portuguese labels (e.g. "Buchstaben aufdecken") are far
      // longer than English; at 1.6x on a 320dp phone the reveal button used to
      // push the layout. The capped + scale-to-fit label keeps it intact.
      for (final lang in ['de', 'fr', 'pt']) {
        final h = await Harness.create();
        h.game.start(shortQuote, daily: false);

        await tester.pumpWidget(
          h.app(const PuzzleScreen(), textScale: 1.6, locale: Locale(lang)),
        );
        await tester.pump();

        expect(find.byType(PuzzleScreen), findsOneWidget, reason: lang);
        expect(tester.takeException(), isNull, reason: 'overflow in $lang');

        h.game.stopTimer();
      }
    },
  );

  testWidgets('a 15-letter word fits a narrow phone with huge system text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create(quotes: [longWordQuote]);
    h.game.start(longWordQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen(), textScale: 1.6));
    await tester.pump();

    expect(tester.takeException(), isNull);
    // The whole board shrinks evenly: one uniform cell width everywhere.
    final widths = tester
        .widgetList<LetterCell>(find.byType(LetterCell))
        .map((c) => c.width)
        .toSet();
    expect(widths, hasLength(1));

    h.game.stopTimer();
  });

  testWidgets('a 15-letter word fits a typical 360dp phone', (tester) async {
    // The screenshotted device: 360x800 logical, default text scale.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create(quotes: [longWordQuote]);
    h.game.start(longWordQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final widths = tester
        .widgetList<LetterCell>(find.byType(LetterCell))
        .map((c) => c.width)
        .toSet();
    expect(widths, hasLength(1));
    // Cells shrank below the screen-only formula to make the word fit.
    expect(widths.single, lessThan(360 / 13.5));

    h.game.stopTimer();
  });

  testWidgets('solve clock checkpoints on exit, not at the last guess', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // Enter one letter at second ~0, then idle for 7 ticking seconds.
    h.game.enterGuess('Q');
    await tester.pump(const Duration(seconds: 7));
    expect(h.game.elapsed.inSeconds, greaterThanOrEqualTo(7));

    // Leaving the screen must persist the CURRENT clock, not the clock at
    // the moment of the last guess (the on-device bug).
    h.game.stopTimer();
    final saved = h.storage.readJson(
      StorageService.puzzleStateKey(shortQuote.id),
    );
    expect(saved?['elapsedSeconds'], greaterThanOrEqualTo(7));

    // Resuming restores from the checkpoint.
    h.game.start(shortQuote, daily: false);
    expect(h.game.elapsed.inSeconds, greaterThanOrEqualTo(7));
    h.game.stopTimer();
  });

  testWidgets('ticking clock autosaves periodically while idle', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 11)); // crosses the 10s mark

    final saved = h.storage.readJson(
      StorageService.puzzleStateKey(shortQuote.id),
    );
    expect(saved?['elapsedSeconds'], greaterThanOrEqualTo(10));

    h.game.stopTimer();
  });

  testWidgets('daily completion screen fits a narrow phone with huge text '
      '(three stat chips wrap instead of overflowing)', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create();
    h.game.start(shortQuote, daily: true);

    await tester.pumpWidget(h.app(const PuzzleScreen(), textScale: 1.6));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    expect(find.textContaining('day streak'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The actions are pinned above the banner: both buttons must be fully
    // visible and tappable WITHOUT scrolling, even on this small viewport
    // (they used to sit below the fold inside the scrolling list).
    expect(find.text('Share result').hitTestable(), findsOneWidget);
    expect(find.text('Back to menu').hitTestable(), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('Back to menu')).dy,
      lessThanOrEqualTo(640),
    );

    h.game.stopTimer();
  });

  testWidgets('completion screen survives a LONG language (German) on a narrow '
      'phone with huge text — action buttons never overflow', (tester) async {
    // The original report was "buttons break in other languages": German
    // labels ("Ergebnis teilen", "Zurück zum Menü") are much longer than the
    // English ones, so this is the real regression guard for label overflow.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create();
    h.game.start(shortQuote, daily: true);

    await tester.pumpWidget(
      h.app(const PuzzleScreen(), textScale: 1.6, locale: const Locale('de')),
    );
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    // No RenderFlex overflow (or any) while laying out the German actions.
    expect(tester.takeException(), isNull);
    expect(find.text('Ergebnis teilen').hitTestable(), findsOneWidget);
    expect(find.text('Zurück zum Menü').hitTestable(), findsOneWidget);

    h.game.stopTimer();
  });

  testWidgets(
    'pack detail grid lays out without overflow (huge text, German)',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final h = await Harness.create(quotes: loadRealQuotes());
      await tester.pumpWidget(
        h.app(
          PackDetailScreen(pack: Pack.byId('beginner')),
          textScale: 1.6,
          locale: const Locale('de'),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('settings and packs survive narrow screens with huge text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create();

    await tester.pumpWidget(h.app(const SettingsScreen(), textScale: 1.6));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Version'), 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme selector shows Auto by default and switches honestly', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    // Default is system ("Auto") and the UI says so instead of faking
    // a light selection.
    expect(h.settings.settings.themeMode, AppThemeMode.system);
    expect(find.text('Auto (follows your device)'), findsOneWidget);

    // Every option carries a readable text label, not just an icon.
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Sepia'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.dark);
    expect(find.text('Auto (follows your device)'), findsNothing);

    await tester.tap(find.byIcon(Icons.brightness_auto_outlined));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.system);
  });

  testWidgets('theme cards keep their labels on a narrow phone with huge '
      'text', (tester) async {
    // The on-device report: the old segmented control wrapped/clipped the
    // "Auto" label. The card grid must show all four labels at 320dp + 1.6x.
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final h = await Harness.create();
    await tester.pumpWidget(h.app(const SettingsScreen(), textScale: 1.6));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Sepia'), findsOneWidget);

    await tester.tap(find.text('Sepia'));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.sepia);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-size slider previews live but persists once on release', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pump();
    final committed = h.settings.settings.textScale;
    expect(committed, greaterThan(1.0));

    // onChangeEnd persisted the final value to storage in one write.
    final saved = h.storage.readJson(StorageService.settingsKey);
    expect((saved?['textScale'] as num).toDouble(), committed);
  });

  testWidgets('sound effects fire on tap, hint, success — and respect the '
      'settings toggle', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // A hint plays the hint sound.
    await tester.tap(find.textContaining('Reveal letter'));
    await tester.pump();
    expect(h.sounds.played, contains('hint'));

    // Solving plays key taps along the way and success exactly once.
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();
    expect(h.sounds.played, contains('tap'));
    expect(h.sounds.played.where((s) => s == 'success').length, 1);
    // The music bed ducks under the success fanfare exactly once.
    expect(h.music.calls.where((c) => c == 'duck').length, 1);

    h.game.stopTimer();
  });

  testWidgets('disabling sound effects silences everything', (tester) async {
    final h = await Harness.create();
    await h.settings.setSoundEffects(false);
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    await tester.tap(find.textContaining('Reveal letter'));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    expect(h.sounds.played, isEmpty);
    h.game.stopTimer();
  });

  testWidgets('a conflicting guess plays the conflict cue instead of a tap', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final session = h.game.session!;
    // Assign Z to the first letter, then Z again to a second letter via
    // the real keyboard: the second input must register as a conflict.
    h.game.enterGuess('Z');
    h.game.selectCipherLetter(session.cipher.encryptLetter('M'));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(PuzzleKeyboard),
        matching: find.text('Z'),
      ),
    );
    await tester.pump();

    expect(h.game.lastInputCreatedConflict, isTrue);
    expect(h.sounds.played, contains('conflict'));

    h.game.stopTimer();
  });

  testWidgets('completing a word plays the word cue instead of a tap', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    final session = h.game.session!;

    Future<void> type(String plain) async {
      h.game.selectCipherLetter(session.cipher.encryptLetter(plain));
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(PuzzleKeyboard),
          matching: find.text(plain),
        ),
      );
      await tester.pump();
    }

    await type('L'); // building LESS — a plain tap
    await type('E');
    expect(h.sounds.played, contains('tap'));
    expect(h.sounds.played, isNot(contains('word')));

    await type('S'); // completes LESS (a real 3+ letter word)
    expect(h.sounds.played.where((s) => s == 'word').length, 1);

    h.game.stopTimer();
  });

  testWidgets('the music toggle applies immediately and persists', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Music'), 150);
    expect(h.settings.settings.music, isTrue);

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.music, isFalse);
    // The running service was told to stop right away, not on next launch.
    expect(h.music.calls, contains('enabled:false'));
    final saved = h.storage.readJson(StorageService.settingsKey);
    expect(saved?['music'], isFalse);

    await tester.tap(find.text('Music'));
    await tester.pumpAndSettle();
    expect(h.settings.settings.music, isTrue);
    expect(h.music.calls, contains('enabled:true'));
  });

  testWidgets('home header music icon mutes instantly and reflects state', (
    tester,
  ) async {
    final h = await Harness.create(quotes: loadRealQuotes());
    await tester.pumpWidget(h.app(const HomeScreen()));
    await tester.pump();

    // Starts on: the note icon is shown, the muted icon is not.
    expect(find.byIcon(Icons.music_note_outlined), findsOneWidget);
    expect(find.byIcon(Icons.music_off_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.music_note_outlined));
    await tester.pumpAndSettle();

    expect(h.settings.settings.music, isFalse);
    expect(h.music.calls, contains('enabled:false'));
    expect(find.byIcon(Icons.music_off_outlined), findsOneWidget);

    // Tapping again turns it back on.
    await tester.tap(find.byIcon(Icons.music_off_outlined));
    await tester.pumpAndSettle();
    expect(h.settings.settings.music, isTrue);
    expect(find.byIcon(Icons.music_note_outlined), findsOneWidget);
  });

  testWidgets('reminder time picker opens keyboard-entry, no buggy dial', (
    tester,
  ) async {
    final h = await Harness.create();
    // Enable the reminder first so the "Reminder time" row is visible; the
    // picker UI is what this test exercises.
    await h.settings.setReminder(enabled: true);
    h.notifications.scheduledAt = null; // reset so the re-schedule is visible
    await tester.pumpWidget(h.app(const SettingsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Reminder time'), 150);
    // Fully scroll the row into the viewport before tapping: scrollUntilVisible
    // stops as soon as any pixel is visible, which can leave the tap target at
    // the very bottom edge.
    await tester.ensureVisible(find.text('Reminder time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reminder time'));
    await tester.pumpAndSettle();

    // input-only mode = text fields, never the dial (the source of the
    // overlapping-dot artifact on device).
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // A reschedule happened (the fake records the time it was handed).
    expect(h.notifications.scheduledAt, isNotNull);
  });

  testWidgets('the solve clock ticks the on-screen timer without rebuilding '
      'the board', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    expect(find.text('0:00'), findsOneWidget);
    final boardBefore = tester.widget<CipherBoard>(find.byType(CipherBoard));

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // The timer text advanced (ticks are live)...
    expect(find.text('0:02'), findsOneWidget);
    // ...but the board widget instance is untouched: a pure tick no longer
    // rebuilds the whole PuzzleScreen, only the AppBar timer.
    final boardAfter = tester.widget<CipherBoard>(find.byType(CipherBoard));
    expect(identical(boardBefore, boardAfter), isTrue);

    h.game.stopTimer();
  });

  // Every remaining screen gets the same narrow-phone + huge-text guard the
  // puzzle/settings/completion screens already have: 320x640 at 1.6 text
  // scale, scrolled end to end, must never overflow.
  group('all menu screens survive 320x640 with huge text', () {
    Future<Harness> pumpAt320(
      WidgetTester tester,
      Widget screen, {
      bool realData = false,
    }) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final h = await Harness.create(
        quotes: realData ? loadRealQuotes() : null,
      );
      await tester.pumpWidget(h.app(screen, textScale: 1.6));
      await tester.pump();
      return h;
    }

    testWidgets('home', (tester) async {
      await pumpAt320(tester, const HomeScreen(), realData: true);
      await tester.scrollUntilVisible(find.text('Go Premium'), 150);
      expect(tester.takeException(), isNull);
    });

    testWidgets('statistics incl. heatmap', (tester) async {
      await pumpAt320(tester, const StatsScreen());
      await tester.scrollUntilVisible(
        find.textContaining('Last 16 weeks'),
        150,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('achievements down to the last entry', (tester) async {
      await pumpAt320(tester, const AchievementsScreen());
      await tester.scrollUntilVisible(find.text('Hundred Mornings'), 150);
      expect(tester.takeException(), isNull);
    });

    testWidgets('paywall', (tester) async {
      await pumpAt320(tester, const PaywallScreen());
      await tester.scrollUntilVisible(
        find.text('Restore previous purchase'),
        150,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('onboarding, every page', (tester) async {
      await pumpAt320(tester, const OnboardingScreen());
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Try one (30 seconds)'), findsOneWidget);
    });
  });

  // Big screens (tablets/foldables): content must not overflow and must stay
  // width-capped/centered rather than stretching edge to edge.
  group('large screens (tablet) lay out without overflow', () {
    Future<Harness> pumpLarge(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final h = await Harness.create(quotes: loadRealQuotes());
      await tester.pumpWidget(h.app(screen));
      await tester.pump();
      return h;
    }

    testWidgets('home is centered and capped, no overflow', (tester) async {
      await pumpLarge(tester, const HomeScreen());
      expect(tester.takeException(), isNull);
      // The content is width-capped well under the 1200px viewport rather
      // than stretching edge to edge.
      expect(find.byType(PageBody), findsOneWidget);
      final listWidth = tester.getSize(find.byType(ListView).first).width;
      expect(listWidth, lessThanOrEqualTo(560));
    });

    testWidgets('packs, stats, settings, achievements survive a tablet', (
      tester,
    ) async {
      for (final screen in const [
        PacksScreen(),
        StatsScreen(),
        SettingsScreen(),
        AchievementsScreen(),
      ]) {
        await pumpLarge(tester, screen);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('puzzle board + keyboard stay width-capped on a tablet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final h = await Harness.create();
      h.game.start(shortQuote, daily: false);
      await tester.pumpWidget(h.app(const PuzzleScreen()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Capped well under the 1200px viewport rather than sprawling.
      expect(
        tester.getSize(find.byType(PuzzleKeyboard)).width,
        lessThanOrEqualTo(600),
      );
      h.game.stopTimer();
    });

    testWidgets('paywall stays centered and capped on a tablet', (
      tester,
    ) async {
      await pumpLarge(tester, const PaywallScreen());
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(ListView).first).width,
        lessThanOrEqualTo(560),
      );
    });
  });
}
