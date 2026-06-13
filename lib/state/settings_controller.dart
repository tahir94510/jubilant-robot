import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/music_service.dart';
import '../services/notifications/notification_service.dart';
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

  Future<void> setMusic(bool value) {
    settings.music = value;
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
