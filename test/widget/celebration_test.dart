import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/puzzle_complete_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:quotecrack/ui/widgets/confetti_burst.dart';

import '../fakes/test_harness.dart';
import 'puzzle_flow_test.dart' show solveByTapping;

/// The win celebration: confetti must be strictly one-shot (or every
/// pumpAndSettle in the suite would hang), invisible under reduced motion,
/// and the solve wave must still land on the complete screen.
void main() {
  testWidgets('confetti draws, finishes on its own, and settles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.light(colorblind: false),
        home: const Scaffold(body: ConfettiBurst()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Mid-flight it paints...
    expect(
      find.descendant(
        of: find.byType(ConfettiBurst),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );

    // ...and completes without external help: a looping animation here
    // would time this out.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion renders no confetti at all', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.light(colorblind: false),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: ConfettiBurst()),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(ConfettiBurst),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('solving sweeps the board, then lands on the complete screen '
      'with confetti', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    await solveByTapping(tester, h);

    // Mid-wave (620ms total): still celebrating on the puzzle screen.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PuzzleScreen), findsOneWidget);
    expect(find.byType(PuzzleCompleteScreen), findsNothing);

    // The wave's onEnd drives navigation; everything settles (confetti is
    // one-shot, so this terminates).
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleCompleteScreen), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(tester.takeException(), isNull);

    h.game.stopTimer();
  });
}
