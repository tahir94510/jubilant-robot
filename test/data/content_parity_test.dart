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

  test('Quote round-trips the optional "About this quote" note', () {
    final withNote = Quote.fromJson(const {
      'id': 't1',
      'text': 'a test quote',
      'author': 'A',
      'source': 'S',
      'category': 'classics',
      'note': 'context here',
    });
    expect(withNote.note, 'context here');

    final without = Quote.fromJson(const {
      'id': 't2',
      'text': 'a test quote',
      'author': 'A',
      'source': 'S',
      'category': 'classics',
    });
    expect(without.note, isNull);
  });

  test('every About note is non-empty, and English seeds the feature', () {
    for (final q in byLocale.values.expand((e) => e)) {
      if (q.note != null) {
        expect(q.note!.trim(), isNotEmpty, reason: '${q.id} has a blank note');
      }
    }
    final enNotes = byLocale['en']!.where((q) => q.note != null).length;
    expect(
      enNotes,
      greaterThanOrEqualTo(18),
      reason: 'English should seed at least 18 "About this quote" notes',
    );
  });

  test('the dataset stays 100% public domain (no in-copyright authors)', () {
    // Authors whose work is not yet public domain under life+70 (death after
    // 1955). Removing them is a deliberate, locked decision (v2.4 copyright
    // cleanup); extend this set if a new in-copyright name ever slips in.
    const blocked = {
      'Eugenio Montale',
      'Giuseppe Ungaretti',
      'Salvatore Quasimodo',
      'Umberto Saba',
      'Aldo Palazzeschi',
      'Ennio Flaiano',
      'Leo Longanesi',
      'Norberto Bobbio',
      'Danilo Dolci',
      'Helen Keller',
      'Will Durant',
      'Robert Frost',
      'Albert Camus',
      'Jean-Paul Sartre',
      'Simone de Beauvoir',
      'Sacha Guitry',
      'Bertolt Brecht',
      'Hannah Arendt',
      'Pablo Neruda',
      'Gabriela Mistral',
      'María Zambrano',
      'Gregorio Marañón',
      'José Luis Sampedro',
      'Carlos Drummond de Andrade',
      'Cecília Meireles',
      'Clarice Lispector',
      'Millôr Fernandes',
      'Mário Quintana',
      'Agostinho da Silva',
      'Paulo Freire',
      'Vinicius de Moraes',
      'Sophia de Mello Breyner Andresen',
      'Caetano Veloso',
      'Raul Seixas',
      'Charlie Chaplin',
      'Bertrand Russell',
    };
    for (final q in byLocale.values.expand((e) => e)) {
      expect(
        blocked.contains(q.author),
        isFalse,
        reason: '${q.id} cites ${q.author}, who is not yet public domain',
      );
    }
  });
}
