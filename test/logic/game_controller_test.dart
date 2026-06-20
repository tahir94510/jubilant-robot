import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/game_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/test_harness.dart';

/// Locks the hint counter semantics shown on the solve screen ("17 hints" =
/// 17 reveal taps) and its persistence across app restarts.
void main() {
  Future<StorageService> storage() async {
    SharedPreferences.setMockInitialValues({});
    return StorageService.init();
  }

  test('hintsUsed counts one per reveal and survives a restart', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);

    game.revealSelected();
    game.revealSelected();
    expect(game.hintsUsed, 2);
    expect(game.session!.revealed.length, 2);
    game.stopTimer();

    // A fresh controller (new process) resumes the same puzzle state.
    final resumed = GameController(storage: store);
    resumed.start(shortQuote, daily: false);
    expect(resumed.hintsUsed, 2);
    expect(resumed.session!.revealed.length, 2);
    for (final ch in resumed.session!.revealed) {
      expect(
        resumed.session!.guesses[ch],
        resumed.session!.cipher.decryptLetter(ch),
      );
    }
    resumed.stopTimer();
    game.dispose();
    resumed.dispose();
  });

  test(
    'undo restores the cursor to the exact edited cell, not the first copy',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;
      final text = s.cipherText;

      // A cipher letter that appears at least twice on the board.
      final repeated = s.cipherLetters.firstWhere(
        (c) => text.split('').where((ch) => ch == c).length >= 2,
      );
      final positions = [
        for (var i = 0; i < text.length; i++)
          if (text[i] == repeated) i,
      ];
      final second = positions[1];

      // Tap the SECOND copy, type, then undo.
      game.selectIndex(second);
      game.enterGuess('A');
      game.undo();

      // The cursor must return to the cell we actually edited, never the first
      // occurrence (the old bug flung it back to positions[0]).
      expect(game.selectedIndex, second);
      expect(game.selectedIndex, isNot(positions[0]));

      game.stopTimer();
      game.dispose();
    },
  );

  test(
    're-opening a solved puzzle starts a fresh board; the answer is shown only '
    'on demand',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);

      // Reveal everything: the last reveal completes the puzzle.
      while (!game.completed) {
        game.revealSelected();
      }
      expect(game.hintsUsed, greaterThan(0));
      expect(game.session!.isSolved, isTrue);

      // Re-opening NEVER spoils the answer: the board is blank and fully
      // playable, just flagged as previously solved so the UI can offer a
      // "Show solution" affordance.
      final review = GameController(storage: store);
      review.start(shortQuote, daily: false);
      expect(review.reviewingSolved, isFalse);
      expect(review.previouslySolved, isTrue);
      expect(review.session!.guesses, isEmpty);
      expect(review.session!.isSolved, isFalse);

      // The player makes a partial guess, then peeks at the solution.
      review.selectIndex(0);
      final firstLetter = review.selectedCipherLetter!;
      review.enterGuess('A');
      final attempt = Map.of(review.session!.guesses);

      review.showSolution();
      expect(review.reviewingSolved, isTrue);
      expect(review.session!.isSolved, isTrue);

      // Returning restores the exact in-progress attempt, untouched.
      review.returnToAttempt();
      expect(review.reviewingSolved, isFalse);
      expect(review.session!.guesses, attempt);
      expect(review.session!.guesses[firstLetter], 'A');

      // Play again wipes the board back to a fresh attempt.
      review.replay();
      expect(review.previouslySolved, isTrue);
      expect(review.hintsUsed, 0);
      expect(review.elapsed, Duration.zero);
      expect(review.session!.guesses, isEmpty);
      expect(review.session!.revealed, isEmpty);
      review.stopTimer();
      game.dispose();
      review.dispose();
    },
  );

  test('smart backspace: clears the current cell when filled, otherwise steps '
      'back to the previous entry and clears that', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    game.selectIndex(0);
    final c0 = game.selectedCipherLetter!;
    game.enterGuess('X'); // fills c0, auto-advances to the next empty cell
    expect(s.guesses[c0], 'X');
    expect(game.selectedCipherLetter, isNot(c0));

    // Cursor is on an empty cell: backspace steps back to c0 and clears it.
    game.clearGuess();
    expect(s.guesses.containsKey(c0), isFalse);
    expect(game.selectedCipherLetter, c0);

    // c0 is selected and filled again: backspace clears it in place.
    game.enterGuess('Y');
    game.selectCipherLetter(c0);
    expect(s.guesses[c0], 'Y');
    game.clearGuess();
    expect(s.guesses.containsKey(c0), isFalse);
    expect(game.selectedCipherLetter, c0);

    game.stopTimer();
    game.dispose();
  });

  test(
    'completing a whole word locks its letters: they turn confirmed and resist '
    'further edits',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      // "Less is more." — the 2-letter middle word "is" is the quickest to
      // complete correctly. Fill both of its letters with the right answers.
      final isWord = s.cipherText.split(' ')[1];
      expect(isWord.length, 2);
      for (final c in isWord.split('')) {
        game.selectCipherLetter(c);
        game.enterGuess(s.cipher.decryptLetter(c));
      }

      final lockedLetters = isWord.split('').toSet();
      expect(s.confirmedLetters.containsAll(lockedLetters), isTrue);

      // A confirmed letter is locked: typing over it is ignored.
      final locked = isWord[0];
      final before = s.guesses[locked];
      game.selectCipherLetter(locked);
      game.enterGuess('Z');
      expect(s.guesses[locked], before);

      // And backspace skips it too (steps past to an editable cell instead).
      game.selectCipherLetter(locked);
      game.clearGuess();
      expect(s.guesses[locked], before);

      game.stopTimer();
      game.dispose();
    },
  );

  test('undo never reverts a confirmed (completed-word) letter', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    final isWord = s.cipherText.split(' ')[1]; // "is"
    for (final c in isWord.split('')) {
      game.selectCipherLetter(c);
      game.enterGuess(s.cipher.decryptLetter(c));
    }
    final locked = isWord.split('').toSet();
    expect(s.confirmedLetters.containsAll(locked), isTrue);

    final before = Map.of(s.guesses);
    game.undo(); // must leave the confirmed word intact
    for (final c in locked) {
      expect(s.guesses[c], before[c]);
    }
    expect(s.confirmedLetters.containsAll(locked), isTrue);

    game.stopTimer();
    game.dispose();
  });

  test(
    'typing advances onto the next editable cell even when it is filled',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;
      // "LESS IS MORE": cells 0 and 1 are distinct letters (L, E).
      expect(s.cipherText[0], isNot(s.cipherText[1]));

      game.selectIndex(1);
      final c1 = game.selectedCipherLetter!;
      game.enterGuess('Q'); // fill cell 1 with a wrong, non-completing letter
      game.selectIndex(0);
      game.enterGuess('W'); // fill cell 0; cursor should step onto cell 1

      expect(game.selectedIndex, 1);
      expect(game.selectedCipherLetter, c1);

      game.stopTimer();
      game.dispose();
    },
  );

  test('typing advances the cursor forward, never back to the start', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    final cipherL = s.cipher.encryptLetter('L'); // first letter of the quote
    final cipherM = s.cipher.encryptLetter('M'); // start of the last word
    final cipherO = s.cipher.encryptLetter('O'); // right after M in "more"

    // Fill a letter in the middle of the quote.
    game.selectCipherLetter(cipherM);
    game.enterGuess('M');

    // The cursor steps to the next empty letter AFTER M ("more" -> O), not
    // all the way back to the first empty letter (L) at the very start.
    expect(game.selectedCipherLetter, cipherO);
    expect(game.selectedCipherLetter, isNot(cipherL));

    game.stopTimer();
    game.dispose();
  });

  test(
    'typing into a repeated letter advances past THAT cell, not its first copy',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      final cipherS = s.cipher.encryptLetter('S'); // repeats: LeSS, iS
      final cipherI = s.cipher.encryptLetter('I'); // empty cell after first S
      final cipherM = s.cipher.encryptLetter('M'); // start of the last word

      // Select the LAST S on the board (the one in "is"), then type it.
      final positions = [
        for (var i = 0; i < s.cipherText.length; i++)
          if (s.cipherText[i] == cipherS) i,
      ];
      expect(positions.length, greaterThan(1));
      game.selectIndex(positions.last);
      game.enterGuess('S');

      // Cursor steps forward from that last S into "more" (M). The old bug
      // used indexOf(S) -> first S, landing the cursor back on the empty 'I'.
      expect(game.selectedCipherLetter, cipherM);
      expect(game.selectedCipherLetter, isNot(cipherI));

      game.stopTimer();
      game.dispose();
    },
  );

  test('undo history survives leaving and re-entering the puzzle', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    game.selectCipherLetter(s.cipher.encryptLetter('L'));
    game.enterGuess('L');
    game.selectCipherLetter(s.cipher.encryptLetter('E'));
    game.enterGuess('E');
    expect(game.canUndo, isTrue);
    game.stopTimer(); // back to the menu

    // A fresh controller (re-entering the puzzle) must restore the undo stack.
    final resumed = GameController(storage: store);
    resumed.start(shortQuote, daily: false);
    expect(resumed.canUndo, isTrue, reason: 'undo stack must persist');

    final eCipher = resumed.session!.cipher.encryptLetter('E');
    expect(resumed.session!.guesses[eCipher], 'E');
    resumed.undo(); // reverts the last guess (E)
    expect(resumed.session!.guesses.containsKey(eCipher), isFalse);

    resumed.stopTimer();
    game.dispose();
    resumed.dispose();
  });

  test('a corrupt saved state resumes fresh instead of crashing', () async {
    final store = await storage();
    // Garbage where structured data is expected (schema drift / partial write).
    store.writeJson(StorageService.puzzleStateKey(shortQuote.id), {
      'solved': false,
      'guesses': 'not-a-map',
      'revealed': 7,
      'elapsedSeconds': 'soon',
      'undo': 42,
    });

    final game = GameController(storage: store);
    game.start(shortQuote, daily: false); // must not throw
    expect(game.session!.guesses, isEmpty);
    expect(game.session!.revealed, isEmpty);
    expect(game.canUndo, isFalse);
    expect(game.elapsed, Duration.zero);

    game.stopTimer();
    game.dispose();
  });

  test(
    're-entering resumes the saved clock, not the time spent away',
    () async {
      final store = await storage();
      // A half-finished puzzle that was last left at 30s elapsed.
      store.writeJson(StorageService.puzzleStateKey(shortQuote.id), {
        'quoteId': shortQuote.id,
        'guesses': <String, String>{},
        'revealed': <String>[],
        'hintsUsed': 0,
        'elapsedSeconds': 30,
        'undo': <dynamic>[],
        'solved': false,
      });

      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      // Resumes exactly at 30s — time spent in the menu never inflates it.
      expect(game.elapsed, const Duration(seconds: 30));

      game.stopTimer();
      final saved = store.readJson(
        StorageService.puzzleStateKey(shortQuote.id),
      )!;
      expect(saved['elapsedSeconds'], 30);
      game.dispose();
    },
  );

  // "Less is more." — every real word counts: LESS (4), "is" (2), MORE (4).
  // Only single-letter words (none here) stay a quiet, trivial fill.
  group('word-complete signal', () {
    test('fires for real words (2+ letters), including short ones', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      void type(String plain) {
        game.selectCipherLetter(s.cipher.encryptLetter(plain));
        game.enterGuess(plain);
      }

      expect(s.correctWordCount, 0);
      type('L');
      expect(game.lastInputCompletedWord, isFalse);
      type('E');
      expect(game.lastInputCompletedWord, isFalse);
      type('S'); // completes LESS (4 letters)
      expect(game.lastInputCompletedWord, isTrue);
      expect(s.correctWordCount, 1);

      // Completing the 2-letter "is" now also earns the cue (S already set,
      // typing I finishes it): two-letter words are real words.
      type('I');
      expect(game.lastInputCompletedWord, isTrue);
      expect(s.correctWordCount, 2);

      game.stopTimer();
      game.dispose();
    });

    test('a wrong or conflicting guess never fires it', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      game.selectCipherLetter(s.cipher.encryptLetter('I'));
      game.enterGuess('I');
      // Wrong letter into S's cell: even though it touches the word IS,
      // nothing completed.
      game.selectCipherLetter(s.cipher.encryptLetter('S'));
      game.enterGuess('Z');
      expect(game.lastInputCompletedWord, isFalse);

      // A conflicting (duplicate) assignment is feedback territory for the
      // conflict cue, never the word cue.
      game.enterGuess('I');
      expect(game.lastInputCreatedConflict, isTrue);
      expect(game.lastInputCompletedWord, isFalse);

      game.stopTimer();
      game.dispose();
    });

    test('hints, clears, and undo reset it', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      void type(String plain) {
        game.selectCipherLetter(s.cipher.encryptLetter(plain));
        game.enterGuess(plain);
      }

      // Complete LESS (a real word) to arm the cue, then verify every
      // non-typing path clears it.
      type('L');
      type('E');
      type('S'); // completes LESS
      expect(game.lastInputCompletedWord, isTrue);

      // Undo disarms the one-shot cue; the completed word is locked, so undo
      // leaves it intact (never reverts a confirmed word).
      game.undo();
      expect(game.lastInputCompletedWord, isFalse);
      expect(s.correctWordCount, greaterThan(0));

      // Re-arm on a DIFFERENT word: typing I completes IS.
      type('I');
      expect(game.lastInputCompletedWord, isTrue);
      game.clearGuess();
      expect(game.lastInputCompletedWord, isFalse);

      game.revealSelected(); // hints have their own chime
      expect(game.lastInputCompletedWord, isFalse);

      game.stopTimer();
      game.dispose();
    });

    test(
      'the solving keystroke belongs to success, not the word cue',
      () async {
        final store = await storage();
        final game = GameController(storage: store);
        game.start(shortQuote, daily: false);
        final s = game.session!;

        void type(String plain) {
          game.selectCipherLetter(s.cipher.encryptLetter(plain));
          game.enterGuess(plain);
        }

        for (final plain in ['L', 'E', 'S', 'I', 'M', 'O']) {
          type(plain);
        }
        expect(game.completed, isFalse);

        type('R'); // finishes MORE and the whole puzzle at once
        expect(game.completed, isTrue);
        // LESS + "is" + MORE all count now.
        expect(game.session!.correctWordCount, 3);
        expect(game.lastInputCompletedWord, isFalse);

        game.dispose();
      },
    );
  });

  group('per-language last-open (Continue card)', () {
    test(
      'a non-daily start records last_open for that quote\'s language',
      () async {
        final store = await storage();
        final game = GameController(storage: store);
        game.start(shortQuote, daily: false, packId: 'wisdom');

        final last = game.lastOpen('en');
        expect(last, isNotNull);
        expect(last!.quoteId, shortQuote.id);
        expect(last.packId, 'wisdom');
        // Another language has nothing to continue.
        expect(game.lastOpen('tr'), isNull);

        game.stopTimer();
        game.dispose();
      },
    );

    test('the daily never participates in the Continue card', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: true);
      expect(game.lastOpen('en'), isNull);

      game.stopTimer();
      game.dispose();
    });
  });

  test(
    'canRevealMore is false once every letter is correct (no wasted hint)',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      // A fresh board has letters to reveal.
      expect(game.canRevealMore, isTrue);

      // Reveal everything; the moment all letters are correct it flips false so
      // the hint button disables and never spends a token on a finished board.
      while (game.canRevealMore) {
        game.revealSelected();
      }
      expect(s.isSolved, isTrue);
      expect(game.canRevealMore, isFalse);

      game.dispose();
    },
  );
}
