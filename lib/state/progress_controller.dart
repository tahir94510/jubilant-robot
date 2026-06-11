import 'package:flutter/foundation.dart';

import '../models/achievement.dart';
import '../models/game_stats.dart';
import '../services/clock.dart';
import '../services/storage_service.dart';

/// Owns [GameStats]: solve recording, daily streaks, achievements.
class ProgressController extends ChangeNotifier {
  ProgressController({required StorageService storage, Clock clock = const Clock()})
      : _storage = storage,
        _clock = clock,
        stats = GameStats.fromJson(
            storage.readJson(StorageService.statsKey) ?? const {}) {
    final unlocked =
        storage.readJson(StorageService.achievementsKey) ?? const {};
    _unlockedIds.addAll(
        (unlocked['ids'] as List<dynamic>? ?? const []).cast<String>());
  }

  final StorageService _storage;
  final Clock _clock;

  final GameStats stats;
  final Set<String> _unlockedIds = {};

  Set<String> get unlockedAchievementIds => Set.unmodifiable(_unlockedIds);

  bool isSolved(String quoteId) => stats.solvedIds.contains(quoteId);

  /// Records a completed puzzle and returns achievements newly unlocked by
  /// it (for celebration UI).
  Future<List<Achievement>> recordSolve({
    required String quoteId,
    required Duration solveTime,
    required int hintsUsed,
    required bool isDaily,
  }) async {
    final firstTimeSolve = stats.solvedIds.add(quoteId);
    if (firstTimeSolve) {
      stats.totalSolved += 1;
      if (hintsUsed == 0) stats.noHintSolves += 1;
    }
    stats.hintsUsed += hintsUsed;
    stats.totalTimeSeconds += solveTime.inSeconds;
    final seconds = solveTime.inSeconds;
    if (seconds > 0 &&
        (stats.bestTimeSeconds == null || seconds < stats.bestTimeSeconds!)) {
      stats.bestTimeSeconds = seconds;
    }

    if (isDaily) _recordDailySolve();

    final newAchievements = _evaluateAchievements();
    await _persist();
    notifyListeners();
    return newAchievements;
  }

  void _recordDailySolve() {
    final today = dateKey(_clock.now());
    if (stats.dailyHistory[today] == true) return; // already counted

    stats.dailyHistory[today] = true;

    final yesterday =
        dateKey(_clock.now().subtract(const Duration(days: 1)));
    if (stats.lastDailyDate == yesterday) {
      stats.currentStreak += 1;
    } else if (stats.lastDailyDate != today) {
      stats.currentStreak = 1;
    }
    stats.lastDailyDate = today;
    if (stats.currentStreak > stats.bestStreak) {
      stats.bestStreak = stats.currentStreak;
    }
  }

  /// The streak shown in the UI: drops to zero visually when yesterday was
  /// missed and today is not yet solved.
  int get displayStreak {
    final last = stats.lastDailyDate;
    if (last == null) return 0;
    final today = dateKey(_clock.now());
    final yesterday =
        dateKey(_clock.now().subtract(const Duration(days: 1)));
    if (last == today || last == yesterday) return stats.currentStreak;
    return 0;
  }

  bool get dailySolvedToday =>
      stats.dailyHistory[dateKey(_clock.now())] == true;

  List<Achievement> _evaluateAchievements() {
    final fresh = <Achievement>[];
    for (final a in Achievement.catalog) {
      if (!_unlockedIds.contains(a.id) && a.isUnlocked(stats)) {
        _unlockedIds.add(a.id);
        fresh.add(a);
      }
    }
    return fresh;
  }

  Future<void> _persist() async {
    await _storage.writeJson(StorageService.statsKey, stats.toJson());
    await _storage.writeJson(
        StorageService.achievementsKey, {'ids': _unlockedIds.toList()});
  }
}
