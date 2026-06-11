/// Difficulty scoring for cryptogram puzzles.
///
/// A cryptogram gets harder when the solver has less statistical material:
/// short texts, many letters that appear only once, many distinct letters,
/// rare letters (J/Q/X/Z mislead frequency analysis), and few short
/// "foothold" words (A, I, THE, AND...).
library;

import '../config/app_config.dart';
import 'cipher.dart';

enum Difficulty { beginner, casual, skilled, expert }

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.casual => 'Casual',
    Difficulty.skilled => 'Skilled',
    Difficulty.expert => 'Expert',
  };
}

/// Relative English letter frequencies (per 1000 letters, standard table).
const Map<String, double> _englishFreq = {
  'E': 127, 'T': 91, 'A': 82, 'O': 75, 'I': 70, 'N': 67, 'S': 63, 'H': 61,
  'R': 60, 'D': 43, 'L': 40, 'C': 28, 'U': 28, 'M': 24, 'W': 24, 'F': 22,
  'G': 20, 'Y': 20, 'P': 19, 'B': 15, 'V': 10, 'K': 8, 'J': 2, 'X': 2,
  'Q': 1, 'Z': 1, //
};

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Score in [0, 100]; higher = harder.
double difficultyScore(String rawText) {
  final normalized = normalizeQuoteText(rawText);
  final letters = lettersOnly(normalized);
  if (letters.isEmpty) return 0;

  final counts = <String, int>{};
  for (final ch in letters.split('')) {
    counts[ch] = (counts[ch] ?? 0) + 1;
  }

  final length = letters.length;
  final unique = counts.length;
  final singles = counts.values.where((c) => c == 1).length;

  final maxFreq = _englishFreq['E']!;
  var raritySum = 0.0;
  counts.forEach((ch, count) {
    raritySum += (1 - _englishFreq[ch]! / maxFreq) * count;
  });
  final rarity = raritySum / length;

  final words = normalized
      .split(RegExp('[^A-Z]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  final shortWords = words.where((w) => w.length <= 3).length;

  final score =
      38 * _clamp01((120 - length) / 90) +
      24 * (singles / unique) +
      20 * _clamp01((unique - 8) / 14) +
      12 * rarity +
      6 * _clamp01(1 - shortWords / 5);
  return score;
}

Difficulty difficultyBucket(double score) {
  if (score < AppConfig.beginnerMax) return Difficulty.beginner;
  if (score < AppConfig.casualMax) return Difficulty.casual;
  if (score < AppConfig.skilledMax) return Difficulty.skilled;
  return Difficulty.expert;
}
