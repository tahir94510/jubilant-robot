import '../engine/alphabet.dart';
import '../engine/cipher.dart';
import 'quote.dart';

/// Live state of one cryptogram being solved.
///
/// The board shows [cipherText]; the player assigns a plain letter to each
/// distinct cipher letter. Identical cipher letters always share one guess,
/// so "auto-fill" is inherent to the data model.
class PuzzleSession {
  PuzzleSession({required this.quote, Map<String, String>? guesses})
    : alphabet = quote.alphabet,
      cipher = CipherMap.forQuoteId(quote.id, alphabet: quote.alphabet.letters),
      guesses = Map.of(guesses ?? const {}) {
    cipherText = cipher.encrypt(quote.normalizedText);
  }

  final Quote quote;

  /// The alphabet this puzzle plays on (drives the board and keyboard).
  final Alphabet alphabet;
  final CipherMap cipher;
  late final String cipherText;

  /// cipherLetter -> player's plain-letter guess.
  final Map<String, String> guesses;

  /// Cipher letters revealed via hints (locked, not editable).
  final Set<String> revealed = {};

  /// Distinct cipher letters present on the board.
  Set<String> get cipherLetters =>
      alphabet.lettersOnly(cipherText).split('').toSet();

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

  /// Number of real words (2+ letters) currently solved correctly — drives
  /// the small "word done" progress cue. Single-letter words (A, I) are a
  /// single keystroke, so they stay a plain tap; everything from two-letter
  /// words up earns the brighter chime.
  ///
  /// A "word" is a whitespace-delimited token (so a hyphenated word like
  /// "well-done" or a contraction like "isn't" counts once, not as its
  /// fragments). Letters are pulled per token with the quote's alphabet so it
  /// stays correct in every language — NOT alphabet.words(), which would split
  /// on the hyphen/apostrophe too.
  int get correctWordCount {
    var count = 0;
    for (final word in cipherText.split(' ')) {
      final letters = alphabet.lettersOnly(word);
      if (letters.length < 2) continue;
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
