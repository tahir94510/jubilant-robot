import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/widgets/letter_cell.dart';

import '../fakes/test_harness.dart';

/// Locks the board's per-keystroke rebuild contract: CipherBoard memoizes
/// cell widgets per position, so a keystroke may only reconstruct cells whose
/// visual inputs actually changed — every other cell must be the IDENTICAL
/// instance, which lets Flutter skip its rebuild entirely. This is the frame
/// budget on long quotes; a regression here silently rebuilds the whole board
/// on every key tap again.
void main() {
  testWidgets('a keystroke reuses every cell whose inputs did not change', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    List<LetterCell> cells() =>
        tester.widgetList<LetterCell>(find.byType(LetterCell)).toList();

    final before = cells();
    expect(before, isNotEmpty);

    // Type the correct letter for the selected cell; the cursor auto-advances.
    final target = h.game.selectedCipherLetter!;
    h.game.enterGuess(h.game.session!.cipher.decryptLetter(target));
    await tester.pump();

    final after = cells();
    expect(after.length, before.length);

    var reused = 0;
    for (var i = 0; i < before.length; i++) {
      final b = before[i];
      final a = after[i];
      if (identical(b, a)) {
        reused++;
        continue;
      }
      // A reconstructed cell must be able to point at a real input change —
      // otherwise the memo regressed and the board is rebuilding wholesale.
      final differs =
          b.guess != a.guess ||
          b.state != a.state ||
          b.focused != a.focused ||
          b.related != a.related ||
          b.recent != a.recent ||
          b.lastTyped != a.lastTyped ||
          b.width != a.width;
      expect(
        differs,
        isTrue,
        reason:
            'cell $i ("${b.cipherLetter}") was reconstructed although none of '
            'its visual inputs changed',
      );
    }
    expect(
      reused,
      greaterThan(0),
      reason:
          'at least the untouched letters must be handed to Flutter as '
          'identical instances so their rebuild is skipped',
    );

    // Sanity: memoization must not eat the auto-fill — every copy of the
    // typed cipher letter shows the guess.
    for (final c in after.where((c) => c.cipherLetter == target)) {
      expect(c.guess, isNotNull);
    }

    h.game.stopTimer();
  });

  testWidgets('tapping a cell moves the cursor via the memoized callback', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // Trigger one keystroke first so some cells come from the memo cache,
    // then tap one of THOSE cells: the cached onTap closure must still reach
    // the live controller (it reads widget.onSelect at tap time).
    final first = h.game.selectedCipherLetter!;
    h.game.enterGuess(h.game.session!.cipher.decryptLetter(first));
    await tester.pump();
    final movedTo = h.game.selectedIndex;

    // Tap the first board cell (position 0) — a memo-cached instance now.
    await tester.tap(find.byType(LetterCell).first);
    await tester.pump();

    expect(h.game.selectedIndex, 0);
    expect(h.game.selectedIndex, isNot(movedTo));

    h.game.stopTimer();
  });
}
