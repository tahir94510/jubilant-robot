import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/pack.dart';
import '../models/quote.dart';
import 'difficulty.dart';

/// Loads and indexes the bundled quote dataset.
class QuoteRepository {
  QuoteRepository._(this._quotes) {
    for (final q in _quotes) {
      _byId[q.id] = q;
    }
  }

  static const List<String> _categoryFiles = [
    'wisdom',
    'humor',
    'proverbs',
    'literature',
    'science',
    'shakespeare',
    'stoic',
  ];

  /// Categories reserved for the premium packs.
  static const Set<String> premiumCategories = {'shakespeare', 'stoic'};

  static Future<QuoteRepository> load({AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    final all = <Quote>[];
    for (final name in _categoryFiles) {
      final raw = await b.loadString('assets/data/quotes/$name.json');
      final list = jsonDecode(raw) as List<dynamic>;
      all.addAll(
        list.map((e) => Quote.fromJson(e as Map<String, dynamic>)),
      );
    }
    return QuoteRepository._(all);
  }

  /// Test hook: build a repository from in-memory quotes.
  static QuoteRepository fromQuotes(List<Quote> quotes) =>
      QuoteRepository._(List.of(quotes));

  final List<Quote> _quotes;
  final Map<String, Quote> _byId = {};

  List<Quote> get all => List.unmodifiable(_quotes);

  Quote? byId(String id) => _byId[id];

  List<Quote> byCategory(String category) =>
      _quotes.where((q) => q.category == category).toList();

  List<Quote> byDifficulty(Difficulty difficulty) =>
      _quotes.where((q) => q.difficulty == difficulty).toList();

  /// Pool for the daily puzzle: free categories only, sorted by id for
  /// platform-stable ordering (asset iteration order must not matter).
  List<Quote> get dailyPool {
    final pool = _quotes
        .where((q) => !premiumCategories.contains(q.category))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return pool;
  }

  /// Quotes belonging to [pack], ordered easiest-first inside the pack so
  /// progress feels like a ramp.
  List<Quote> forPack(Pack pack) {
    final list = _quotes.where(pack.contains).toList()
      ..sort((a, b) {
        final byScore = a.score.compareTo(b.score);
        return byScore != 0 ? byScore : a.id.compareTo(b.id);
      });
    return list;
  }
}
