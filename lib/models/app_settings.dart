import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, sepia, system }

/// User preferences (persisted as settings.v1).
class AppSettings {
  AppSettings({
    this.themeMode = AppThemeMode.system,
    this.languageCode,
    this.textScale = 1.0,
    this.colorblindMode = false,
    this.highContrastMode = false,
    this.batterySaver = false,
    this.errorChecking = true,
    this.showTimer = true,
    this.haptics = true,
    this.hapticIntensity = 1.0,
    this.soundEffects = true,
    this.soundVolume = 0.85,
    this.music = true,
    this.musicVolume = 0.65,
    this.reminderEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.reminderCustomized = false,
    this.reminderPermissionAsked = false,
    this.reminderNudgeDone = false,
    this.onboardingDone = false,
    this.seenContentVersion = 1,
    int? newContentSinceVersion,
    this.newContentNoticedAtMs = 0,
  }) : newContentSinceVersion = newContentSinceVersion ?? seenContentVersion;

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode:
        AppThemeMode.values.asNameMap()[json['themeMode']] ??
        AppThemeMode.system,
    languageCode: json['languageCode'] as String?,
    textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
    colorblindMode: json['colorblindMode'] as bool? ?? false,
    highContrastMode: json['highContrastMode'] as bool? ?? false,
    batterySaver: json['batterySaver'] as bool? ?? false,
    errorChecking: json['errorChecking'] as bool? ?? true,
    showTimer: json['showTimer'] as bool? ?? true,
    haptics: json['haptics'] as bool? ?? true,
    hapticIntensity: (json['hapticIntensity'] as num?)?.toDouble() ?? 1.0,
    soundEffects: json['soundEffects'] as bool? ?? true,
    soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.85,
    music: json['music'] as bool? ?? true,
    musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.65,
    reminderEnabled: json['reminderEnabled'] as bool? ?? false,
    reminderHour: json['reminderHour'] as int? ?? 20,
    reminderMinute: json['reminderMinute'] as int? ?? 0,
    reminderCustomized: json['reminderCustomized'] as bool? ?? false,
    reminderPermissionAsked: json['reminderPermissionAsked'] as bool? ?? false,
    reminderNudgeDone: json['reminderNudgeDone'] as bool? ?? false,
    onboardingDone: json['onboardingDone'] as bool? ?? false,
    seenContentVersion: json['seenContentVersion'] as int? ?? 1,
    // Absent on older saves: fall back to seenContentVersion, so a player who
    // had already cleared the current batch under the old view-based system
    // never sees those badges resurrected by this upgrade.
    newContentSinceVersion:
        json['newContentSinceVersion'] as int? ??
        (json['seenContentVersion'] as int? ?? 1),
    newContentNoticedAtMs: json['newContentNoticedAtMs'] as int? ?? 0,
  );

  AppThemeMode themeMode;

  /// UI language override (e.g. 'en', 'tr'); null follows the device locale.
  String? languageCode;

  /// 0.85 .. 1.4 — clamped in the UI; word-puzzle players skew older, so
  /// large-type support is a first-class feature.
  double textScale;
  bool colorblindMode;

  /// WCAG 2.2 high-contrast variant of the active theme (AAA text ratios,
  /// stronger borders and selection cues). Independent from [colorblindMode];
  /// the two compose.
  bool highContrastMode;

  /// Caps the display's refresh rate (instead of unlocking 90/120Hz) to cut
  /// power draw on high-refresh panels. Off by default: silkiness first,
  /// saving is the player's explicit choice.
  bool batterySaver;

  /// When on, a confirmed-wrong guess is tinted after the puzzle is full.
  bool errorChecking;
  bool showTimer;
  bool haptics;

  /// 0..1 strength multiplier on every haptic cue's amplitude. Lets a player
  /// keep haptics but soften (or strengthen) how firmly the phone buzzes,
  /// independent of the on/off [haptics] switch. 1.0 = the full designed ladder.
  double hapticIntensity;
  bool soundEffects;

  /// 0..1 multiplier on the (already balanced) sound-effect peaks. Lets a
  /// player keep effects but dial them down under the music.
  double soundVolume;

  /// Looping ambient bed; independent from [soundEffects] so players can
  /// keep the gentle key taps and still solve in silence (or vice versa).
  bool music;

  /// 0..1 multiplier on the ambient bed's base level, so music can be tuned
  /// up or down independently of the effects.
  double musicVolume;
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;

  /// True once the player has personally picked a reminder time. Until then,
  /// enabling the reminder uses a sensible per-language default hour instead of
  /// a fixed global one.
  bool reminderCustomized;

  /// True once the OS notification permission has been requested at least once.
  /// Android 13+ only shows its permission prompt the FIRST time; after a denial
  /// it never prompts again. This flag lets the enable flow tell "first ask"
  /// (show the system prompt, respect a No) apart from "already asked & blocked"
  /// (route straight to system settings, since the prompt can't reappear).
  bool reminderPermissionAsked;

  /// The one-time "protect your streak" reminder invitation on the daily
  /// completion screen: shown once, then never again (either answer).
  bool reminderNudgeDone;
  bool onboardingDone;

  /// Highest content revision this install has NOTICED. Auto-advanced to
  /// [AppConfig.contentVersion] on the first launch of a build that ships a
  /// newer batch (see SettingsController._reconcileNewContent) — no user
  /// action involved. (JSON key kept from the older view-based system.)
  int seenContentVersion;

  /// Lower bound of the "new" batch: items with
  /// `addedInVersion > newContentSinceVersion` wear the NEW badge while the
  /// discovery window is open. Set to the previously-noticed revision when
  /// [seenContentVersion] advances, so skipped revisions (2 -> 4) still badge
  /// everything the player hasn't had yet.
  int newContentSinceVersion;

  /// When the current batch was first noticed (epoch ms; 0 = nothing new
  /// noticed yet). Badges expire [AppConfig.newBadgeWindow] after this moment
  /// — time-based for every player, independent of what they open.
  int newContentNoticedAtMs;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'languageCode': languageCode,
    'textScale': textScale,
    'colorblindMode': colorblindMode,
    'highContrastMode': highContrastMode,
    'batterySaver': batterySaver,
    'errorChecking': errorChecking,
    'showTimer': showTimer,
    'haptics': haptics,
    'hapticIntensity': hapticIntensity,
    'soundEffects': soundEffects,
    'soundVolume': soundVolume,
    'music': music,
    'musicVolume': musicVolume,
    'reminderEnabled': reminderEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'reminderCustomized': reminderCustomized,
    'reminderPermissionAsked': reminderPermissionAsked,
    'reminderNudgeDone': reminderNudgeDone,
    'onboardingDone': onboardingDone,
    'seenContentVersion': seenContentVersion,
    'newContentSinceVersion': newContentSinceVersion,
    'newContentNoticedAtMs': newContentNoticedAtMs,
  };
}
