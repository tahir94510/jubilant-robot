import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over SharedPreferences storing versioned JSON blobs.
///
/// Keys: settings.v1, stats.v1, economy.v1, achievements.v1,
/// `puzzle_state.<quoteId>`. Bump the suffix and migrate in [init] if a
/// breaking schema change ever ships.
class StorageService {
  StorageService._(this._prefs);

  static Future<StorageService> init() async =>
      StorageService._(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null; // corrupt blob: treat as missing rather than crash
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // --- well-known keys ---
  static const String settingsKey = 'settings.v1';
  static const String statsKey = 'stats.v1';
  static const String economyKey = 'economy.v1';
  static const String achievementsKey = 'achievements.v1';
  static String puzzleStateKey(String quoteId) => 'puzzle_state.$quoteId';
}
