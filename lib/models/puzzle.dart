import '../engine/cipher.dart';
import 'quote.dart';

/// Live state of one cryptogram being solved.
///
/// The board shows [cipherText]; the player assigns a plain letter to each
/// distinct cipher letter. Identical cipher letters always share one guess,
/// so "auto-fill" is inherent to the data model.
class PuzzleSession {
  PuzzleSession({required this.quote, Map<String, String>? guesses})
    : cipher = CipherMap.forQuoteId(quote.id),
      guesses = Map.of(guesses ?? const {}) {
    cipherText = cipher.encrypt(quote.normalizedText);
  }

  final Quote quote;
  final CipherMap cipher;
  late final String cipherText;

  /// cipherLetter -> player's plain-letter guess.
  final Map<String, String> guesses;

  /// Cipher letters revealed via hints (locked, not editable).
  final Set<String> revealed = {};

  /// Distinct cipher letters present on the board.
  Set<String> get cipherLetters => lettersOnly(cipherText).split('').toSet();

  /// Plain letters already used as guesses (for keyboard dimming).
  Set<String> get usedPlainLetters => guesses.values.toSet();

  /// Cipher letters whose guess collides with another cipher letter's guess.
  Set<String> get conflicts {
    final byPlain = <String, List<String>>{};
    guesses.forEach((cipherL, plainL) {
      byPlain.putIfAbsent(plainL, () => []).add(cipherL);
    });
    final out = <String>{};
    for (final group in byPlain.values) {
      if (group.length > 1) out.addAll(group);
    }
    return out;
  }

  /// True when every cipher letter is guessed correctly.
  bool get isSolved {
    for (final c in cipherLetters) {
      if (guesses[c] != cipher.decryptLetter(c)) return false;
    }
    return true;
  }

  /// 0..1 share of cipher letters currently filled in.
  double get progress {
    final total = cipherLetters.length;
    if (total == 0) return 0;
    return guesses.length / total;
  }

  bool isGuessCorrect(String cipherLetter) =>
      guesses[cipherLetter] == cipher.decryptLetter(cipherLetter);

  /// Number of "meaningful" words (3+ letters) currently solved correctly —
  /// drives the small "word done" progress cue. Trivial 1-2 letter words
  /// (A, I, is, to, of...) are excluded so the cue rewards real progress
  /// instead of firing on a single keystroke.
  int get correctWordCount {
    var count = 0;
    for (final word in cipherText.split(' ')) {
      final letters = lettersOnly(word);
      if (letters.length < 3) continue;
      if (letters.split('').every(isGuessCorrect)) count++;
    }
    return count;
  }

  /// For persistence.
  Map<String, dynamic> toJson() => {
    'quoteId': quote.id,
    'guesses': guesses,
    'revealed': revealed.toList(),
  };
}
