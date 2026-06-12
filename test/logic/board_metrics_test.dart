import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/ui/widgets/board_metrics.dart';

/// Locks the board-fitting math that stops long words from overflowing the
/// screen (the on-device "RIGHT OVERFLOWED BY 8/21/79/94 PIXELS" stripes:
/// a 15-letter word at the old fixed cell width was 430dp wide on a 360dp
/// phone). Words render as non-wrapping Rows, so every word must fit the
/// available width at the chosen cell size.
void main() {
  group('wordWidthAt', () {
    test('letters cost a cell plus margins, punctuation half a cell', () {
      // 5 letters + trailing comma at a 20dp cell:
      // 5 * (20 + 2) + 1 * (20 * 0.5) = 120.
      expect(wordWidthAt('FALSE,', 20), 120);
      expect(wordWidthAt('AB', 30), 2 * 32);
      expect(wordWidthAt("DON'T", 20), 4 * 22 + 10);
    });
  });

  group('fitCellWidth', () {
    test('returns the preferred width untouched when every word fits', () {
      final cell = fitCellWidth(
        preferred: 26.67,
        availableWidth: 336,
        words: ['HELLO', 'WORLD,', 'SHORT'],
      );
      expect(cell, 26.67);
    });

    test('a 15-letter word on a 360dp phone shrinks cells and fits', () {
      // Puzzle screen padding is 12+12, so a 360dp phone offers 336dp.
      final cell = fitCellWidth(
        preferred: 360 / 13.5,
        availableWidth: 336,
        words: 'ALL GENERALIZATIONS ARE FALSE'.split(' '),
      );
      expect(cell, lessThan(360 / 13.5));
      expect(cell, greaterThan(kMinBoardCellWidth));
      expect(
        wordWidthAt('GENERALIZATIONS', cell),
        lessThanOrEqualTo(336 - 1 + 0.001),
      );
    });

    test('letters plus trailing punctuation fit a 320dp phone', () {
      final cell = fitCellWidth(
        preferred: 320 / 13.5,
        availableWidth: 296,
        words: const ['SYSTEMATICALLY.'],
      );
      expect(
        wordWidthAt('SYSTEMATICALLY.', cell),
        lessThanOrEqualTo(296 - 1 + 0.001),
      );
    });

    test('never shrinks below the readability floor', () {
      final cell = fitCellWidth(
        preferred: 26,
        availableWidth: 100,
        words: const ['ABCDEFGHIJKLMNOPQRST'],
      );
      expect(cell, kMinBoardCellWidth);
    });

    test('ignores empty segments from double spaces', () {
      final cell = fitCellWidth(
        preferred: 26,
        availableWidth: 336,
        words: const ['', 'A'],
      );
      expect(cell, 26);
    });
  });

  test('every quote in the dataset fits a 320dp phone board', () {
    final dir = Directory('assets/data/quotes');
    final quotes = [
      for (final file in dir.listSync().whereType<File>())
        if (file.path.endsWith('.json'))
          ...(jsonDecode(file.readAsStringSync()) as List<dynamic>).map(
            (e) => Quote.fromJson(e as Map<String, dynamic>),
          ),
    ];
    expect(quotes, isNotEmpty);

    // Smallest supported phone: 320dp wide minus the 12+12 board padding.
    const available = 296.0;
    final preferred = (320 / 13.5).clamp(22.0, 34.0);

    for (final q in quotes) {
      final words = q.normalizedText.split(' ');
      final cell = fitCellWidth(
        preferred: preferred,
        availableWidth: available,
        words: words,
      );
      // The board must stay readable — if a future quote ever needs cells
      // below 16dp, shorten its longest word instead of shipping it.
      expect(
        cell,
        greaterThanOrEqualTo(16.0),
        reason: '${q.id}: longest word forces cells down to $cell dp',
      );
      for (final word in words) {
        expect(
          wordWidthAt(word, cell),
          lessThanOrEqualTo(available),
          reason: '${q.id}: "$word" would overflow at $cell dp cells',
        );
      }
    }
  });
}
