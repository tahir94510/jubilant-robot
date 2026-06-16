import 'package:flutter/material.dart';

import '../engine/difficulty.dart';
import '../l10n/app_localizations.dart';
import 'quote.dart';

enum PackKind { difficulty, themed, language, premium }

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
  });

  final String id;
  final String title;
  final String tagline;
  final IconData icon;
  final PackKind kind;
  final Difficulty? difficulty;
  final String? category;

  bool get premiumOnly => kind == PackKind.premium;

  /// Whether [q] belongs in this pack for a player whose active content
  /// language is [activeLocale].
  ///
  /// The difficulty ladder follows the player's language: English by default,
  /// but the moment they switch to (say) Turkish, Beginner→Expert fill with
  /// natively-authored Turkish quotes, graded by the same language-aware
  /// difficulty engine. Themed and premium packs stay English (curated
  /// collections), and each "language pack" is matched by its own category so
  /// every native library remains playable by everyone.
  bool contains(Quote q, {String activeLocale = 'en'}) {
    switch (kind) {
      case PackKind.difficulty:
        if (q.locale != activeLocale) return false;
        // The free ladder never leaks the premium-only categories.
        if (q.category == 'shakespeare' || q.category == 'stoic') return false;
        return q.difficulty == difficulty;
      case PackKind.themed:
        // Curated English themes — identical for every player.
        return q.locale == 'en' && q.category == category;
      case PackKind.language:
      case PackKind.premium:
        return q.category == category;
    }
  }

  /// The full pack catalog shown on the Packs screen, in display order.
  static const List<Pack> catalog = [
    // Difficulty ladder
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
    // Themed
    Pack(
      id: 'proverbs',
      title: 'Proverbs',
      tagline: 'Folk wisdom of the world',
      icon: Icons.public_outlined,
      kind: PackKind.themed,
      category: 'proverbs',
    ),
    Pack(
      id: 'humor',
      title: 'Humor',
      tagline: 'Wit from Twain to Wilde',
      icon: Icons.sentiment_very_satisfied_outlined,
      kind: PackKind.themed,
      category: 'humor',
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
      id: 'literature',
      title: 'Literature',
      tagline: 'Lines from great books',
      icon: Icons.menu_book_outlined,
      kind: PackKind.themed,
      category: 'literature',
    ),
    Pack(
      id: 'science',
      title: 'Science',
      tagline: 'Minds that moved the world',
      icon: Icons.science_outlined,
      kind: PackKind.themed,
      category: 'science',
    ),
    // Native-language packs (playable by everyone; each plays in its own
    // alphabet). More languages drop in here as their content lands.
    Pack(
      id: 'turkish',
      title: 'Türkçe',
      tagline: 'Türk atasözleri ve özlü sözler',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'turkish',
    ),
    Pack(
      id: 'spanish',
      title: 'Español',
      tagline: 'Spanish proverbs & sayings',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'spanish',
    ),
    Pack(
      id: 'german',
      title: 'Deutsch',
      tagline: 'German proverbs & sayings',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'german',
    ),
    Pack(
      id: 'french',
      title: 'Français',
      tagline: 'French proverbs & sayings',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'french',
    ),
    Pack(
      id: 'italian',
      title: 'Italiano',
      tagline: 'Italian proverbs & sayings',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'italian',
    ),
    Pack(
      id: 'portuguese',
      title: 'Português',
      tagline: 'Portuguese proverbs & sayings',
      icon: Icons.translate_outlined,
      kind: PackKind.language,
      category: 'portuguese',
    ),
    // Premium bonus packs
    Pack(
      id: 'shakespeare',
      title: 'Shakespeare',
      tagline: 'The Bard, uncut',
      icon: Icons.theater_comedy_outlined,
      kind: PackKind.premium,
      category: 'shakespeare',
    ),
    Pack(
      id: 'stoic',
      title: 'Stoic Wisdom',
      tagline: 'Marcus, Seneca, Epictetus',
      icon: Icons.account_balance_outlined,
      kind: PackKind.premium,
      category: 'stoic',
    ),
  ];

  static Pack byId(String id) => catalog.firstWhere((p) => p.id == id);
}

/// Localized title/tagline for a [Pack], resolved by id. The English [title]/
/// [tagline] on the const definitions stay as the fallback for any pack a
/// translation hasn't covered yet.
extension PackL10n on Pack {
  String localizedTitle(AppLocalizations l) => switch (id) {
    'beginner' => l.packTitleBeginner,
    'casual' => l.packTitleCasual,
    'skilled' => l.packTitleSkilled,
    'expert' => l.packTitleExpert,
    'proverbs' => l.packTitleProverbs,
    'humor' => l.packTitleHumor,
    'wisdom' => l.packTitleWisdom,
    'literature' => l.packTitleLiterature,
    'science' => l.packTitleScience,
    'shakespeare' => l.packTitleShakespeare,
    'stoic' => l.packTitleStoic,
    'turkish' => l.packTitleTurkish,
    'spanish' => l.packTitleSpanish,
    'german' => l.packTitleGerman,
    'french' => l.packTitleFrench,
    'italian' => l.packTitleItalian,
    'portuguese' => l.packTitlePortuguese,
    _ => title,
  };

  String localizedTagline(AppLocalizations l) => switch (id) {
    'beginner' => l.packTaglineBeginner,
    'casual' => l.packTaglineCasual,
    'skilled' => l.packTaglineSkilled,
    'expert' => l.packTaglineExpert,
    'proverbs' => l.packTaglineProverbs,
    'humor' => l.packTaglineHumor,
    'wisdom' => l.packTaglineWisdom,
    'literature' => l.packTaglineLiterature,
    'science' => l.packTaglineScience,
    'shakespeare' => l.packTaglineShakespeare,
    'stoic' => l.packTaglineStoic,
    'turkish' => l.packTaglineTurkish,
    'spanish' => l.packTaglineSpanish,
    'german' => l.packTaglineGerman,
    'french' => l.packTaglineFrench,
    'italian' => l.packTaglineItalian,
    'portuguese' => l.packTaglinePortuguese,
    _ => tagline,
  };
}
