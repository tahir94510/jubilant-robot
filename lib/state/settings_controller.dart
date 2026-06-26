import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../services/music_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';

/// Owns [AppSettings]: persistence + applying side effects (reminders).
class SettingsController extends ChangeNotifier with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Re-arm the reminder every time the app returns to the foreground: an
    // aggressive OEM (battery saver) can drop a scheduled alarm while the app is
    // backgrounded, so rescheduling here keeps an enabled reminder reliable.
    // syncReminderWithOsPermission also reflects a notifications-off change the
    // user may have made from system settings. Both are best-effort and never
    // throw. (Scheduling is always inexact / Play-safe — the app requests no
    // exact-alarm permission, so there is nothing to "upgrade" on resume.)
    unawaited(rescheduleDailyIfEnabled());
    unawaited(syncReminderWithOsPermission());
  }

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

  /// Resolves [AppLocalizations] for the active UI language without a
  /// BuildContext — used to localize scheduled notifications. Falls back to
  /// the device locale, then English, for any unsupported code.
  AppLocalizations _activeL10n() {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    var code = settings.languageCode;
    code ??= PlatformDispatcher.instance.locale.languageCode;
    if (!supported.contains(code)) code = 'en';
    return lookupAppLocalizations(Locale(code));
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

  /// A sensible default reminder time for the active UI language — a relaxed
  /// evening hour when people unwind with a puzzle, nudged later for cultures
  /// with later evenings. Used until the player picks their own time.
  TimeOfDay _defaultReminderTime() {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    // PlatformDispatcher.instance (dart:ui) needs no widget binding, so this is
    // safe to call from controllers/tests outside a running app.
    var code = settings.languageCode;
    code ??= PlatformDispatcher.instance.locale.languageCode;
    if (!supported.contains(code)) code = 'en';
    // Later dinners / evenings in these locales -> a 21:00 nudge; 20:00 elsewhere.
    const lateEvening = {'tr', 'es', 'it', 'pt'};
    return TimeOfDay(hour: lateEvening.contains(code) ? 21 : 20, minute: 0);
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
        // The player picked their own time: honor it and stop overriding with
        // the language default from here on.
        settings.reminderHour = time.hour;
        settings.reminderMinute = time.minute;
        settings.reminderCustomized = true;
      } else if (!settings.reminderCustomized) {
        // First enable without a chosen time: pick a sensible evening hour for
        // the player's language/community instead of a fixed global default.
        final t = _defaultReminderTime();
        settings.reminderHour = t.hour;
        settings.reminderMinute = t.minute;
      }
      // Scheduling talks to the OS alarm/timezone plugins, which can throw on
      // some devices. A failure must NEVER crash the app from the settings
      // toggle: swallow it, leave the toggle off, and report a soft denial so
      // the user sees a snackbar instead of the app disappearing.
      try {
        final l10n = _activeL10n();
        await _notifications.scheduleDaily(
          settings.reminderTime,
          title: l10n.notificationDailyTitle,
          body: l10n.notificationDailyBody,
        );
      } catch (e) {
        debugPrint('scheduleDaily failed: $e');
        settings.reminderEnabled = false;
        await _save();
        return false;
      }
    } else {
      settings.reminderEnabled = false;
      await _notifications.cancelAll();
    }
    await _save();
    return true;
  }

  /// Re-arms the daily reminder on app startup when it is enabled. The OS boot
  /// receiver restores alarms after a reboot, but a force-stop or app update can
  /// drop them; re-scheduling here (without re-prompting for permission) keeps
  /// an enabled reminder reliable. Never throws — a failure must not block
  /// startup.
  Future<void> rescheduleDailyIfEnabled() async {
    if (!settings.reminderEnabled || !_notifications.supported) return;
    try {
      final l10n = _activeL10n();
      await _notifications.scheduleDaily(
        settings.reminderTime,
        title: l10n.notificationDailyTitle,
        body: l10n.notificationDailyBody,
      );
    } catch (e) {
      // Best-effort: an enabled reminder simply won't re-arm this launch.
      debugPrint('rescheduleDailyIfEnabled failed: $e');
    }
  }

  /// Posts an immediate test notification so the player can confirm reminders
  /// actually arrive on their device. Requests permission first (the reminder
  /// may never have been enabled). Returns false if unsupported or denied.
  Future<bool> sendTestNotification() async {
    if (!_notifications.supported) return false;
    final granted = await _notifications.requestPermission();
    if (!granted) return false;
    final l10n = _activeL10n();
    await _notifications.sendTestNotification(
      title: l10n.notificationDailyTitle,
      body: l10n.notificationDailyBody,
    );
    return true;
  }

  /// Keeps the in-app reminder toggle honest when the user turns notifications
  /// off from system settings: if the OS no longer allows notifications but the
  /// app still thinks the reminder is on, switch it off and cancel. Safe to call
  /// on every resume; never throws.
  Future<void> syncReminderWithOsPermission() async {
    if (!settings.reminderEnabled || !_notifications.supported) return;
    try {
      if (!await _notifications.areEnabled()) {
        settings.reminderEnabled = false;
        await _notifications.cancelAll();
        await _save();
        notifyListeners();
      }
    } catch (_) {
      // Best-effort sync; a failure must never disrupt the app.
    }
  }
}
