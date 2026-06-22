import 'package:flutter_test/flutter_test.dart';
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
}
