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
    // On every return to the foreground, reconcile the in-app reminder with the
    // real OS state — both directions, so the toggle is never out of sync:
    //   * pending-enable: the user tapped "on" while blocked and we sent them to
    //     system settings; if they granted there, finish enabling now.
    //   * re-arm: an aggressive OEM (battery saver) can drop a scheduled alarm.
    //   * sync-off: the user may have turned notifications off in system settings.
    // All best-effort and never throw. (Scheduling is always inexact / Play-safe.)
    unawaited(_reconcileReminderOnResume());
  }

  /// One-shot resume reconciliation (see [didChangeAppLifecycleState]). Runs the
  /// pending-enable completion first; only if that doesn't enable does it fall
  /// through to the re-arm + turn-off sync.
  Future<void> _reconcileReminderOnResume() async {
    if (_pendingEnableAfterSettings) {
      _pendingEnableAfterSettings = false; // one-shot, whatever the outcome
      if (_notifications.supported && await _notifications.areEnabled()) {
        await _enableAndSchedule(null);
        notifyListeners();
        return; // now on and scheduled — nothing more to reconcile
      }
    }
    await rescheduleDailyIfEnabled();
    await syncReminderWithOsPermission();
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

  /// Session-only intent: the user tapped "turn on reminders" while the OS had
  /// notifications blocked, so we routed them to system settings. If they grant
  /// the permission there, the next resume completes the enable. Not persisted —
  /// a one-shot tied to that specific round-trip.
  bool _pendingEnableAfterSettings = false;

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

  /// Live haptic-intensity drag: updates the value (and lets the next cue use it)
  /// every tick without a disk write, so dragging feels responsive. Commit with
  /// [setHapticIntensity] on release. The service reads [AppSettings.hapticIntensity]
  /// directly on each buzz, so no service call is needed here.
  void previewHapticIntensity(double value) {
    settings.hapticIntensity = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> setHapticIntensity(double value) {
    settings.hapticIntensity = value.clamp(0.0, 1.0);
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

  /// Turns the daily reminder on or off. Returns true when the reminder is on
  /// and scheduled afterwards; false when it ended up off (explicit denial, a
  /// scheduling failure, or a redirect to system settings is in progress).
  ///
  /// Enable flow (mirrors the user's choice exactly, no custom modal):
  ///   1. OS already allows notifications  -> just schedule.
  ///   2. Never asked before               -> show the system permission prompt
  ///      once. Granted -> schedule. Denied -> stay off (respect the No; no nag,
  ///      no redirect).
  ///   3. Asked before but still blocked   -> the system can't re-prompt, so open
  ///      this app's notification settings directly and remember the intent; the
  ///      next resume finishes enabling if the user granted it there.
  /// Disable always cancels every scheduled notification — the in-app switch is
  /// the true on/off (an app can't revoke its own OS permission on Android).
  Future<bool> setReminder({required bool enabled, TimeOfDay? time}) async {
    if (!enabled) {
      settings.reminderEnabled = false;
      _pendingEnableAfterSettings = false;
      await _notifications.cancelAll();
      await _save();
      return true;
    }

    // Web/stub has no OS permission concept: just flip it on and schedule.
    if (!_notifications.supported) return _enableAndSchedule(time);

    if (await _notifications.areEnabled()) return _enableAndSchedule(time);

    if (!settings.reminderPermissionAsked) {
      // First ever ask: this is the one time Android shows its system prompt.
      settings.reminderPermissionAsked = true;
      final granted = await _notifications.requestPermission();
      if (granted) return _enableAndSchedule(time);
      // Explicit "No": honor it — leave the toggle off, do not redirect.
      settings.reminderEnabled = false;
      await _save();
      return false;
    }

    // Asked before and still blocked: the system prompt won't reappear, so the
    // only way back on is the OS settings page. Route there and remember to
    // finish enabling on resume if the permission gets granted.
    _pendingEnableAfterSettings = true;
    settings.reminderEnabled = false;
    await _save();
    await _notifications.openSystemSettings();
    return false;
  }

  /// Marks the reminder on, applies the chosen/default time, and schedules it.
  /// Scheduling talks to the OS alarm/timezone plugins, which can throw on some
  /// devices; a failure must never crash the app, so it leaves the toggle off
  /// and reports false instead.
  Future<bool> _enableAndSchedule(TimeOfDay? time) async {
    settings.reminderEnabled = true;
    _applyReminderTime(time);
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
    await _save();
    return true;
  }

  /// Applies the reminder time: the player's explicit pick (and stops overriding
  /// with the language default from then on), or a sensible per-language evening
  /// hour on the first enable when no time was chosen.
  void _applyReminderTime(TimeOfDay? time) {
    if (time != null) {
      settings.reminderHour = time.hour;
      settings.reminderMinute = time.minute;
      settings.reminderCustomized = true;
    } else if (!settings.reminderCustomized) {
      final t = _defaultReminderTime();
      settings.reminderHour = t.hour;
      settings.reminderMinute = t.minute;
    }
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
