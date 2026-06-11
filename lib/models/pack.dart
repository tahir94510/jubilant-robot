import 'package:flutter/material.dart';

import '../engine/difficulty.dart';
import 'quote.dart';

enum PackKind { difficulty, themed, premium }

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

  bool contains(Quote q) {
    if (difficulty != null && q.difficulty != difficulty) return false;
    if (category != null && q.category != category) return false;
    if (kind != PackKind.premium &&
        (q.category == 'shakespeare' || q.category == 'stoic')) {
      return false;
    }
    return true;
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
