import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/achievement.dart';
import 'package:quotecrack/models/game_stats.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/progress_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

void main() {
  test('catalog ids are unique and predicates are total', () {
    final ids = Achievement.catalog.map((a) => a.id).toSet();
    expect(ids.length, Achievement.catalog.length);
    final empty = GameStats();
    for (final a in Achievement.catalog) {
      // Must evaluate without throwing on a fresh profile.
      expect(() => a.isUnlocked(empty), returnsNormally);
    }
  });

  test('first solve unlocks exactly the right achievements once', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final p = ProgressController(
        storage: storage, clock: FakeClock(DateTime(2026, 6, 10, 9)));

    final fresh = await p.recordSolve(
      quoteId: 'a',
      solveTime: const Duration(seconds: 45),
      hintsUsed: 0,
      isDaily: true,
    );
    final freshIds = fresh.map((a) => a.id).toSet();
    expect(freshIds, contains('first_solve'));
    expect(freshIds, contains('speed_60')); // 45s < 60s
    expect(freshIds, contains('speed_120'));
    expect(freshIds, isNot(contains('solve_10')));

    // Idempotent: the same milestones never unlock twice.
    final again = await p.recordSolve(
      quoteId: 'b',
      solveTime: const Duration(seconds: 50),
      hintsUsed: 1,
      isDaily: false,
    );
    expect(again.map((a) => a.id), isNot(contains('first_solve')));
  });

  test('thresholds fire exactly at their boundary', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final p = ProgressController(
        storage: storage, clock: FakeClock(DateTime(2026, 6, 10, 9)));

    for (var i = 1; i <= 10; i++) {
      final fresh = await p.recordSolve(
        quoteId: 'q$i',
        solveTime: const Duration(minutes: 3),
        hintsUsed: 1,
        isDaily: false,
      );
      final hasTen = fresh.any((a) => a.id == 'solve_10');
      expect(hasTen, i == 10, reason: 'at solve $i');
    }
  });

  test('unlocked set persists across restarts', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final clock = FakeClock(DateTime(2026, 6, 10, 9));
    final p1 = ProgressController(storage: storage, clock: clock);
    await p1.recordSolve(
      quoteId: 'a',
      solveTime: const Duration(seconds: 30),
      hintsUsed: 0,
      isDaily: false,
    );
    expect(p1.unlockedAchievementIds, contains('first_solve'));

    final p2 = ProgressController(storage: storage, clock: clock);
    expect(p2.unlockedAchievementIds, contains('first_solve'));
  });
}
