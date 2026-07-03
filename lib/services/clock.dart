/// Time source abstraction so streak/day-boundary logic is testable.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

/// Formats a local date as the canonical 'yyyy-MM-dd' storage key.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The storage key for the calendar day before [d]'s calendar day.
///
/// Deliberately NOT `d.subtract(Duration(days: 1))`: Duration math works on
/// the absolute instant, so on the day after a DST spring-forward (a 23-hour
/// day) a post-midnight `now` lands TWO calendar days back — which would
/// wrongly reset a daily streak. Constructing `DateTime(y, m, day - 1)` is
/// pure calendar arithmetic (Dart normalizes day 0 into the previous
/// month/year) and is immune to timezone transitions.
String yesterdayKey(DateTime d) =>
    dateKey(DateTime(d.year, d.month, d.day - 1));
