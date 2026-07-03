import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/services/clock.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

Future<ProgressController> _controller(FakeClock clock) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.init();
  return ProgressController(storage: storage, clock: clock);
}

Future<void> _solveDaily(ProgressController p, String id) => p.recordSolve(
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

    test('Dec 31 to Jan 1 keeps the streak across the year boundary', () async {
      final clock = FakeClock(DateTime(2026, 12, 31, 21));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      expect(p.stats.currentStreak, 1);

      clock.value = DateTime(2027, 1, 1, 8);
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 2);
      expect(p.stats.bestStreak, 2);
      expect(p.displayStreak, 2);
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

    test('Feb 28 to Mar 1 is consecutive in a non-leap year', () async {
      final clock = FakeClock(DateTime(2026, 2, 28, 22));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      clock.value = DateTime(2026, 3, 1, 7);
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 2);
    });

    test('leap day keeps the streak: Feb 28 -> Feb 29 -> Mar 1', () async {
      final clock = FakeClock(DateTime(2028, 2, 28, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      clock.value = DateTime(2028, 2, 29, 9);
      await _solveDaily(p, 'b');
      clock.value = DateTime(2028, 3, 1, 9);
      await _solveDaily(p, 'c');
      expect(p.stats.currentStreak, 3);
    });

    test('a missed day across a month boundary resets to 1', () async {
      final clock = FakeClock(DateTime(2026, 2, 27, 9));
      final p = await _controller(clock);

      await _solveDaily(p, 'a');
      clock.value = DateTime(2026, 3, 1, 9); // Feb 28 was skipped
      await _solveDaily(p, 'b');
      expect(p.stats.currentStreak, 1);
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

  // The DST regression guard: CI runs in UTC, so a true timezone-transition
  // test isn't portable. Instead these lock the property that makes the fix
  // correct — yesterdayKey is pure CALENDAR arithmetic (never Duration math on
  // the absolute instant, which lands two days back after a spring-forward).
  group('yesterdayKey calendar semantics', () {
    test('mid-month', () {
      expect(yesterdayKey(DateTime(2026, 6, 11, 0, 30)), '2026-06-10');
    });

    test('month boundary normalizes day 0 into the previous month', () {
      expect(yesterdayKey(DateTime(2026, 3, 1, 0, 30)), '2026-02-28');
    });

    test('leap February is honored', () {
      expect(yesterdayKey(DateTime(2028, 3, 1)), '2028-02-29');
    });

    test('year boundary', () {
      expect(yesterdayKey(DateTime(2027, 1, 1)), '2026-12-31');
    });

    test('agrees with dateKey of the previous calendar day', () {
      final d = DateTime(2026, 8, 15, 23, 59);
      expect(yesterdayKey(d), dateKey(DateTime(2026, 8, 14)));
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
        isDaily: false,
      );
      await p.recordSolve(
        quoteId: 'x',
        solveTime: const Duration(seconds: 50),
        hintsUsed: 0,
        isDaily: false,
      );
      expect(p.stats.totalSolved, 1);
      // A replay is practice — it must NOT rewrite the best time (or any stat),
      // so the record stays at the first solve even though the replay was faster.
      expect(p.stats.bestTimeSeconds, 90);
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
