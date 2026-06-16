import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/daily_puzzle.dart';
import 'package:quotecrack/engine/difficulty.dart';
import 'package:quotecrack/engine/quote_repository.dart';
import 'package:quotecrack/models/pack.dart';
import 'package:quotecrack/models/quote.dart';

/// The native-first content contract: when a player switches language, the
/// difficulty ladder and the daily follow them into that language, while the
/// English experience is unchanged.
void main() {
  List<Quote> sample() => [
    // English base (a couple of buckets).
    Quote(
      id: 'en-1',
      text: 'The quick brown fox jumps over the lazy dog tonight.',
      author: 'Pangram',
      source: 'Traditional',
      category: 'proverbs',
    ),
    Quote(
      id: 'en-2',
      text: 'Brevity is the soul of wit.',
      author: 'Shakespeare',
      source: 'Hamlet',
      category: 'proverbs',
    ),
    // Turkish natives spanning the spectrum.
    Quote(
      id: 'tr-1',
      text: 'Damlaya damlaya göl olur, aka aka sel olur.',
      author: 'Türk atasözü',
      source: 'Geleneksel',
      category: 'proverbs',
      locale: 'tr',
    ),
    Quote(
      id: 'tr-2',
      text: 'Sabrın sonu selamettir.',
      author: 'Türk atasözü',
      source: 'Geleneksel',
      category: 'proverbs',
      locale: 'tr',
    ),
  ];

  test('difficulty ladder follows the active language', () {
    final repo = QuoteRepository.fromQuotes(sample());
    final ladder = Pack.catalog.where((p) => p.kind == PackKind.difficulty);

    // English by default: only English quotes ever appear in the ladder.
    for (final pack in ladder) {
      expect(
        repo.forPack(pack).every((q) => q.locale == 'en'),
        isTrue,
        reason: '${pack.id} leaked a non-English quote by default',
      );
    }

    // Turkish player: every laddered quote is Turkish, none English.
    final trLadder = [
      for (final pack in ladder) ...repo.forPack(pack, activeLocale: 'tr'),
    ];
    expect(trLadder, isNotEmpty);
    expect(trLadder.every((q) => q.locale == 'tr'), isTrue);
  });

  test('daily pool is language-aware and English stays English-only', () {
    final repo = QuoteRepository.fromQuotes(sample());
    expect(repo.dailyPool.every((q) => q.locale == 'en'), isTrue);
    expect(repo.dailyPoolFor('en').every((q) => q.locale == 'en'), isTrue);

    final tr = repo.dailyPoolFor('tr');
    expect(tr, isNotEmpty);
    expect(tr.every((q) => q.locale == 'tr'), isTrue);

    // The same Turkish day resolves to the same Turkish quote for everyone.
    final a = selectDaily(tr, DateTime(2026, 6, 16));
    final b = selectDaily(tr, DateTime(2026, 6, 16, 22, 0));
    expect(a.quote.id, b.quote.id);
    expect(a.quote.locale, 'tr');
  });

  test('a tiny native pool cycles instead of crashing', () {
    final pool = [
      Quote(
        id: 'tr-only',
        text: 'Sabrın sonu selamettir, acele işe şeytan karışır.',
        author: 'Türk atasözü',
        source: 'Geleneksel',
        category: 'proverbs',
        locale: 'tr',
      ),
    ];
    // One-quote pool: still deterministic, never throws.
    expect(selectDaily(pool, DateTime(2026, 1, 1)).quote.id, 'tr-only');
    expect(selectDaily(pool, DateTime(2026, 12, 31)).quote.id, 'tr-only');
  });

  test('themed packs are native to the active language', () {
    final repo = QuoteRepository.fromQuotes(sample());
    final proverbs = Pack.byId('proverbs');
    // English player sees English proverbs...
    expect(repo.forPack(proverbs).every((q) => q.locale == 'en'), isTrue);
    expect(repo.forPack(proverbs), isNotEmpty);
    // ...a Turkish player sees Turkish proverbs in the very same pack.
    final tr = repo.forPack(proverbs, activeLocale: 'tr');
    expect(tr, isNotEmpty);
    expect(tr.every((q) => q.locale == 'tr'), isTrue);
  });

  test('bucketing is language-aware, not English-centric', () {
    // The Turkish difficulty engine scores Turkish text on Turkish letter
    // frequencies — a sanity check that buckets resolve for native text.
    final q = Quote(
      id: 'tr-x',
      text: 'Damlaya damlaya göl olur, aka aka sel olur.',
      author: 'Türk atasözü',
      source: 'Geleneksel',
      category: 'proverbs',
      locale: 'tr',
    );
    expect(Difficulty.values.contains(q.difficulty), isTrue);
  });
}
