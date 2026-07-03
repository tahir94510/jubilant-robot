import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/daily_puzzle.dart';
import 'package:quotecrack/models/quote.dart';

List<Quote> _pool(int n) => List.generate(
  n,
  (i) => Quote(
    id: 'q-${i.toString().padLeft(3, '0')}',
    text: 'Sample quote number $i with enough letters to play',
    author: 'Author $i',
    source: 'Source',
    category: 'wisdom',
  ),
);

void main() {
  final pool = _pool(400);

  group('selectDaily', () {
    test('same date gives the same quote', () {
      final a = selectDaily(pool, DateTime(2026, 6, 11));
      final b = selectDaily(pool, DateTime(2026, 6, 11, 23, 59));
      expect(a.quote.id, b.quote.id);
      expect(a.number, b.number);
    });

    test('golden vector: exact daily picks are locked forever', () {
      // Captured from the shipped implementation. A different pick here means
      // every player's "same quote for everyone today" contract just broke —
      // fix the code, NEVER these expectations.
      expect(selectDaily(pool, DateTime(2026, 6, 11)).quote.id, 'q-266');
      expect(selectDaily(pool, DateTime(2027, 1, 1)).quote.id, 'q-214');
      expect(selectDaily(pool, DateTime(2028, 2, 29)).quote.id, 'q-369');
    });

    test('every day of 2026 picks a distinct quote', () {
      final seen = <String>{};
      for (
        var d = DateTime(2026, 1, 1);
        d.year == 2026;
        d = d.add(const Duration(days: 1))
      ) {
        final picked = selectDaily(pool, d).quote.id;
        expect(seen.add(picked), isTrue, reason: '$d repeated quote $picked');
      }
      expect(seen.length, 365);
    });

    test('leap year 2028 also has no repeats', () {
      final seen = <String>{};
      for (
        var d = DateTime(2028, 1, 1);
        d.year == 2028;
        d = d.add(const Duration(days: 1))
      ) {
        expect(seen.add(selectDaily(pool, d).quote.id), isTrue);
      }
      expect(seen.length, 366);
    });

    test('year rollover reshuffles the order', () {
      final dec31 = selectDaily(pool, DateTime(2026, 12, 31));
      final jan1 = selectDaily(pool, DateTime(2027, 1, 1));
      // Different year permutations: equality would be a 1/400 fluke, and
      // determinism makes this assertion stable forever.
      expect(jan1.quote.id, isNot(dec31.quote.id));
    });

    test('puzzle numbers are sequential from the epoch', () {
      expect(puzzleNumberFor(DateTime(2026, 1, 1)), 1);
      expect(puzzleNumberFor(DateTime(2026, 1, 31)), 31);
      expect(puzzleNumberFor(DateTime(2026, 12, 31)), 365);
      expect(
        puzzleNumberFor(DateTime(2026, 6, 12)) -
            puzzleNumberFor(DateTime(2026, 6, 11)),
        1,
      );
    });
  });
}
