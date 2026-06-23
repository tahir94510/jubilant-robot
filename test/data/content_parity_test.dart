import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/quote.dart';

/// Locks cross-language content parity and structure so a future edit can't
/// silently let one language fall behind. This is the regression net for the
/// gaps fixed in v2.4: French/Italian shipped fewer quotes than the rest, and
/// Italian was missing `classics2.json` entirely (a thin premium pack), even
/// though the dataset still cleared the older "≥510 + non-empty packs" bar.
void main() {
  const localized = ['tr', 'es', 'de', 'fr', 'it', 'pt'];
  const allLocales = ['en', ...localized];

  /// Every language must ship at least this many quotes (top-line parity).
  /// Languages may exceed it; they may never drop below.
  const minPerLocale = 550;

  /// Per-language floors for the slimmer packs, so no culture gets an anemic
  /// premium Classics, themed Literature or Heart & Courage pack.
  const categoryFloors = {'classics': 30, 'literature': 35, 'inspire': 30};

  late final Map<String, List<Quote>> byLocale;

  setUpAll(() {
    final dir = Directory('assets/data/quotes');
    byLocale = {};
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.json')) continue;
      for (final e in jsonDecode(file.readAsStringSync()) as List<dynamic>) {
        final q = Quote.fromJson(e as Map<String, dynamic>);
        byLocale.putIfAbsent(q.locale, () => []).add(q);
      }
    }
  });

  test('every language ships at least $minPerLocale quotes', () {
    for (final loc in allLocales) {
      final n = byLocale[loc]?.length ?? 0;
      expect(
        n,
        greaterThanOrEqualTo(minPerLocale),
        reason: '$loc has $n quotes',
      );
    }
  });

  test('localized packs share an identical file structure', () {
    Set<String> filesIn(String loc) => Directory('assets/data/quotes/$loc')
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((n) => n.endsWith('.json'))
        .toSet();

    final reference = filesIn('tr');
    expect(reference, isNotEmpty);
    for (final loc in localized) {
      expect(
        filesIn(loc),
        reference,
        reason:
            '$loc has a different set of pack files than tr '
            '(a missing/extra file means uneven content across languages)',
      );
    }
  });

  test('themed and premium packs stay stocked in every language', () {
    int count(String loc, String category) =>
        byLocale[loc]?.where((q) => q.category == category).length ?? 0;
    for (final loc in allLocales) {
      categoryFloors.forEach((category, floor) {
        final n = count(loc, category);
        expect(n, greaterThanOrEqualTo(floor), reason: '$loc has $n $category');
      });
    }
  });
}
