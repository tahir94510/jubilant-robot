import '../engine/cipher.dart';
import '../engine/difficulty.dart';

/// One quote from assets/data/quotes/*.json with derived puzzle fields.
class Quote {
  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.source,
    required this.category,
  })  : normalizedText = normalizeQuoteText(text),
        score = difficultyScore(text) {
    difficulty = difficultyBucket(score);
  }

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        id: json['id'] as String,
        text: json['text'] as String,
        author: json['author'] as String,
        source: json['source'] as String,
        category: json['category'] as String,
      );

  final String id;
  final String text;
  final String author;
  final String source;
  final String category;

  /// Uppercased, ASCII-folded text shown on the board.
  final String normalizedText;
  final double score;
  late final Difficulty difficulty;

  /// Distinct A-Z letters used by this quote.
  Set<String> get usedLetters => lettersOnly(normalizedText).split('').toSet();
}
