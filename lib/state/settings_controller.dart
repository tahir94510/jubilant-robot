import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/app_settings.dart';
import '../services/music_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';

/// Owns [AppSettings]: persistence + applying side effects (reminders).
class SettingsController extends ChangeNotifier {
  SettingsController({
    required StorageService storage,
    required NotificationService notifications,
  }) : _storage = storage,
       _notifications = notifications,
       settings = AppSettings.fromJson(
         storage.readJson(StorageService.settingsKey) ?? const {},
       );

  final StorageService _storage;
  final NotificationService _notifications;

  final AppSettings settings;

  Future<void> _save() async {
    await _storage.writeJson(StorageService.settingsKey, settings.toJson());
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) {
    settings.themeMode = mode;
    return _save();
  }

  /// Sets the UI language ([code] null = follow the device locale).
  Future<void> setLanguage(String? code) {
    settings.languageCode = code;
    return _save();
  }

  Future<void> setTextScale(double scale) {
    settings.textScale = scale.clamp(0.85, 1.4);
    return _save();
  }

  /// Live slider preview: updates the UI every drag tick WITHOUT touching
  /// disk (persisting per tick caused visible jank). Call [setTextScale]
  /// once on drag end to commit.
  void previewTextScale(double scale) {
    settings.textScale = scale.clamp(0.85, 1.4);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) {
    settings.soundEffects = value;
    return _save();
  }

  /// Live effect-volume drag: applies to the running service every tick for
  /// instant audible feedback, without a disk write. Commit with
  /// [setSoundVolume] on release.
  void previewSoundVolume(double value, SoundService sounds) {
    settings.soundVolume = value.clamp(0.0, 1.0);
    sounds.setUserVolume(settings.soundVolume);
    notifyListeners();
  }

  Future<void> setSoundVolume(double value, SoundService sounds) {
    settings.soundVolume = value.clamp(0.0, 1.0);
    sounds.setUserVolume(settings.soundVolume);
    return _save();
  }

  Future<void> setMusic(bool value) {
    settings.music = value;
    return _save();
  }

  void previewMusicVolume(double value, MusicService music) {
    settings.musicVolume = value.clamp(0.0, 1.0);
    music.setUserVolume(settings.musicVolume);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value, MusicService music) {
    settings.musicVolume = value.clamp(0.0, 1.0);
    music.setUserVolume(settings.musicVolume);
    return _save();
  }

  /// Persists the music preference, THEN applies it to the running service.
  /// Order matters: the service's isEnabled() gate must already reflect the
  /// new choice when setEnabled fades in/out. The one shared code path for
  /// the Settings tile and the home-screen quick toggle.
  Future<void> setMusicAndApply(bool value, MusicService music) async {
    await setMusic(value);
    await music.setEnabled(value);
  }

  Future<void> setColorblindMode(bool value) {
    settings.colorblindMode = value;
    return _save();
  }

  Future<void> setErrorChecking(bool value) {
    settings.errorChecking = value;
    return _save();
  }

  Future<void> setShowTimer(bool value) {
    settings.showTimer = value;
    return _save();
  }

  Future<void> setHaptics(bool value) {
    settings.haptics = value;
    return _save();
  }

  Future<void> markOnboardingDone() {
    settings.onboardingDone = true;
    return _save();
  }

  Future<void> markReminderNudgeDone() {
    settings.reminderNudgeDone = true;
    return _save();
  }

  /// True when [item] is newer than the content the player has already seen,
  /// so it should wear a "NEW" badge.
  bool isContentNew(int addedInVersion) =>
      addedInVersion > settings.seenContentVersion;

  /// Clears the "NEW" badges by recording that the player has now seen the
  /// current content revision. A no-op (no disk write) once already current.
  Future<void> markContentSeen() {
    if (settings.seenContentVersion >= AppConfig.contentVersion) {
      return Future.value();
    }
    settings.seenContentVersion = AppConfig.contentVersion;
    return _save();
  }

  /// Returns false when the OS permission was denied.
  Future<bool> setReminder({required bool enabled, TimeOfDay? time}) async {
    if (enabled) {
      final granted = await _notifications.requestPermission();
      if (!granted && _notifications.supported) {
        settings.reminderEnabled = false;
        await _save();
        return false;
      }
      settings.reminderEnabled = true;
      if (time != null) {
        settings.reminderHour = time.hour;
        settings.reminderMinute = time.minute;
      }
      await _notifications.scheduleDaily(settings.reminderTime);
    } else {
      settings.reminderEnabled = false;
      await _notifications.cancelAll();
    }
    await _save();
    return true;
  }
}
