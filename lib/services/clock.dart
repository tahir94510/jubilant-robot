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
