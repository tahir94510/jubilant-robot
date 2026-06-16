import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/difficulty.dart';
import 'package:quotecrack/engine/quote_repository.dart';
import 'package:quotecrack/models/pack.dart';
import 'package:quotecrack/models/puzzle.dart';
import 'package:quotecrack/models/quote.dart';

/// Content QA as a test: the dataset itself must satisfy the product
/// contract (size, uniqueness, normalization, pack coverage) — for the
/// English base AND every localized pack.
void main() {
  late final List<Quote> quotes; // all locales
  late final List<Quote> en; // English base

  setUpAll(() {
    final dir = Directory('assets/data/quotes');
    quotes = [
      // recursive: English at the root, localized packs in locale subfolders.
      for (final file in dir.listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.json'))
          ...(jsonDecode(file.readAsStringSync()) as List<dynamic>).map(
            (e) => Quote.fromJson(e as Map<String, dynamic>),
          ),
    ];
    en = quotes.where((q) => q.locale == 'en').toList();
  });

  test('English base covers a full year of dailies', () {
    expect(en.length, greaterThanOrEqualTo(450));
    final dailyEligible = en
        .where((q) => !QuoteRepository.premiumCategories.contains(q.category))
        .length;
    expect(
      dailyEligible,
      greaterThanOrEqualTo(366),
      reason: 'daily pool must cover a leap year',
    );
  });

  test('ids are unique across every locale', () {
    final ids = quotes.map((q) => q.id).toSet();
    expect(ids.length, quotes.length);
  });

  test('no duplicate texts within a locale (after normalization)', () {
    final seen = <String>{};
    for (final q in quotes) {
      final key = '${q.locale}:${q.alphabet.lettersOnly(q.normalizedText)}';
      expect(seen.add(key), isTrue, reason: 'duplicate text: ${q.id}');
    }
  });

  test('English texts are ASCII', () {
    for (final q in en) {
      expect(
        q.text.runes.every((r) => r < 128),
        isTrue,
        reason: '${q.id} contains non-ASCII characters',
      );
    }
  });

  test('every quote is within playable length bounds for its alphabet', () {
    for (final q in quotes) {
      final letters = q.alphabet.lettersOnly(q.normalizedText).length;
      expect(
        letters,
        inInclusiveRange(20, 180),
        reason: '${q.id} (${q.locale}) has $letters letters',
      );
    }
  });

  test('localized quotes use only their own alphabet letters', () {
    // Catches stray characters a translator might slip in — e.g. Turkish
    // circumflex â/î/û, which are NOT in the 29-letter alphabet and would
    // render as dead cells on the board.
    for (final q in quotes.where((q) => q.locale != 'en')) {
      for (final ch in q.normalizedText.split('')) {
        final isLetter = q.alphabet.isLetter(ch);
        // Allow spaces and simple punctuation; flag stray letter-like glyphs.
        final isAllowedNonLetter = RegExp(
          r'''[ \-'".,;:!?()…’“”—]''',
        ).hasMatch(ch);
        expect(
          isLetter || isAllowedNonLetter,
          isTrue,
          reason: '${q.id}: stray character "$ch" not in ${q.locale} alphabet',
        );
      }
    }
  });

  test('every quote is solvable by entering the correct letters', () {
    for (final q in quotes) {
      final s = PuzzleSession(quote: q);
      for (final c in s.cipherLetters) {
        s.guesses[c] = s.cipher.decryptLetter(c);
      }
      expect(s.isSolved, isTrue, reason: '${q.id} (${q.locale}) not solvable');
    }
  });

  test('attribution fields are filled in', () {
    for (final q in quotes) {
      expect(q.author.trim(), isNotEmpty, reason: q.id);
      expect(q.source.trim(), isNotEmpty, reason: q.id);
      expect(q.category.trim(), isNotEmpty, reason: q.id);
      expect(
        q.author.trim().toLowerCase(),
        isNot('unknown'),
        reason: '${q.id}: use a real attribution instead of "Unknown"',
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

  test('every language fills the whole pack structure', () {
    final repo = QuoteRepository.fromQuotes(quotes);
    const locales = ['en', 'tr', 'es', 'de', 'fr', 'it', 'pt'];
    for (final loc in locales) {
      // Difficulty ladder collectively has content.
      final ladder = Pack.catalog
          .where((p) => p.kind == PackKind.difficulty)
          .expand((p) => repo.forPack(p, activeLocale: loc))
          .length;
      expect(ladder, greaterThan(0), reason: '$loc difficulty ladder is empty');
      // Each themed pack is non-empty, and the premium Classics pack is stocked.
      for (final pack in Pack.catalog.where(
        (p) => p.kind != PackKind.difficulty,
      )) {
        final size = repo.forPack(pack, activeLocale: loc).length;
        expect(size, greaterThan(0), reason: '$loc pack ${pack.id} is empty');
        if (pack.premiumOnly) {
          expect(
            size,
            greaterThanOrEqualTo(15),
            reason: '$loc Classics pack too small ($size)',
          );
        }
      }
    }
  });

  test('the daily pool stays English-only', () {
    final repo = QuoteRepository.fromQuotes(quotes);
    expect(repo.dailyPool.every((q) => q.locale == 'en'), isTrue);
    expect(repo.dailyPool.length, greaterThanOrEqualTo(366));
  });

  test('every English difficulty bucket is well stocked', () {
    final byBucket = <Difficulty, int>{};
    for (final q in en) {
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
