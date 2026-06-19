import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/game_stats.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

/// Locks the per-language profile model: solves, streaks and daily history are
/// scoped per content language, while achievements stay global (lifetime).
void main() {
  Future<StorageService> emptyStorage() async {
    SharedPreferences.setMockInitialValues({});
    return StorageService.init();
  }

  test(
    'solves are bucketed per language; isSolved and aggregate are global',
    () async {
      final storage = await emptyStorage();
      final p = ProgressController(
        storage: storage,
        clock: FakeClock(DateTime(2026, 6, 10, 9)),
      );

      await p.recordSolve(
        quoteId: 'en-1',
        solveTime: const Duration(seconds: 90),
        hintsUsed: 0,
        isDaily: false,
        locale: 'en',
      );
      await p.recordSolve(
        quoteId: 'tr-1',
        solveTime: const Duration(seconds: 80),
        hintsUsed: 0,
        isDaily: false,
        locale: 'tr',
      );
      await p.recordSolve(
        quoteId: 'tr-2',
        solveTime: const Duration(seconds: 70),
        hintsUsed: 0,
        isDaily: false,
        locale: 'tr',
      );

      expect(p.statsFor('en').totalSolved, 1);
      expect(p.statsFor('tr').totalSolved, 2);
      expect(p.statsFor('de').totalSolved, 0);

      // Membership is global (ids are language-specific, so this is unambiguous).
      expect(p.isSolved('en-1'), isTrue);
      expect(p.isSolved('tr-2'), isTrue);
      expect(p.isSolved('de-9'), isFalse);

      // Aggregate sums across every language.
      expect(p.aggregate.totalSolved, 3);
      expect(p.aggregate.bestTimeSeconds, 70);
    },
  );

  test(
    'daily streak is per language: solving one language does not mark another',
    () async {
      final storage = await emptyStorage();
      final p = ProgressController(
        storage: storage,
        clock: FakeClock(DateTime(2026, 6, 10, 9)),
      );

      await p.recordSolve(
        quoteId: 'en-d',
        solveTime: const Duration(minutes: 1),
        hintsUsed: 0,
        isDaily: true,
        locale: 'en',
      );

      expect(p.dailySolvedTodayFor('en'), isTrue);
      expect(p.dailySolvedTodayFor('tr'), isFalse);
      expect(p.displayStreakFor('en'), 1);
      expect(p.displayStreakFor('tr'), 0);
    },
  );

  test('achievements evaluate on the cross-language aggregate', () async {
    final storage = await emptyStorage();
    final p = ProgressController(
      storage: storage,
      clock: FakeClock(DateTime(2026, 6, 10, 9)),
    );

    // Five solves spread across two languages: the global "solve 5"-style
    // milestones must see the combined total, not any single bucket.
    for (var i = 0; i < 3; i++) {
      await p.recordSolve(
        quoteId: 'en-$i',
        solveTime: const Duration(seconds: 200),
        hintsUsed: 1,
        isDaily: false,
        locale: 'en',
      );
    }
    final last = await p.recordSolve(
      quoteId: 'tr-x',
      solveTime: const Duration(seconds: 200),
      hintsUsed: 1,
      isDaily: false,
      locale: 'tr',
    );
    // first_solve unlocked on the very first; by now totalSolved aggregate = 4.
    expect(p.unlockedAchievementIds, contains('first_solve'));
    expect(p.aggregate.totalSolved, 4);
    // The tr solve didn't re-unlock first_solve (idempotent / already owned).
    expect(last.map((a) => a.id), isNot(contains('first_solve')));
  });

  test('migrates a legacy stats.v1 blob into per-language buckets', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    // Seed a legacy all-languages blob: two English + one Turkish solve, plus
    // counters that can't be attributed after the fact.
    final legacy = GameStats(
      totalSolved: 3,
      noHintSolves: 2,
      bestTimeSeconds: 42,
      totalTimeSeconds: 600,
      hintsUsed: 5,
      currentStreak: 4,
      bestStreak: 9,
      lastDailyDate: '2026-06-09',
      solvedIds: {'en-1', 'en-2', 'tr-1'},
      dailyHistory: {'2026-06-09': true},
    );
    await storage.writeJson(StorageService.statsKey, legacy.toJson());

    final p = ProgressController(
      storage: storage,
      clock: FakeClock(DateTime(2026, 6, 10, 9)),
      quoteLocales: {'en-1': 'en', 'en-2': 'en', 'tr-1': 'tr'},
      migrationLocale: 'tr',
    );

    // Solves land in their real language; pack progress is now correct.
    expect(p.statsFor('en').solvedIds, {'en-1', 'en-2'});
    expect(p.statsFor('tr').solvedIds, {'tr-1'});
    expect(p.statsFor('en').totalSolved, 2);
    expect(p.statsFor('tr').totalSolved, 1);

    // The aggregate preserves the lifetime totals, so achievements never
    // regress after the migration.
    final agg = p.aggregate;
    expect(agg.totalSolved, 3);
    expect(agg.noHintSolves, 2);
    expect(agg.bestTimeSeconds, 42);
    expect(agg.bestStreak, 9);
    expect(agg.dailyHistory['2026-06-09'], isTrue);

    // A second controller reads the persisted stats.v2 (no re-migration).
    final p2 = ProgressController(
      storage: storage,
      clock: FakeClock(DateTime(2026, 6, 10, 9)),
    );
    expect(p2.statsFor('en').totalSolved, 2);
    expect(p2.statsFor('tr').totalSolved, 1);
  });

  test(
    'app updates preserve data: stats.v2 reloads identically across restarts',
    () async {
      // SharedPreferences survives a Play update (only uninstall/clear wipes
      // it). This locks that reloading stats.v2 repeatedly never loses or
      // mutates the per-language profile — the exact concern after an update.
      final storage = await emptyStorage();
      final p = ProgressController(
        storage: storage,
        clock: FakeClock(DateTime(2026, 6, 10, 9)),
      );
      await p.recordSolve(
        quoteId: 'en-1',
        solveTime: const Duration(seconds: 90),
        hintsUsed: 0,
        isDaily: true,
        locale: 'en',
      );
      await p.recordSolve(
        quoteId: 'tr-1',
        solveTime: const Duration(seconds: 80),
        hintsUsed: 2,
        isDaily: false,
        locale: 'tr',
      );

      // Simulate three "app launches" reading the SAME persisted store.
      for (var launch = 0; launch < 3; launch++) {
        final reloaded = ProgressController(
          storage: storage,
          clock: FakeClock(DateTime(2026, 6, 10, 9)),
        );
        expect(reloaded.statsFor('en').totalSolved, 1);
        expect(reloaded.statsFor('tr').totalSolved, 1);
        expect(reloaded.displayStreakFor('en'), 1);
        expect(reloaded.statsFor('tr').hintsUsed, 2);
        expect(reloaded.isSolved('en-1'), isTrue);
        expect(reloaded.isSolved('tr-1'), isTrue);
        expect(reloaded.aggregate.totalSolved, 2);
      }
    },
  );
}
