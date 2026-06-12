import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/cipher.dart';
import 'package:quotecrack/engine/difficulty.dart';
import 'package:quotecrack/engine/quote_repository.dart';
import 'package:quotecrack/models/pack.dart';
import 'package:quotecrack/models/quote.dart';

/// Content QA as a test: the dataset itself must satisfy the product
/// contract (size, uniqueness, normalization, pack coverage).
void main() {
  late final List<Quote> quotes;

  setUpAll(() {
    final dir = Directory('assets/data/quotes');
    quotes = [
      for (final file in dir.listSync().whereType<File>())
        if (file.path.endsWith('.json'))
          ...(jsonDecode(file.readAsStringSync()) as List<dynamic>).map(
            (e) => Quote.fromJson(e as Map<String, dynamic>),
          ),
    ];
  });

  test('dataset is large enough for a full year of dailies', () {
    expect(quotes.length, greaterThanOrEqualTo(450));
    final dailyEligible = quotes
        .where((q) => !QuoteRepository.premiumCategories.contains(q.category))
        .length;
    expect(
      dailyEligible,
      greaterThanOrEqualTo(366),
      reason: 'daily pool must cover a leap year',
    );
  });

  test('ids are unique', () {
    final ids = quotes.map((q) => q.id).toSet();
    expect(ids.length, quotes.length);
  });

  test('no duplicate texts after normalization', () {
    final seen = <String>{};
    for (final q in quotes) {
      final key = lettersOnly(q.normalizedText);
      expect(seen.add(key), isTrue, reason: 'duplicate text: ${q.id}');
    }
  });

  test('texts are ASCII and within playable length bounds', () {
    for (final q in quotes) {
      expect(
        q.text.runes.every((r) => r < 128),
        isTrue,
        reason: '${q.id} contains non-ASCII characters',
      );
      final letters = lettersOnly(q.normalizedText).length;
      expect(
        letters,
        inInclusiveRange(20, 180),
        reason: '${q.id} has $letters letters',
      );
    }
  });

  test('attribution fields are filled in', () {
    for (final q in quotes) {
      expect(q.author.trim(), isNotEmpty, reason: q.id);
      expect(q.source.trim(), isNotEmpty, reason: q.id);
      expect(q.category.trim(), isNotEmpty, reason: q.id);
      // "— Unknown" reads cheap on the board and the solve screen; folk
      // material is credited "Anonymous" (or "Proverb") instead.
      expect(
        q.author.trim().toLowerCase(),
        isNot('unknown'),
        reason: '${q.id}: use "Anonymous" instead of "Unknown"',
      );
    }
  });

  test('every pack in the catalog is playable', () {
    final repo = QuoteRepository.fromQuotes(quotes);
    for (final pack in Pack.catalog) {
      final size = repo.forPack(pack).length;
      expect(size, greaterThan(0), reason: 'pack ${pack.id} is empty');
      if (pack.premiumOnly) {
        expect(
          size,
          greaterThanOrEqualTo(20),
          reason: 'premium pack ${pack.id} too small',
        );
      }
    }
  });

  test('every difficulty bucket is well stocked', () {
    final byBucket = <Difficulty, int>{};
    for (final q in quotes) {
      if (QuoteRepository.premiumCategories.contains(q.category)) continue;
      byBucket[q.difficulty] = (byBucket[q.difficulty] ?? 0) + 1;
    }
    for (final bucket in Difficulty.values) {
      expect(
        byBucket[bucket] ?? 0,
        greaterThanOrEqualTo(40),
        reason: 'bucket $bucket has ${byBucket[bucket] ?? 0} quotes',
      );
    }
  });
}
