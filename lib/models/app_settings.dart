import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, sepia, system }

/// User preferences (persisted as settings.v1).
class AppSettings {
  AppSettings({
    this.themeMode = AppThemeMode.system,
    this.textScale = 1.0,
    this.colorblindMode = false,
    this.errorChecking = true,
    this.showTimer = true,
    this.haptics = true,
    this.soundEffects = true,
    this.music = true,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.reminderNudgeDone = false,
    this.onboardingDone = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[json['themeMode']] ??
        AppThemeMode.system,
    textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
    colorblindMode: json['colorblindMode'] as bool? ?? false,
    errorChecking: json['errorChecking'] as bool? ?? true,
    showTimer: json['showTimer'] as bool? ?? true,
    haptics: json['haptics'] as bool? ?? true,
    soundEffects: json['soundEffects'] as bool? ?? true,
    music: json['music'] as bool? ?? true,
    reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    reminderHour: json['reminderHour'] as int? ?? 9,
    reminderMinute: json['reminderMinute'] as int? ?? 0,
    reminderNudgeDone: json['reminderNudgeDone'] as bool? ?? false,
    onboardingDone: json['onboardingDone'] as bool? ?? false,
  );

  AppThemeMode themeMode;

  /// 0.85 .. 1.4 — clamped in the UI; word-puzzle players skew older, so
  /// large-type support is a first-class feature.
  double textScale;
  bool colorblindMode;

  /// When on, a confirmed-wrong guess is tinted after the puzzle is full.
  bool errorChecking;
  bool showTimer;
  bool haptics;
  bool soundEffects;

  /// Looping ambient bed; independent from [soundEffects] so players can
  /// keep the gentle key taps and still solve in silence (or vice versa).
  bool music;
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;

  /// The one-time "protect your streak" reminder invitation on the daily
  /// completion screen: shown once, then never again (either answer).
  bool reminderNudgeDone;
  bool onboardingDone;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'textScale': textScale,
    'colorblindMode': colorblindMode,
    'errorChecking': errorChecking,
    'showTimer': showTimer,
    'haptics': haptics,
    'soundEffects': soundEffects,
    'music': music,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'reminderNudgeDone': reminderNudgeDone,
    'onboardingDone': onboardingDone,
  };
}
