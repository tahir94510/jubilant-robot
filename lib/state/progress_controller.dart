import 'package:flutter/foundation.dart';

import '../models/achievement.dart';
import '../models/game_stats.dart';
import '../services/clock.dart';
import '../services/storage_service.dart';

/// Owns per-language [GameStats]: solve recording, daily streaks, pack
/// progress and achievements.
///
/// Each content language keeps its OWN profile — solves, streak, daily history
/// and pack progress are scoped to the language they were earned in. Premium,
/// hint tokens, settings and achievements stay GLOBAL: buy premium once and
/// every language is unlocked, and achievements reward lifetime mastery across
/// all languages (evaluated against the [aggregate] of every bucket).
class ProgressController extends ChangeNotifier {
  ProgressController({
    required StorageService storage,
    Clock clock = const Clock(),
    Map<String, String>? quoteLocales,
    String migrationLocale = 'en',
  }) : _storage = storage,
       _clock = clock,
       _viewLocale = migrationLocale {
    _load(quoteLocales: quoteLocales, migrationLocale: migrationLocale);
    final unlocked =
        storage.readJson(StorageService.achievementsKey) ?? const {};
    _unlockedIds.addAll(
      (unlocked['ids'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  final StorageService _storage;
  final Clock _clock;

  /// One [GameStats] per language code.
  final Map<String, GameStats> _byLocale = {};
  final Set<String> _unlockedIds = {};

  /// The language whose stats the bare [stats]/[displayStreak] convenience
  /// getters report. Production screens call the explicit `*For(locale)`
  /// variants; this default keeps callers (and tests) that don't care about
  /// language working against a single bucket.
  String _viewLocale;

  Set<String> get unlockedAchievementIds => Set.unmodifiable(_unlockedIds);

  /// Loads per-language stats, migrating a legacy single-blob save the first
  /// time it runs.
  void _load({
    Map<String, String>? quoteLocales,
    required String migrationLocale,
  }) {
    final v2 = _storage.readJson(StorageService.statsByLocaleKey);
    if (v2 != null) {
      final byLocale = (v2['byLocale'] as Map<String, dynamic>?) ?? const {};
      byLocale.forEach((code, json) {
        _byLocale[code] = GameStats.fromJson((json as Map).cast());
      });
      return;
    }

    // First launch on this build: fold a legacy stats.v1 blob (all languages
    // combined) into per-language buckets so nothing is lost.
    final v1 = _storage.readJson(StorageService.statsKey);
    if (v1 == null) return;
    final old = GameStats.fromJson(v1);

    // Solves split cleanly: quote ids are language-specific, so each one lands
    // in its real language's bucket (drives correct per-language pack
    // progress). totalSolved per bucket is then its solve count.
    for (final id in old.solvedIds) {
      final loc = quoteLocales?[id] ?? migrationLocale;
      _bucket(loc).solvedIds.add(id);
    }
    for (final g in _byLocale.values) {
      g.totalSolved = g.solvedIds.length;
    }

    // The remaining counters can't be attributed to a language after the fact
    // (the old blob never recorded one), so they carry over wholesale to the
    // migration locale. The cross-language [aggregate] that drives achievements
    // therefore stays identical, so nothing already unlocked regresses.
    final carry = _bucket(migrationLocale);
    carry.noHintSolves = old.noHintSolves;
    carry.bestTimeSeconds = old.bestTimeSeconds;
    carry.totalTimeSeconds = old.totalTimeSeconds;
    carry.hintsUsed = old.hintsUsed;
    carry.currentStreak = old.currentStreak;
    carry.bestStreak = old.bestStreak;
    carry.lastDailyDate = old.lastDailyDate;
    carry.dailyHistory.addAll(old.dailyHistory);

    _persist();
  }

  GameStats _bucket(String locale) =>
      _byLocale.putIfAbsent(locale, GameStats.new);

  /// Stats for [locale] (the Stats screen reads the active content language).
  GameStats statsFor(String locale) => _bucket(locale);

  /// The view-locale bucket. Defaults to the migration locale; production code
  /// prefers [statsFor].
  GameStats get stats => _bucket(_viewLocale);

  /// Points the bare convenience getters at [locale].
  void setViewLocale(String locale) {
    if (_viewLocale == locale) return;
    _viewLocale = locale;
    notifyListeners();
  }

  /// Lifetime totals across every language — the basis for global achievements
  /// and any all-languages summary.
  GameStats get aggregate {
    final agg = GameStats();
    for (final g in _byLocale.values) {
      agg.totalSolved += g.totalSolved;
      agg.noHintSolves += g.noHintSolves;
      agg.totalTimeSeconds += g.totalTimeSeconds;
      agg.hintsUsed += g.hintsUsed;
      if (g.bestTimeSeconds != null &&
          (agg.bestTimeSeconds == null ||
              g.bestTimeSeconds! < agg.bestTimeSeconds!)) {
        agg.bestTimeSeconds = g.bestTimeSeconds;
      }
      if (g.bestStreak > agg.bestStreak) agg.bestStreak = g.bestStreak;
      if (g.currentStreak > agg.currentStreak) {
        agg.currentStreak = g.currentStreak;
      }
      agg.solvedIds.addAll(g.solvedIds);
      agg.dailyHistory.addAll(g.dailyHistory);
    }
    return agg;
  }

  /// Quote ids are language-specific, so a global membership test is correct
  /// and lets callers stay language-agnostic for pack progress.
  bool isSolved(String quoteId) =>
      _byLocale.values.any((g) => g.solvedIds.contains(quoteId));

  /// Records a completed puzzle into [locale]'s profile and returns
  /// achievements newly unlocked by it (for celebration UI).
  Future<List<Achievement>> recordSolve({
    required String quoteId,
    required Duration solveTime,
    required int hintsUsed,
    required bool isDaily,
    String locale = 'en',
  }) async {
    final stats = _bucket(locale);
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

    if (isDaily) _recordDailySolve(stats);

    final newAchievements = _evaluateAchievements();
    await _persist();
    notifyListeners();
    return newAchievements;
  }

  void _recordDailySolve(GameStats stats) {
    // One clock read: deriving today and yesterday from the same instant keeps
    // them consistent even if the call straddles a midnight tick.
    final now = _clock.now();
    final today = dateKey(now);
    if (stats.dailyHistory[today] == true) return; // already counted

    stats.dailyHistory[today] = true;

    final yesterday = dateKey(now.subtract(const Duration(days: 1)));
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

  /// The streak shown in the UI for [locale]: drops to zero visually when
  /// yesterday was missed and today is not yet solved.
  int displayStreakFor(String locale) {
    final stats = _bucket(locale);
    final last = stats.lastDailyDate;
    if (last == null) return 0;
    final now = _clock.now();
    final today = dateKey(now);
    final yesterday = dateKey(now.subtract(const Duration(days: 1)));
    if (last == today || last == yesterday) return stats.currentStreak;
    return 0;
  }

  int get displayStreak => displayStreakFor(_viewLocale);

  bool dailySolvedTodayFor(String locale) =>
      _bucket(locale).dailyHistory[dateKey(_clock.now())] == true;

  bool get dailySolvedToday => dailySolvedTodayFor(_viewLocale);

  List<Achievement> _evaluateAchievements() {
    final agg = aggregate;
    final fresh = <Achievement>[];
    for (final a in Achievement.catalog) {
      if (!_unlockedIds.contains(a.id) && a.isUnlocked(agg)) {
        _unlockedIds.add(a.id);
        fresh.add(a);
      }
    }
    return fresh;
  }

  Future<void> _persist() async {
    await _storage.writeJson(StorageService.statsByLocaleKey, {
      'byLocale': {
        for (final entry in _byLocale.entries) entry.key: entry.value.toJson(),
      },
    });
    await _storage.writeJson(StorageService.achievementsKey, {
      'ids': _unlockedIds.toList(),
    });
  }
}
