import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';
import 'package:quotecrack/ui/widgets/letter_cell.dart';
import 'package:quotecrack/ui/widgets/puzzle_keyboard.dart';

import '../fakes/test_harness.dart';
import 'puzzle_flow_test.dart' show solveByTapping;

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
    expect(find.text('Auto — follows your device'), findsOneWidget);

    // Every option carries a readable text label, not just an icon.
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Sepia'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.dark);
    expect(find.text('Auto — follows your device'), findsNothing);

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
}
