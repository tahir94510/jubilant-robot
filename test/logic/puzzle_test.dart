import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/puzzle.dart';
import 'package:quotecrack/models/quote.dart';

/// Locks the "word done" counting semantics: a word is a whitespace-delimited
/// token, so hyphenated words and contractions count once — not as fragments.
void main() {
  PuzzleSession solved(String text) {
    final quote = Quote(
      id: 'wc-${text.hashCode}',
      text: text,
      author: 'Test',
      source: 'Test',
      category: 'wisdom',
    );
    final s = PuzzleSession(quote: quote);
    for (final c in s.cipherLetters) {
      s.guesses[c] = s.cipher.decryptLetter(c);
    }
    return s;
  }

  test('a hyphenated word counts as one word, not two', () {
    // Tokens: "Well-being", "is", "everything." -> 3 words. The hyphen must
    // NOT split "Well-being" into WELL + BEING (which would give 4).
    expect(solved('Well-being is everything.').correctWordCount, 3);
  });

  test('a contraction counts as one word', () {
    // Tokens: "It", "isn't", "over" -> 3 words. The apostrophe must not split
    // "isn't" into ISN + T.
    expect(solved("It isn't over").correctWordCount, 3);
  });
}
