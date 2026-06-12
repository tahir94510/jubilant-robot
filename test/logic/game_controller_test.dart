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
}
