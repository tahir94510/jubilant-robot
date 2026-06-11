import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

Future<ProgressController> _controller(FakeClock clock) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.init();
  return ProgressController(storage: storage, clock: clock);
}

Future<void> _solveDaily(ProgressController p, String id) =>
    p.recordSolve(
      quoteId: id,
      solveTime: const Duration(minutes: 2),
      hintsUsed: 0,
      isDaily: true,
    );

void main() {
  group('daily streak', () {
    test('consecutive days increment the streak', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      expect(p.stats.currentStreak, 1);

      clock.advanceDays(1);
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 2);

      clock.advanceDays(1);
      await _solveDaily(p, 'c');
      expect(p.stats.currentStreak, 3);
      expect(p.stats.bestStreak, 3);
    });

    test('a missed day resets the streak to 1', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      clock.advanceDays(1);
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 2);

      clock.advanceDays(2); // skip a day
      await _solveDaily(p, 'c');
      expect(p.stats.currentStreak, 1);
      expect(p.stats.bestStreak, 2);
    });

    test('two solves on the same day count once', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      await _solveDaily(p, 'a2');
      expect(p.stats.currentStreak, 1);
      expect(p.stats.dailyHistory.length, 1);
    });

    test('23:59 then 00:01 next day counts as consecutive', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 23, 59));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      clock.value = DateTime(2026, 6, 11, 0, 1);
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 2);
    });

    test('displayStreak hides a stale streak until re-earned', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      expect(p.displayStreak, 1);

      clock.advanceDays(1); // yesterday solved -> still shown
      expect(p.displayStreak, 1);

      clock.advanceDays(1); // gap -> visually zero
      expect(p.displayStreak, 0);
    });

    test('non-daily solves never touch the streak', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);
      await p.recordSolve(
        quoteId: 'pack-quote',
        solveTime: const Duration(minutes: 1),
        hintsUsed: 2,
        isDaily: false,
      );
      expect(p.stats.currentStreak, 0);
      expect(p.stats.dailyHistory, isEmpty);
      expect(p.stats.totalSolved, 1);
    });
  });

  group('solve stats', () {
    test('replaying a solved puzzle does not double count', () async {
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p = await _controller(clock);
      await p.recordSolve(
          quoteId: 'x',
          solveTime: const Duration(seconds: 90),
          hintsUsed: 0,
          isDaily: false);
      await p.recordSolve(
          quoteId: 'x',
          solveTime: const Duration(seconds: 50),
          hintsUsed: 0,
          isDaily: false);
      expect(p.stats.totalSolved, 1);
      expect(p.stats.bestTimeSeconds, 50);
    });

    test('persists and reloads through storage', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final clock = FakeClock(DateTime(2026, 6, 10, 9));
      final p1 = ProgressController(storage: storage, clock: clock);
      await _solveDaily(p1, 'a');

      final p2 = ProgressController(storage: storage, clock: clock);
      expect(p2.stats.totalSolved, 1);
      expect(p2.stats.currentStreak, 1);
      expect(p2.isSolved('a'), isTrue);
    });
  });
}
