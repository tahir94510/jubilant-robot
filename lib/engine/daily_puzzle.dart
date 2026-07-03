/// Deterministic daily puzzle selection.
///
/// Same local date => same quote and same cipher for every player on every
/// platform (shared-daily convention). Selection is stateless: a Sattolo shuffle
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

int puzzleNumberFor(DateTime date) {
  final epoch = AppConfig.puzzleEpoch;
  final d = DateTime(date.year, date.month, date.day);
  final n =
      d.difference(DateTime(epoch.year, epoch.month, epoch.day)).inDays + 1;
  // A device clock set before the epoch would yield a zero/negative number;
  // the shared "Quotecrack #N" label is 1-based, so floor it at 1.
  return n < 1 ? 1 : n;
}

int _dayOfYear(DateTime date) =>
    DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(date.year, 1, 1)).inDays +
    1;

/// Picks the daily quote from [pool] (sorted/stable). An English pool covers a
/// full leap year (>= 366) so a quote never repeats within a calendar year; a
/// smaller native-language pool cycles deterministically via the modulo below
/// — still the same quote for everyone on that language, every day.
DailyPuzzle selectDaily(List<Quote> pool, DateTime date) {
  assert(pool.isNotEmpty, 'daily pool must not be empty');
  final order = List<int>.generate(pool.length, (i) => i);
  final rng = DeterministicRng(fmix32(date.year));
  // Sattolo shuffle of the year's ordering.
  sattoloShuffle(order, rng);
  final quote = pool[order[(_dayOfYear(date) - 1) % pool.length]];
  return DailyPuzzle(
    quote: quote,
    number: puzzleNumberFor(date),
    date: DateTime(date.year, date.month, date.day),
  );
}
