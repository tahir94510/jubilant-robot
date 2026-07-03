import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/l10n/app_localizations.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/widgets/premium_celebration.dart';

import '../fakes/test_harness.dart';

/// Locks the screen-reader contract for the board and the premium celebration.
/// The cipher board is the heart of the game; without these labels a TalkBack/
/// VoiceOver user hears unlabeled buttons and stray single letters. A
/// regression here ships an inaccessible board unnoticed, so it fails CI.
void main() {
  testWidgets('board letter cells expose localized screen-reader labels', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // Every editable cell is a labeled control: cipher letter + "empty"
    // (English template). One combined label per cell, not two stray glyphs.
    expect(find.bySemanticsLabel(RegExp(r'Letter [A-Z], empty')), findsWidgets);

    // Typing a guess flips the announcement to include the answer.
    h.game.enterGuess('A');
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp(r'Letter [A-Z], answer A')),
      findsWidgets,
    );

    handle.dispose();
    h.game.stopTimer();
  });

  testWidgets('the backspace key announces itself to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // The keyboard's icon-only action key must carry an explicit label
    // (English template) — letter keys are announced by their glyphs, but an
    // unlabeled icon reads as a nameless button under TalkBack/VoiceOver.
    expect(find.bySemanticsLabel('Backspace'), findsOneWidget);

    handle.dispose();
    h.game.stopTimer();
  });

  testWidgets('punctuation cells are hidden from screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // The quote's period renders as a layout-only PunctuationCell wrapped in
    // ExcludeSemantics, so it never surfaces as its own announced node.
    expect(find.bySemanticsLabel('.'), findsNothing);

    handle.dispose();
    h.game.stopTimer();
  });

  testWidgets('premium celebration scrim is a labeled dismiss control', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final h = await Harness.create();

    await tester.pumpWidget(h.app(PremiumCelebration(onDismiss: () {})));
    await tester.pump();

    // The tap-to-dismiss scrim announces itself (sighted users still get the
    // visible "Start playing" button).
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);

    handle.dispose();
  });

  testWidgets(
    'premium celebration fits a short screen and an outside tap dismisses it',
    (tester) async {
      // A very short viewport forces the card's INTERNAL-scroll path. Two
      // guarantees: (1) it must not overflow; (2) the regression guard — tapping
      // OUTSIDE the centered card must still fall through to the dismiss scrim
      // (a full-screen scroll overlay would have swallowed that tap).
      tester.view.physicalSize = const Size(320, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final h = await Harness.create();
      var dismissed = 0;
      await tester.pumpWidget(
        h.app(PremiumCelebration(onDismiss: () => dismissed++)),
      );
      await tester.pump(const Duration(milliseconds: 600)); // settle scale-in
      expect(tester.takeException(), isNull); // no RenderFlex overflow

      await tester.tapAt(const Offset(6, 6)); // a corner, outside the card
      await tester.pump();
      expect(
        dismissed,
        1,
        reason: 'tapping outside the card must dismiss via the scrim',
      );
    },
  );

  testWidgets('premium celebration text renders in the app brand font', (
    tester,
  ) async {
    // The overlay is a bare sibling of the paywall Scaffold, so without an
    // explicit Material ancestor its Text falls back to the platform default
    // font (off-brand Roboto) instead of the theme's Inter — a subtle but real
    // brand break on the app's most celebratory screen. This locks the fix
    // (a transparent Material wrapper) without a fragile golden image.
    final h = await Harness.create();
    await tester.pumpWidget(h.app(PremiumCelebration(onDismiss: () {})));
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(PremiumCelebration)),
    );
    final titleFinder = find.text(l10n.premiumUnlockedTitle);
    final ctx = tester.element(titleFinder);
    final brandFont = Theme.of(ctx).textTheme.bodyMedium?.fontFamily;
    // The effective style the title actually renders with = ambient default
    // merged with the widget's own style (which sets no family).
    final effective = DefaultTextStyle.of(
      ctx,
    ).style.merge(tester.widget<Text>(titleFinder).style);

    expect(brandFont, 'Inter'); // the theme's UI font
    expect(
      effective.fontFamily,
      brandFont,
      reason: 'premium title must inherit the brand font, not a fallback',
    );
  });
}
