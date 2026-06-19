import 'package:flutter/material.dart';

import '../engine/difficulty.dart';
import '../l10n/app_localizations.dart';
import 'quote.dart';

enum PackKind { difficulty, themed, shortform, premium }

/// A puzzle pack: a named, filtered slice of the quote dataset.
class Pack {
  const Pack({
    required this.id,
    required this.title,
    required this.tagline,
    required this.icon,
    required this.kind,
    this.difficulty,
    this.category,
    this.maxLetters,
  });

  final String id;
  final String title;
  final String tagline;
  final IconData icon;
  final PackKind kind;
  final Difficulty? difficulty;
  final String? category;

  /// Upper bound on a quote's playable letter count for a [PackKind.shortform]
  /// pack (a cross-cutting "quick play" filter over the free pool).
  final int? maxLetters;

  bool get premiumOnly => kind == PackKind.premium;

  /// Whether [q] belongs in this pack for a player whose active content
  /// language is [activeLocale].
  ///
  /// Every pack is native to the active language: the difficulty ladder, the
  /// themed packs and the premium Classics pack all draw from that language's
  /// own authentic content. Switching the app language switches the entire
  /// catalog to that culture's quotes.
  bool contains(Quote q, {String activeLocale = 'en'}) {
    if (q.locale != activeLocale) return false;
    switch (kind) {
      case PackKind.difficulty:
        // The free ladder never includes the premium Classics category.
        if (q.category == 'classics') return false;
        return q.difficulty == difficulty;
      case PackKind.shortform:
        // A free, cross-cutting "quick play" filter: the shortest quotes from
        // the free pool (the premium Classics category stays locked).
        if (q.category == 'classics') return false;
        return q.letterCount <= (maxLetters ?? 40);
      case PackKind.themed:
      case PackKind.premium:
        return q.category == category;
    }
  }

  /// The full pack catalog, in display order. The same structure applies to
  /// every language; only the content behind each pack changes with the
  /// active locale.
  static const List<Pack> catalog = [
    // Difficulty ladder — graded from the active language's pool.
    Pack(
      id: 'beginner',
      title: 'Beginner',
      tagline: 'Long quotes, gentle ciphers',
      icon: Icons.spa_outlined,
      kind: PackKind.difficulty,
      difficulty: Difficulty.beginner,
    ),
    Pack(
      id: 'casual',
      title: 'Casual',
      tagline: 'A comfortable challenge',
      icon: Icons.coffee_outlined,
      kind: PackKind.difficulty,
      difficulty: Difficulty.casual,
    ),
    Pack(
      id: 'skilled',
      title: 'Skilled',
      tagline: 'For practiced decoders',
      icon: Icons.psychology_outlined,
      kind: PackKind.difficulty,
      difficulty: Difficulty.skilled,
    ),
    Pack(
      id: 'expert',
      title: 'Expert',
      tagline: 'Short, sharp, unforgiving',
      icon: Icons.whatshot_outlined,
      kind: PackKind.difficulty,
      difficulty: Difficulty.expert,
    ),
    // A free, cross-cutting quick-play pack: the shortest quotes from the
    // free pool, perfect for a fast round. Drawn by length, not category.
    Pack(
      id: 'shortsweet',
      title: 'Short & Sweet',
      tagline: 'Bite-size quotes for a quick win',
      icon: Icons.bolt_outlined,
      kind: PackKind.shortform,
      maxLetters: 40,
    ),
    // Themed — each language's own content under one shared taxonomy.
    Pack(
      id: 'proverbs',
      title: 'Proverbs',
      tagline: 'Folk wisdom of the world',
      icon: Icons.public_outlined,
      kind: PackKind.themed,
      category: 'proverbs',
    ),
    Pack(
      id: 'wisdom',
      title: 'Wisdom',
      tagline: 'Thinkers and statesmen',
      icon: Icons.auto_stories_outlined,
      kind: PackKind.themed,
      category: 'wisdom',
    ),
    Pack(
      id: 'wit',
      title: 'Wit',
      tagline: 'Sharp tongues and clever quips',
      icon: Icons.sentiment_very_satisfied_outlined,
      kind: PackKind.themed,
      category: 'wit',
    ),
    Pack(
      id: 'literature',
      title: 'Literature',
      tagline: 'Lines from great books',
      icon: Icons.menu_book_outlined,
      kind: PackKind.themed,
      category: 'literature',
    ),
    // Premium bonus pack — the active language's iconic classics.
    Pack(
      id: 'classics',
      title: 'Classics',
      tagline: 'Timeless voices, hand-picked',
      icon: Icons.auto_awesome_outlined,
      kind: PackKind.premium,
      category: 'classics',
    ),
  ];

  static Pack byId(String id) => catalog.firstWhere((p) => p.id == id);
}

/// Localized title/tagline for a [Pack], resolved by id. The English [title]/
/// [tagline] on the const definitions stay as the fallback.
extension PackL10n on Pack {
  String localizedTitle(AppLocalizations l) => switch (id) {
    'beginner' => l.packTitleBeginner,
    'casual' => l.packTitleCasual,
    'skilled' => l.packTitleSkilled,
    'expert' => l.packTitleExpert,
    'shortsweet' => l.packTitleShortSweet,
    'proverbs' => l.packTitleProverbs,
    'wisdom' => l.packTitleWisdom,
    'wit' => l.packTitleWit,
    'literature' => l.packTitleLiterature,
    'classics' => l.packTitleClassics,
    _ => title,
  };

  String localizedTagline(AppLocalizations l) => switch (id) {
    'beginner' => l.packTaglineBeginner,
    'casual' => l.packTaglineCasual,
    'skilled' => l.packTaglineSkilled,
    'expert' => l.packTaglineExpert,
    'shortsweet' => l.packTaglineShortSweet,
    'proverbs' => l.packTaglineProverbs,
    'wisdom' => l.packTaglineWisdom,
    'wit' => l.packTaglineWit,
    'literature' => l.packTaglineLiterature,
    'classics' => l.packTaglineClassics,
    _ => tagline,
  };
}
