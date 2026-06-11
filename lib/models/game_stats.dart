/// Lifetime player statistics (persisted as stats.v1).
class GameStats {
  GameStats({
    this.totalSolved = 0,
    this.noHintSolves = 0,
    this.bestTimeSeconds,
    this.totalTimeSeconds = 0,
    this.hintsUsed = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastDailyDate,
    Set<String>? solvedIds,
    Map<String, bool>? dailyHistory,
  }) : solvedIds = solvedIds ?? <String>{},
       dailyHistory = dailyHistory ?? <String, bool>{};

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    totalSolved: json['totalSolved'] as int? ?? 0,
    noHintSolves: json['noHintSolves'] as int? ?? 0,
    bestTimeSeconds: json['bestTimeSeconds'] as int?,
    totalTimeSeconds: json['totalTimeSeconds'] as int? ?? 0,
    hintsUsed: json['hintsUsed'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    bestStreak: json['bestStreak'] as int? ?? 0,
    lastDailyDate: json['lastDailyDate'] as String?,
    solvedIds: ((json['solvedIds'] as List<dynamic>?) ?? const [])
        .cast<String>()
        .toSet(),
    dailyHistory: ((json['dailyHistory'] as Map<String, dynamic>?) ?? const {})
        .map((k, v) => MapEntry(k, v as bool)),
  );

  int totalSolved;
  int noHintSolves;
  int? bestTimeSeconds;
  int totalTimeSeconds;
  int hintsUsed;

  /// Daily-puzzle streak.
  int currentStreak;
  int bestStreak;

  /// Last local date ('yyyy-MM-dd') a daily puzzle was solved.
  String? lastDailyDate;

  /// Every quote id ever solved (drives pack progress).
  final Set<String> solvedIds;

  /// 'yyyy-MM-dd' -> solved that day's daily (drives the heatmap).
  final Map<String, bool> dailyHistory;

  Map<String, dynamic> toJson() => {
    'totalSolved': totalSolved,
    'noHintSolves': noHintSolves,
    'bestTimeSeconds': bestTimeSeconds,
    'totalTimeSeconds': totalTimeSeconds,
    'hintsUsed': hintsUsed,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'lastDailyDate': lastDailyDate,
    'solvedIds': solvedIds.toList(),
    'dailyHistory': dailyHistory,
  };
}
