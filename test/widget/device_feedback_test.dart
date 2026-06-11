import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';
import 'package:quotecrack/ui/widgets/puzzle_keyboard.dart';

import '../fakes/test_harness.dart';
import 'puzzle_flow_test.dart' show solveByTapping;

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

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.dark);
    expect(find.text('Auto — follows your device'), findsNothing);

    await tester.tap(find.byIcon(Icons.brightness_auto_outlined));
    await tester.pump();
    expect(h.settings.settings.themeMode, AppThemeMode.system);
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
