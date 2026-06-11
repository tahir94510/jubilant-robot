import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/widgets/letter_cell.dart';
import 'package:quotecrack/ui/widgets/puzzle_keyboard.dart';

import '../fakes/test_harness.dart';

void main() {
  testWidgets('identical cipher letters auto-fill together', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false); // LESS IS MORE: S appears 3x

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final session = h.game.session!;
    // Select the cipher letter for plain S and guess it correctly.
    final cipherS = session.cipher.encryptLetter('S');
    h.game.selectCipherLetter(cipherS);
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byType(PuzzleKeyboard),
        matching: find.text('S'),
      ),
    );
    await tester.pump();

    // All three S-cells show the same guess simultaneously.
    final filled = tester
        .widgetList<LetterCell>(find.byType(LetterCell))
        .where((c) => c.cipherLetter == cipherS)
        .toList();
    expect(filled.length, 3);
    for (final cell in filled) {
      expect(cell.guess, 'S');
    }

    h.game.stopTimer();
  });

  testWidgets('using one plain letter twice flags a conflict', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final session = h.game.session!;
    final cipherL = session.cipher.encryptLetter('L');
    final cipherM = session.cipher.encryptLetter('M');

    h.game.selectCipherLetter(cipherL);
    h.game.enterGuess('Z');
    h.game.selectCipherLetter(cipherM);
    h.game.enterGuess('Z');
    await tester.pump();

    expect(session.conflicts, containsAll([cipherL, cipherM]));
    final conflictCells = tester
        .widgetList<LetterCell>(find.byType(LetterCell))
        .where((c) => c.state == CellState.conflict);
    expect(conflictCells.length, greaterThanOrEqualTo(2));

    h.game.stopTimer();
  });

  testWidgets('keyboard dims letters already used on the board', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    h.game.enterGuess('Q');
    await tester.pump();

    final keyboard = tester.widget<PuzzleKeyboard>(find.byType(PuzzleKeyboard));
    expect(keyboard.usedLetters, contains('Q'));

    h.game.stopTimer();
  });

  testWidgets('undo restores the previous guess', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final session = h.game.session!;
    final first = h.game.selectedCipherLetter!;
    h.game.enterGuess('Q');
    expect(session.guesses[first], 'Q');

    h.game.undo();
    expect(session.guesses.containsKey(first), isFalse);

    h.game.stopTimer();
  });
}
