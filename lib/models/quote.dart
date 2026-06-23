import '../engine/alphabet.dart';
import '../engine/difficulty.dart';

/// One quote from assets/data/quotes/**/*.json with derived puzzle fields.
class Quote {
  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.source,
    required this.category,
    this.locale = 'en',
    this.note,
  }) : alphabet = Alphabets.forLocale(locale) {
    normalizedText = alphabet.normalize(text);
    score = difficultyScore(text, alphabet: alphabet);
    difficulty = difficultyBucket(score);
  }

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    id: json['id'] as String,
    text: json['text'] as String,
    author: json['author'] as String,
    source: json['source'] as String,
    category: json['category'] as String,
    locale: json['locale'] as String? ?? 'en',
    note: json['note'] as String?,
  );

  final String id;
  final String text;
  final String author;
  final String source;
  final String category;

  /// BCP-47-ish language code; selects the playable [alphabet].
  final String locale;

  /// Optional one- or two-sentence context shown after a solve ("About this
  /// quote") — who said it, from where, why it matters. Null for the vast
  /// majority; the complete screen renders the section only when present, so
  /// the dataset can be enriched gradually without any code change.
  final String? note;

  /// The alphabet this quote's cryptogram plays on.
  final Alphabet alphabet;

  /// Uppercased, locale-folded text shown on the board.
  late final String normalizedText;
  late final double score;
  late final Difficulty difficulty;

  /// Distinct letters (in this quote's alphabet) used by the quote.
  Set<String> get usedLetters =>
      alphabet.lettersOnly(normalizedText).split('').toSet();

  /// Total playable letters (drives the "Short & Sweet" length filter).
  int get letterCount => alphabet.lettersOnly(normalizedText).length;
}
