/// Deterministic daily puzzle selection.
///
/// Same local date => same quote and same cipher for every player on every
/// platform (Wordle convention). Selection is stateless: a Sattolo shuffle
/// of the eligible pool is seeded by the year, and the day-of-year indexes
/// into it, so a quote can never repeat within a calendar year (pool size
/// >= 366 is enforced by tests).
library;

import '../config/app_config.dart';
import '../models/quote.dart';
import 'deterministic_rng.dart';

class DailyPuzzle {
  const DailyPuzzle({
    required this.quote,
    required this.number,
    required this.date,
  });

  final Quote quote;

  /// "Quotecrack #N" — days since the epoch date, 1-based.
  final int number;
  final DateTime date;
}

/// Seed that uniquely identifies a calendar date.
int dailySeed(DateTime date) =>
    fmix32(date.year * 10000 + date.month * 100 + date.day);

int puzzleNumberFor(DateTime date) {
  final epoch = AppConfig.puzzleEpoch;
  final d = DateTime(date.year, date.month, date.day);
  return d.difference(DateTime(epoch.year, epoch.month, epoch.day)).inDays + 1;
}

int _dayOfYear(DateTime date) =>
    DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(date.year, 1, 1)).inDays +
    1;

/// Picks the daily quote from [pool] (must be sorted/stable and >= 366 long).
DailyPuzzle selectDaily(List<Quote> pool, DateTime date) {
  assert(pool.length >= 366, 'daily pool must cover a leap year');
  final order = List<int>.generate(pool.length, (i) => i);
  final rng = DeterministicRng(fmix32(date.year));
  // Sattolo shuffle of the year's ordering.
  for (var i = order.length - 1; i > 0; i--) {
    final j = rng.nextInt(i);
    final t = order[i];
    order[i] = order[j];
    order[j] = t;
  }
  final quote = pool[order[_dayOfYear(date) - 1]];
  return DailyPuzzle(
    quote: quote,
    number: puzzleNumberFor(date),
    date: DateTime(date.year, date.month, date.day),
  );
}
