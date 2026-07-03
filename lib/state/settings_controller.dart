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

  /// One-shot resume reconciliation (see [didChangeAppLifecycleState]). Completes
  /// a pending enable first (the authoritative path: the OS grant may only become
  /// visible now), then retries a failed schedule, then the turn-off sync.
  Future<void> _reconcileReminderOnResume() async {
    if (_pendingEnable && _notifications.supported) {
      if (await _notifications.areEnabled()) {
        _pendingEnable = false;
        await _enableAndSchedule(null);
        notifyListeners();
        return; // now on and scheduled — nothing more to reconcile
      }
      // Still not granted after returning: the user declined. Drop the intent so
      // we don't surprise-enable later, and fall through to the off-sync.
      _pendingEnable = false;
    }
    // Re-arm an enabled reminder (also retries a previously failed schedule).
    await rescheduleDailyIfEnabled();
    await syncReminderWithOsPermission();
  }

  /// Polls the OS permission a few times so a grant that propagates just after
  /// the system dialog/settings page closes is not missed. The plugin's request
  /// return is unreliable on Android 13+, so [areNotificationsEnabled] is the
  /// authority — we just give it a moment to reflect a fresh grant.
  Future<bool> _areEnabledWithRetry() async {
    for (var i = 0; i < 6; i++) {
      if (await _notifications.areEnabled()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return _notifications.areEnabled();
  }

  SettingsController({
    required StorageService storage,
    required NotificationService notifications,
    DateTime Function()? now,
  }) : _storage = storage,
       _notifications = notifications,
       _now = now ?? DateTime.now,
       settings = AppSettings.fromJson(
         storage.readJson(StorageService.settingsKey) ?? const {},
       ) {
    _reconcileNewContent();
  }

  final StorageService _storage;
  final NotificationService _notifications;

  /// Injectable clock so the time-based NEW-badge window is testable.
  final DateTime Function() _now;

  final AppSettings settings;

  /// Session-only intent: the user tapped "turn on reminders" but the OS had not
  /// granted notifications yet (we showed the prompt, or routed them to system
  /// settings). The grant can land asynchronously — the system prompt's result
  /// is unreliable and arrives around a pause/resume — so on the NEXT resume, if
  /// the OS now allows notifications, we finish enabling. Covers BOTH the prompt
  /// and the settings-redirect paths. Not persisted; cleared once resolved.
  bool _pendingEnable = false;

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

  Future<void> setHighContrastMode(bool value) {
    settings.highContrastMode = value;
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

  /// Notices a freshly-shipped content batch: on the first launch of a build
  /// whose [AppConfig.contentVersion] is above the last-noticed revision, the
  /// window's lower bound and timestamp are stamped so everything newer wears
  /// a "NEW" badge for [AppConfig.newBadgeWindow] — for EVERY player (fresh
  /// installs included), with no user action involved. Also self-heals a
  /// timestamp left in the future by a device-clock rollback, so the window
  /// can never get stuck open.
  void _reconcileNewContent() {
    final nowMs = _now().millisecondsSinceEpoch;
    var changed = false;
    if (settings.seenContentVersion < AppConfig.contentVersion) {
      settings.newContentSinceVersion = settings.seenContentVersion;
      settings.seenContentVersion = AppConfig.contentVersion;
      settings.newContentNoticedAtMs = nowMs;
      changed = true;
    } else if (settings.newContentNoticedAtMs > nowMs) {
      settings.newContentNoticedAtMs = nowMs;
      changed = true;
    }
    if (changed) unawaited(_save());
  }

  /// True while [addedInVersion] belongs to the current "new" batch AND the
  /// time-based discovery window is still open. Purely time-based: badges
  /// normalize on their own after [AppConfig.newBadgeWindow], whether or not
  /// the player ever opened the screen.
  bool isContentNew(int addedInVersion) {
    if (addedInVersion <= settings.newContentSinceVersion) return false;
    final noticed = settings.newContentNoticedAtMs;
    if (noticed <= 0) return false;
    final age = _now().millisecondsSinceEpoch - noticed;
    return age >= 0 && age < AppConfig.newBadgeWindow.inMilliseconds;
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
      _pendingEnable = false;
      await _notifications.cancelAll();
      await _save();
      return true;
    }

    // Web/stub has no OS permission concept: just flip it on and schedule.
    if (!_notifications.supported) return _enableAndSchedule(time);

    // OS already allows it: enable straight away.
    if (await _notifications.areEnabled()) return _enableAndSchedule(time);

    if (!settings.reminderPermissionAsked) {
      // First ever ask: the one time Android shows its system prompt. Its return
      // value is unreliable (it can report false even when the user tapped
      // Allow), so we IGNORE it and re-check the real OS state with a short
      // retry — that is what makes "say yes -> toggle turns on" actually work.
      settings.reminderPermissionAsked = true;
      _pendingEnable =
          true; // resume will also finish this if the grant is late
      await _save();
      await _notifications.requestPermission();
      if (await _areEnabledWithRetry()) {
        _pendingEnable = false;
        return _enableAndSchedule(time);
      }
      // Genuinely declined: honor the "No" — leave it off (resume won't enable
      // because the intent is cleared), no redirect.
      _pendingEnable = false;
      settings.reminderEnabled = false;
      await _save();
      return false;
    }

    // Asked before and still blocked: the system prompt won't reappear, so the
    // only way back on is the OS settings page. Route there and remember to
    // finish enabling on the next resume if the permission gets granted.
    _pendingEnable = true;
    settings.reminderEnabled = false;
    await _save();
    await _notifications.openSystemSettings();
    return false;
  }

  /// Marks the reminder ON (reflecting the user's choice + OS permission), saves
  /// so the toggle updates immediately, THEN schedules. A scheduling failure does
  /// NOT revert the toggle — the reminder stays on and we retry on the next
  /// resume/launch ([_needsReschedule]). This is the fix for "permission is
  /// granted but the switch never turns on": the switch tracks permission, not
  /// the success of an alarm call that can transiently fail.
  Future<bool> _enableAndSchedule(TimeOfDay? time) async {
    settings.reminderEnabled = true;
    _applyReminderTime(time);
    await _save(); // toggle reflects ON right away
    try {
      final l10n = _activeL10n();
      await _notifications.scheduleDaily(
        settings.reminderTime,
        title: l10n.notificationDailyTitle,
        body: l10n.notificationDailyBody,
      );
    } catch (e) {
      // The toggle stays ON (it reflects permission); the unconditional
      // rescheduleDailyIfEnabled() on the next resume/launch retries the alarm.
      debugPrint('scheduleDaily failed (will retry on resume): $e');
    }
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
