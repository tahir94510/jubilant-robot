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
    'smart cursor: typing skips already-filled cells onto the next EMPTY one',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;
      // "LESS IS MORE": cells 0 (L), 1 (E), 2 (S) are three distinct letters.
      expect(s.cipherText[0], isNot(s.cipherText[1]));
      expect(s.cipherText[1], isNot(s.cipherText[2]));

      // Pre-fill cell 1 (E) so there is a filled cell for the cursor to skip.
      game.selectIndex(1);
      game.enterGuess('Q');

      // Type into cell 0 (L): the cursor must SKIP the now-filled cell 1 and
      // land on the next EMPTY cell (2, an S) — never pause on a filled copy.
      game.selectIndex(0);
      game.enterGuess('W');

      expect(game.selectedIndex, 2);
      expect(game.selectedCipherLetter, s.cipherText[2]);

      game.stopTimer();
      game.dispose();
    },
  );

  test(
    'the last-entered highlight is stable: it survives delete/undo, moves only '
    'on a new letter, and clears on solve',
    () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      final cipherS = s.cipher.encryptLetter('S');
      final cipherL = s.cipher.encryptLetter('L');

      game.selectCipherLetter(cipherS);
      game.enterGuess('S');
      expect(game.lastEnteredCipherLetter, cipherS);

      // Delete and undo must NOT move the highlight off the last letter — it is
      // anchored to the letter, not to the cursor or the edit history.
      game.clearGuess();
      expect(game.lastEnteredCipherLetter, cipherS);
      game.undo();
      expect(game.lastEnteredCipherLetter, cipherS);

      // Typing a DIFFERENT letter moves the highlight to it.
      game.selectCipherLetter(cipherL);
      game.enterGuess('L');
      expect(game.lastEnteredCipherLetter, cipherL);

      // Solving the whole puzzle clears it so the finished board reads clean.
      for (final plain in ['L', 'E', 'S', 'I', 'M', 'O', 'R']) {
        game.selectCipherLetter(s.cipher.encryptLetter(plain));
        game.enterGuess(plain);
      }
      expect(game.completed, isTrue);
      expect(game.lastEnteredCipherLetter, isNull);

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

  test('a HINT reveal sets the last-move highlight, and cursor navigation never '
      'disturbs it', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    // A hint counts as a "last found" letter (not only typing): the revealed
    // letter becomes the last-move highlight.
    game.revealSelected();
    final revealed = s.revealed.first;
    expect(game.lastEnteredCipherLetter, revealed);

    // Prev/next-letter navigation must NOT move the highlight — it is anchored
    // to the letter, never to the cursor.
    game.moveSelection(1);
    game.moveSelection(-1);
    expect(game.lastEnteredCipherLetter, revealed);

    // Typing a DIFFERENT letter then moves the highlight to it.
    final other = s.cipherLetters.firstWhere(
      (c) => c != revealed && !s.revealed.contains(c),
    );
    game.selectCipherLetter(other);
    game.enterGuess('Z');
    expect(game.lastEnteredCipherLetter, other);

    game.stopTimer();
    game.dispose();
  });

  test('with every editable cell filled (none locked), typing cycles the cursor '
      'onto the next filled cell instead of sticking', () async {
    final store = await storage();
    final game = GameController(storage: store);
    game.start(shortQuote, daily: false);
    final s = game.session!;

    // Fill every distinct cipher letter with a deliberately WRONG, distinct
    // plain so no word ever completes (nothing locks): the board is full but
    // fully editable.
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final used = <String>{};
    for (final c in s.cipherLetters) {
      final correct = s.cipher.decryptLetter(c);
      final plain = alphabet
          .split('')
          .firstWhere((p) => p != correct && !used.contains(p));
      used.add(plain);
      game.selectCipherLetter(c);
      game.enterGuess(plain);
    }
    expect(game.completed, isFalse);
    expect(s.confirmedLetters, isEmpty);
    expect(s.guesses.length, s.cipherLetters.length);

    // There is no empty cell left to jump to, so typing on cell 0 must advance
    // to the NEXT editable (filled, non-locked) cell — it cycles, never sticks.
    game.selectIndex(0);
    final g0 = s.guesses[s.cipherText[0]]!;
    game.enterGuess(
      g0,
    ); // re-type the same letter: a no-op edit that still walks
    expect(game.selectedIndex, isNot(0));
    expect(game.selectedCipherLetter, isNotNull);

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
        // The GLOBAL record (what Home reads) points at the same quote,
        // regardless of UI language.
        final global = game.lastOpenGlobal();
        expect(global, isNotNull);
        expect(global!.quoteId, shortQuote.id);
        expect(global.packId, 'wisdom');

        game.stopTimer();
        game.dispose();
      },
    );

    test('the daily never participates in the Continue card', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: true);
      expect(game.lastOpen('en'), isNull);
      expect(game.lastOpenGlobal(), isNull);

      game.stopTimer();
      game.dispose();
    });
  });

  group('cursor navigation', () {
    test('moveSelection wraps around the ends; ◀ ▶ stay enabled', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;
      final t = s.cipherText;
      final letterPositions = [
        for (var i = 0; i < t.length; i++)
          if (s.cipherLetters.contains(t[i])) i,
      ];
      final first = letterPositions.first;
      final last = letterPositions.last;

      // With >= 2 editable cells both controls stay enabled everywhere.
      game.selectIndex(first);
      expect(game.canMovePrev, isTrue);
      expect(game.canMoveNext, isTrue);
      // ◀ on the FIRST letter wraps to the LAST.
      game.moveSelection(-1);
      expect(game.selectedIndex, last);

      // ▶ on the LAST letter wraps back to the FIRST.
      game.selectIndex(last);
      expect(game.canMoveNext, isTrue);
      expect(game.canMovePrev, isTrue);
      game.moveSelection(1);
      expect(game.selectedIndex, first);

      // Moving forward from the first lands on the next letter (no wrap yet).
      game.selectIndex(first);
      game.moveSelection(1);
      expect(game.selectedIndex, greaterThan(first));

      game.stopTimer();
      game.dispose();
    });

    test(
      'prev/next skip locked cells and the cursor only rests on editable ones',
      () async {
        final store = await storage();
        final game = GameController(storage: store);
        game.start(shortQuote, daily: false);
        final s = game.session!;

        // Reveal the first letter so all of its cells become locked.
        game.selectIndex(0);
        game.revealSelected();
        expect(s.revealed, isNotEmpty);

        bool editable(int i) =>
            s.cipherLetters.contains(s.cipherText[i]) &&
            !s.revealed.contains(s.cipherText[i]) &&
            !s.confirmedLetters.contains(s.cipherText[i]);

        final editablePositions = [
          for (var i = 0; i < s.cipherText.length; i++)
            if (editable(i)) i,
        ];
        final firstEditable = editablePositions.first;
        final lastEditable = editablePositions.last;

        // Walk forward across every editable cell: each landing must be editable
        // (locked cells are skipped, so the cursor never visually vanishes). A
        // BOUNDED loop — moveSelection now wraps, so `while (canMoveNext)` would
        // never end.
        game.selectIndex(firstEditable);
        expect(game.selectedCipherLetter, isNotNull);
        for (var k = 0; k < editablePositions.length - 1; k++) {
          game.moveSelection(1);
          expect(editable(game.selectedIndex!), isTrue);
          expect(game.selectedCipherLetter, isNotNull);
        }
        // ...now sitting on the last editable cell.
        expect(game.selectedIndex, lastEditable);

        // ▶ on the last wraps to the first; ◀ on the first wraps back to last.
        game.moveSelection(1);
        expect(game.selectedIndex, firstEditable);
        game.moveSelection(-1);
        expect(game.selectedIndex, lastEditable);

        // Walking back across every editable cell lands on the first again.
        for (var k = 0; k < editablePositions.length - 1; k++) {
          game.moveSelection(-1);
          expect(editable(game.selectedIndex!), isTrue);
        }
        expect(game.selectedIndex, firstEditable);

        game.stopTimer();
        game.dispose();
      },
    );

    test(
      'forward from the last editable cell wraps past a locked tail to the first',
      () async {
        final store = await storage();
        final game = GameController(storage: store);
        game.start(shortQuote, daily: false);
        final s = game.session!;
        final t = s.cipherText;
        final letterPositions = [
          for (var i = 0; i < t.length; i++)
            if (s.cipherLetters.contains(t[i])) i,
        ];

        // Reveal the letter sitting in the LAST board position, locking it.
        game.selectIndex(letterPositions.last);
        game.revealSelected();
        expect(s.revealed.contains(t[letterPositions.last]), isTrue);

        bool editable(int i) =>
            s.cipherLetters.contains(t[i]) &&
            !s.revealed.contains(t[i]) &&
            !s.confirmedLetters.contains(t[i]);
        final editablePositions = letterPositions.where(editable).toList();
        final firstEditable = editablePositions.first;
        final lastEditable = editablePositions.last;

        // Sitting on the last editable cell, only a locked cell remains ahead.
        // ▶ stays enabled and WRAPS past the locked tail onto the first editable
        // cell — it never strands the cursor on a locked cell.
        game.selectIndex(lastEditable);
        expect(game.canMoveNext, isTrue);
        game.moveSelection(1);
        expect(editable(game.selectedIndex!), isTrue);
        expect(game.selectedIndex, firstEditable);

        game.stopTimer();
        game.dispose();
      },
    );

    test('tapping a locked cell does not move the cursor onto it', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      // Reveal the first letter, then place the cursor on an editable cell.
      game.selectIndex(0);
      game.revealSelected();
      final lockedPos = [
        for (var i = 0; i < s.cipherText.length; i++)
          if (s.revealed.contains(s.cipherText[i])) i,
      ].first;
      final editablePos = [
        for (var i = 0; i < s.cipherText.length; i++)
          if (s.cipherLetters.contains(s.cipherText[i]) &&
              !s.revealed.contains(s.cipherText[i]) &&
              !s.confirmedLetters.contains(s.cipherText[i]))
            i,
      ].first;
      game.selectIndex(editablePos);

      // A tap on a locked cell is ignored — the cursor stays put and visible.
      game.selectIndex(lockedPos);
      expect(game.selectedIndex, editablePos);
      expect(game.selectedCipherLetter, isNotNull);

      game.stopTimer();
      game.dispose();
    });
  });

  group('same-letter retype', () {
    test('retyping the cell\'s current letter skips ahead without a new undo '
        'entry', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      game.selectIndex(0);
      final c0 = game.selectedCipherLetter!;
      game.enterGuess('X'); // fills c0, advances; one undo entry
      expect(s.guesses[c0], 'X');

      // Go back to c0 and type the SAME letter: no rewrite, no extra undo entry,
      // and the cursor simply walks forward to the next editable cell.
      game.selectCipherLetter(c0);
      expect(game.canUndo, isTrue);
      game.enterGuess('X');
      expect(s.guesses[c0], 'X'); // unchanged
      expect(game.selectedCipherLetter, isNot(c0)); // advanced past it

      // Undo once returns to the only real edit (filling c0); nothing stacked
      // up from the redundant re-type.
      game.undo();
      expect(s.guesses.containsKey(c0), isFalse);
      expect(game.canUndo, isFalse);

      game.stopTimer();
      game.dispose();
    });
  });

  group('conflict feedback', () {
    test('a conflicting guess is flagged on the same keystroke', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      // "LESS IS MORE": cells 0 and 1 are distinct cipher letters (L, E).
      final c0 = s.cipherText[0];
      final c1 = s.cipherText[1];
      expect(c0, isNot(c1));

      game.selectIndex(0);
      game.enterGuess('Z');
      game.selectIndex(1);
      game.enterGuess('Z'); // same plaintext on a different cipher letter

      // The conflict is known immediately (drives the red cell + shake) — the UI
      // no longer has to wait for the cursor to advance off the cell.
      expect(game.lastInputCreatedConflict, isTrue);
      expect(s.conflicts.contains(c0), isTrue);
      expect(s.conflicts.contains(c1), isTrue);

      game.stopTimer();
      game.dispose();
    });
  });

  group('hint cursor direction', () {
    test('revealing advances forward from the cursor, not back to an earlier '
        'copy of the revealed letter', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;
      final t = s.cipherText;

      // A cipher letter with a later occurrence that still has editable cells
      // after it (so "advance forward" is observable, not a wrap).
      final repeated = s.cipherLetters.firstWhere((c) {
        final positions = [
          for (var i = 0; i < t.length; i++)
            if (t[i] == c) i,
        ];
        return positions.length >= 2 &&
            positions.last < t.length - 1 &&
            [
              for (var i = positions.last + 1; i < t.length; i++) i,
            ].any((i) => s.cipherLetters.contains(t[i]) && t[i] != c);
      });
      final positions = [
        for (var i = 0; i < t.length; i++)
          if (t[i] == repeated) i,
      ];

      // Sit on the LAST copy and reveal it: the cursor must move FORWARD past
      // it, never jump back toward the first copy.
      game.selectIndex(positions.last);
      game.revealSelected();
      expect(game.selectedIndex, greaterThan(positions.last));

      game.stopTimer();
      game.dispose();
    });
  });

  group('redo', () {
    test(
      'redo re-applies an undone guess; a new edit clears the redo future',
      () async {
        final store = await storage();
        final game = GameController(storage: store);
        game.start(shortQuote, daily: false);
        final s = game.session!;

        game.selectIndex(0);
        final c0 = game.selectedCipherLetter!;
        game.enterGuess('Q');
        expect(s.guesses[c0], 'Q');
        expect(game.canRedo, isFalse);

        game.undo();
        expect(s.guesses.containsKey(c0), isFalse);
        expect(game.canRedo, isTrue);

        game.redo();
        expect(s.guesses[c0], 'Q');
        expect(game.canRedo, isFalse);
        expect(game.canUndo, isTrue);

        // Undo again, then a NEW edit must invalidate the redo future.
        game.undo();
        expect(game.canRedo, isTrue);
        game.selectIndex(0);
        game.enterGuess('Z');
        expect(game.canRedo, isFalse);

        game.stopTimer();
        game.dispose();
      },
    );

    test('redo history survives leaving and re-entering the puzzle', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final c0 = game.session!.cipherLetters.first;
      game.selectCipherLetter(c0);
      game.enterGuess('Q');
      game.undo();
      expect(game.canRedo, isTrue);
      game.stopTimer();

      final resumed = GameController(storage: store);
      resumed.start(shortQuote, daily: false);
      expect(resumed.canRedo, isTrue, reason: 'redo stack must persist');
      resumed.redo();
      expect(resumed.session!.guesses[c0], 'Q');

      resumed.stopTimer();
      game.dispose();
      resumed.dispose();
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
