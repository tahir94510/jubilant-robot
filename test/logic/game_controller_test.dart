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
    'a solved puzzle restarts clean instead of resuming stale hints',
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

      // Replaying starts from scratch — no leftover guesses, hints, or clock.
      final replay = GameController(storage: store);
      replay.start(shortQuote, daily: false);
      expect(replay.hintsUsed, 0);
      expect(replay.elapsed, Duration.zero);
      expect(replay.session!.guesses, isEmpty);
      expect(replay.session!.revealed, isEmpty);
      replay.stopTimer();
      game.dispose();
      replay.dispose();
    },
  );

  // "Less is more." — three words: LESS, IS, MORE.
  group('word-complete signal', () {
    test('fires exactly when a typed guess finishes a word', () async {
      final store = await storage();
      final game = GameController(storage: store);
      game.start(shortQuote, daily: false);
      final s = game.session!;

      void type(String plain) {
        game.selectCipherLetter(s.cipher.encryptLetter(plain));
        game.enterGuess(plain);
      }

      expect(s.correctWordCount, 0);
      type('I'); // half of IS
      expect(game.lastInputCompletedWord, isFalse);
      type('S'); // completes IS (LESS still misses L and E)
      expect(game.lastInputCompletedWord, isTrue);
      expect(s.correctWordCount, 1);

      type('L');
      expect(game.lastInputCompletedWord, isFalse);
      type('E'); // completes LESS
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

      game.selectCipherLetter(s.cipher.encryptLetter('I'));
      game.enterGuess('I');
      game.selectCipherLetter(s.cipher.encryptLetter('S'));
      game.enterGuess('S');
      expect(game.lastInputCompletedWord, isTrue);

      game.undo();
      expect(game.lastInputCompletedWord, isFalse);
      game.enterGuess('S');
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
        expect(game.session!.correctWordCount, 3);
        expect(game.lastInputCompletedWord, isFalse);

        game.dispose();
      },
    );
  });
}
