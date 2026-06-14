import 'package:flutter/material.dart';

import 'game_stats.dart';

/// A static achievement definition; unlocked ids are persisted separately.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.addedInVersion = 1,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(GameStats stats) isUnlocked;

  /// Content revision this achievement first shipped in. Items newer than the
  /// revision the player last viewed get a "NEW" badge (see [AppConfig.
  /// contentVersion] and SettingsController.seenContentVersion).
  final int addedInVersion;

  /// Full catalog, in display order.
  static final List<Achievement> catalog = [
    Achievement(
      id: 'first_solve',
      title: 'First Crack',
      description: 'Solve your first cryptogram',
      icon: Icons.vpn_key_outlined,
      isUnlocked: (s) => s.totalSolved >= 1,
    ),
    Achievement(
      id: 'solve_10',
      title: 'Apprentice Decoder',
      description: 'Solve 10 puzzles',
      icon: Icons.lock_open_outlined,
      isUnlocked: (s) => s.totalSolved >= 10,
    ),
    Achievement(
      id: 'solve_25',
      title: 'Code Breaker',
      description: 'Solve 25 puzzles',
      icon: Icons.key_outlined,
      isUnlocked: (s) => s.totalSolved >= 25,
    ),
    Achievement(
      id: 'solve_50',
      title: 'Cipher Sleuth',
      description: 'Solve 50 puzzles',
      icon: Icons.search_outlined,
      isUnlocked: (s) => s.totalSolved >= 50,
    ),
    Achievement(
      id: 'solve_100',
      title: 'Centurion',
      description: 'Solve 100 puzzles',
      icon: Icons.military_tech_outlined,
      isUnlocked: (s) => s.totalSolved >= 100,
    ),
    Achievement(
      id: 'solve_250',
      title: 'Master Cryptologist',
      description: 'Solve 250 puzzles',
      icon: Icons.workspace_premium_outlined,
      isUnlocked: (s) => s.totalSolved >= 250,
    ),
    Achievement(
      id: 'solve_500',
      title: 'Grandmaster',
      description: 'Solve 500 puzzles',
      icon: Icons.shield_outlined,
      isUnlocked: (s) => s.totalSolved >= 500,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'streak_3',
      title: 'Warming Up',
      description: 'Reach a 3-day daily streak',
      icon: Icons.local_fire_department_outlined,
      isUnlocked: (s) => s.bestStreak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'One Solid Week',
      description: 'Reach a 7-day daily streak',
      icon: Icons.calendar_view_week_outlined,
      isUnlocked: (s) => s.bestStreak >= 7,
    ),
    Achievement(
      id: 'streak_14',
      title: 'Fortnight Focus',
      description: 'Reach a 14-day daily streak',
      icon: Icons.date_range_outlined,
      isUnlocked: (s) => s.bestStreak >= 14,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Monthly Devotion',
      description: 'Reach a 30-day daily streak',
      icon: Icons.calendar_month_outlined,
      isUnlocked: (s) => s.bestStreak >= 30,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Unbreakable',
      description: 'Reach a 100-day daily streak',
      icon: Icons.diamond_outlined,
      isUnlocked: (s) => s.bestStreak >= 100,
    ),
    Achievement(
      id: 'streak_365',
      title: 'Year-Round Decoder',
      description: 'Reach a 365-day daily streak',
      icon: Icons.event_available_outlined,
      isUnlocked: (s) => s.bestStreak >= 365,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'no_hints_10',
      title: 'Purist',
      description: 'Solve 10 puzzles without hints',
      icon: Icons.do_not_touch_outlined,
      isUnlocked: (s) => s.noHintSolves >= 10,
    ),
    Achievement(
      id: 'no_hints_25',
      title: 'Self-Reliant',
      description: 'Solve 25 puzzles without hints',
      icon: Icons.self_improvement_outlined,
      isUnlocked: (s) => s.noHintSolves >= 25,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'no_hints_50',
      title: 'Iron Will',
      description: 'Solve 50 puzzles without hints',
      icon: Icons.fitness_center_outlined,
      isUnlocked: (s) => s.noHintSolves >= 50,
    ),
    Achievement(
      id: 'no_hints_100',
      title: 'Unaided Mind',
      description: 'Solve 100 puzzles without hints',
      icon: Icons.psychology_alt_outlined,
      isUnlocked: (s) => s.noHintSolves >= 100,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'speed_30',
      title: 'Blink of an Eye',
      description: 'Solve a puzzle in under 30 seconds',
      icon: Icons.flash_on_outlined,
      isUnlocked: (s) => s.bestTimeSeconds != null && s.bestTimeSeconds! < 30,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'speed_60',
      title: 'Lightning Fast',
      description: 'Solve a puzzle in under 60 seconds',
      icon: Icons.bolt_outlined,
      isUnlocked: (s) => s.bestTimeSeconds != null && s.bestTimeSeconds! < 60,
    ),
    Achievement(
      id: 'speed_120',
      title: 'Quick Thinker',
      description: 'Solve a puzzle in under 2 minutes',
      icon: Icons.timer_outlined,
      isUnlocked: (s) => s.bestTimeSeconds != null && s.bestTimeSeconds! < 120,
    ),
    Achievement(
      id: 'daily_10',
      title: 'Daily Ritual',
      description: 'Solve 10 daily puzzles',
      icon: Icons.wb_sunny_outlined,
      isUnlocked: (s) => s.dailyHistory.values.where((v) => v).length >= 10,
    ),
    Achievement(
      id: 'daily_25',
      title: 'Faithful Solver',
      description: 'Solve 25 daily puzzles',
      icon: Icons.brightness_5_outlined,
      isUnlocked: (s) => s.dailyHistory.values.where((v) => v).length >= 25,
      addedInVersion: 2,
    ),
    Achievement(
      id: 'daily_50',
      title: 'Morning Coffee',
      description: 'Solve 50 daily puzzles',
      icon: Icons.coffee_maker_outlined,
      isUnlocked: (s) => s.dailyHistory.values.where((v) => v).length >= 50,
    ),
    Achievement(
      id: 'daily_100',
      title: 'Hundred Mornings',
      description: 'Solve 100 daily puzzles',
      icon: Icons.brightness_7_outlined,
      isUnlocked: (s) => s.dailyHistory.values.where((v) => v).length >= 100,
      addedInVersion: 2,
    ),
  ];
}
