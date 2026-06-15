/// Difficulty scoring for cryptogram puzzles.
///
/// A cryptogram gets harder when the solver has less statistical material:
/// short texts, many letters that appear only once, many distinct letters,
/// rare letters (J/Q/X/Z mislead frequency analysis), and few short
/// "foothold" words (A, I, THE, AND...).
library;

import '../config/app_config.dart';
import 'alphabet.dart';

enum Difficulty { beginner, casual, skilled, expert }

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.casual => 'Casual',
    Difficulty.skilled => 'Skilled',
    Difficulty.expert => 'Expert',
  };
}

/// Relative letter frequencies per language (percent of letters). The rarity
/// term only needs the SHAPE of each table (which letters are common vs rare
/// in THAT language), so approximate published values are fine. Folded
/// alphabets (de/fr/it/pt) fold accents to base letters, so these tables are
/// keyed by base letters; Spanish keeps Ñ and Turkish its full 29 letters.
const Map<String, Map<String, double>> _freqByLocale = {
  'en': {
    'E': 12.7,
    'T': 9.1,
    'A': 8.2,
    'O': 7.5,
    'I': 7.0,
    'N': 6.7,
    'S': 6.3,
    'H': 6.1,
    'R': 6.0,
    'D': 4.3,
    'L': 4.0,
    'C': 2.8,
    'U': 2.8,
    'M': 2.4,
    'W': 2.4,
    'F': 2.2,
    'G': 2.0,
    'Y': 2.0,
    'P': 1.9,
    'B': 1.5,
    'V': 1.0,
    'K': 0.8,
    'J': 0.15,
    'X': 0.15,
    'Q': 0.1,
    'Z': 0.07,
  },
  'tr': {
    'A': 11.9,
    'E': 8.9,
    'İ': 8.6,
    'N': 7.5,
    'R': 6.9,
    'L': 5.9,
    'I': 5.1,
    'K': 4.7,
    'D': 4.7,
    'M': 3.7,
    'Y': 3.4,
    'U': 3.2,
    'T': 3.3,
    'S': 3.0,
    'B': 2.8,
    'O': 2.5,
    'Ü': 1.9,
    'Ş': 1.8,
    'Z': 1.5,
    'G': 1.3,
    'Ç': 1.2,
    'H': 1.2,
    'Ğ': 1.1,
    'V': 1.0,
    'C': 1.0,
    'Ö': 0.9,
    'P': 0.9,
    'F': 0.4,
    'J': 0.04,
  },
  'es': {
    'E': 13.7,
    'A': 11.5,
    'O': 8.7,
    'S': 8.0,
    'R': 6.9,
    'N': 6.7,
    'I': 6.2,
    'D': 5.0,
    'L': 5.0,
    'C': 4.7,
    'T': 4.6,
    'U': 3.9,
    'M': 3.2,
    'P': 2.5,
    'B': 1.4,
    'G': 1.0,
    'V': 0.9,
    'Y': 0.9,
    'Q': 0.9,
    'H': 0.7,
    'F': 0.7,
    'Z': 0.5,
    'J': 0.4,
    'Ñ': 0.3,
    'X': 0.2,
    'K': 0.05,
    'W': 0.02,
  },
  'de': {
    'E': 16.4,
    'N': 9.8,
    'S': 7.3,
    'R': 7.0,
    'I': 6.6,
    'A': 6.5,
    'T': 6.2,
    'D': 5.1,
    'H': 4.6,
    'U': 4.2,
    'L': 3.4,
    'G': 3.0,
    'O': 2.6,
    'C': 2.7,
    'M': 2.5,
    'B': 1.9,
    'W': 1.9,
    'F': 1.7,
    'K': 1.2,
    'Z': 1.1,
    'V': 0.8,
    'P': 0.7,
    'J': 0.3,
    'Y': 0.04,
    'X': 0.03,
    'Q': 0.02,
  },
  'fr': {
    'E': 14.7,
    'S': 7.9,
    'A': 7.6,
    'I': 7.5,
    'T': 7.2,
    'N': 7.1,
    'R': 6.6,
    'U': 6.3,
    'L': 5.5,
    'O': 5.8,
    'D': 3.7,
    'C': 3.3,
    'P': 3.0,
    'M': 3.0,
    'V': 1.6,
    'Q': 1.4,
    'F': 1.1,
    'B': 0.9,
    'G': 0.9,
    'H': 0.7,
    'J': 0.5,
    'X': 0.4,
    'Y': 0.3,
    'Z': 0.1,
    'K': 0.05,
    'W': 0.04,
  },
  'it': {
    'E': 11.8,
    'A': 11.7,
    'I': 11.3,
    'O': 9.8,
    'N': 6.9,
    'L': 6.5,
    'R': 6.4,
    'T': 5.6,
    'S': 5.0,
    'C': 4.5,
    'D': 3.7,
    'P': 3.1,
    'U': 3.0,
    'M': 2.5,
    'V': 2.1,
    'G': 1.6,
    'H': 1.5,
    'F': 1.0,
    'B': 0.9,
    'Z': 0.5,
    'Q': 0.5,
  },
  'pt': {
    'A': 14.6,
    'E': 12.6,
    'O': 10.7,
    'S': 7.8,
    'R': 6.5,
    'I': 6.2,
    'N': 5.0,
    'D': 5.0,
    'M': 4.7,
    'U': 4.6,
    'T': 4.3,
    'C': 3.9,
    'L': 2.8,
    'P': 2.5,
    'V': 1.7,
    'G': 1.3,
    'H': 1.3,
    'Q': 1.2,
    'B': 1.0,
    'F': 1.0,
    'Z': 0.4,
    'J': 0.4,
    'X': 0.25,
  },
};

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

/// Score in [0, 100]; higher = harder. Rarity is judged with [alphabet]'s own
/// language's letter-frequency table (English by default), so a Turkish or
/// Spanish puzzle is scored by what is actually rare in THAT language — not by
/// English frequencies.
double difficultyScore(String rawText, {Alphabet? alphabet}) {
  final a = alphabet ?? Alphabets.en;
  final normalized = a.normalize(rawText);
  final letters = a.lettersOnly(normalized);
  if (letters.isEmpty) return 0;

  final counts = <String, int>{};
  for (final ch in letters.split('')) {
    counts[ch] = (counts[ch] ?? 0) + 1;
  }

  final length = letters.length;
  final unique = counts.length;
  final singles = counts.values.where((c) => c == 1).length;

  final freq = _freqByLocale[a.code] ?? _freqByLocale['en']!;
  final maxFreq = freq.values.reduce((m, v) => v > m ? v : m);
  // Unknown letters count as the rarest known letter, not zero.
  final minFreq = freq.values.reduce((m, v) => v < m ? v : m);
  var raritySum = 0.0;
  counts.forEach((ch, count) {
    raritySum += (1 - (freq[ch] ?? minFreq) / maxFreq) * count;
  });
  final rarity = raritySum / length;

  final words = a.words(normalized);
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
