import 'dart:convert';

import 'package:flutter/services.dart'
    show AssetBundle, AssetManifest, rootBundle;

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

  /// Categories reserved for the premium packs.
  static const Set<String> premiumCategories = {'shakespeare', 'stoic'};

  /// Discovers EVERY quote file under assets/data/quotes (English at the root,
  /// each localized pack in its own locale subfolder) via the asset manifest,
  /// so adding a language is just dropping in a JSON file + a pubspec entry —
  /// no code change here.
  static Future<QuoteRepository> load({AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(b);
    final paths =
        manifest
            .listAssets()
            .where(
              (p) => p.startsWith('assets/data/quotes/') && p.endsWith('.json'),
            )
            .toList()
          ..sort(); // stable, platform-independent load order
    final all = <Quote>[];
    for (final p in paths) {
      final list = jsonDecode(await b.loadString(p)) as List<dynamic>;
      all.addAll(list.map((e) => Quote.fromJson(e as Map<String, dynamic>)));
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

  /// The English daily pool: every player on Earth shares the same English
  /// cipher to compare (Wordle-style) when playing in English. Free categories
  /// only, sorted by id for platform-stable ordering.
  List<Quote> get dailyPool {
    final pool =
        _quotes
            .where(
              (q) =>
                  q.locale == 'en' && !premiumCategories.contains(q.category),
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return pool;
  }

  /// The daily pool for a player whose content language is [locale]. Everyone
  /// on that language shares the same daily cipher for the day. Falls back to
  /// the English pool when a locale has no native dailies yet, so the home
  /// screen can always present a puzzle.
  List<Quote> dailyPoolFor(String locale) {
    if (locale == 'en') return dailyPool;
    final pool =
        _quotes
            .where(
              (q) =>
                  q.locale == locale &&
                  !premiumCategories.contains(q.category),
            )
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return pool.isEmpty ? dailyPool : pool;
  }

  /// Quotes belonging to [pack], ordered easiest-first inside the pack so
  /// progress feels like a ramp. [activeLocale] steers the difficulty ladder
  /// to the player's language (English by default).
  List<Quote> forPack(Pack pack, {String activeLocale = 'en'}) {
    final list =
        _quotes
            .where((q) => pack.contains(q, activeLocale: activeLocale))
            .toList()
          ..sort((a, b) {
            final byScore = a.score.compareTo(b.score);
            return byScore != 0 ? byScore : a.id.compareTo(b.id);
          });
    return list;
  }
}
