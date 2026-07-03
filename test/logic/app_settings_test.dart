import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

/// Settings round-trip and migration guarantees: new fields must default
/// sensibly for players upgrading from older versions.
void main() {
  test('fresh defaults: music and sound effects are on', () {
    final s = AppSettings();
    expect(s.music, isTrue);
    expect(s.soundEffects, isTrue);
    expect(s.themeMode, AppThemeMode.system);
    // Sensible mix defaults: effects sit just below the ceiling (headroom so
    // the fanfare riding over the bed never clips), and music sits under the
    // effects so feedback cues stay clearly audible over the bed.
    expect(s.soundVolume, 0.85);
    expect(s.musicVolume, 0.65);
    expect(s.musicVolume, lessThan(s.soundVolume));
  });

  test('volume preferences round-trip and default for legacy JSON', () {
    final s = AppSettings(soundVolume: 0.4, musicVolume: 0.2);
    final r = AppSettings.fromJson(s.toJson());
    expect(r.soundVolume, 0.4);
    expect(r.musicVolume, 0.2);
    // Upgraders without the keys fall back to the defaults, not silence.
    final legacy = AppSettings.fromJson({'music': true});
    expect(legacy.soundVolume, 0.85);
    expect(legacy.musicVolume, 0.65);
  });

  test('toJson/fromJson round-trips every field', () {
    final s = AppSettings(
      themeMode: AppThemeMode.sepia,
      textScale: 1.2,
      colorblindMode: true,
      highContrastMode: true,
      errorChecking: false,
      showTimer: false,
      haptics: false,
      soundEffects: false,
      music: false,
      reminderEnabled: true,
      reminderHour: 21,
      reminderMinute: 30,
      reminderNudgeDone: true,
      onboardingDone: true,
    );
    final r = AppSettings.fromJson(s.toJson());
    expect(r.toJson(), s.toJson());
    expect(r.music, isFalse);
    expect(r.reminderNudgeDone, isTrue);
    expect(r.highContrastMode, isTrue);
  });

  test('legacy settings JSON without highContrastMode defaults to OFF', () {
    final r = AppSettings.fromJson({'themeMode': 'dark'});
    expect(r.highContrastMode, isFalse);
  });

  test('legacy settings JSON without a music key defaults to ON', () {
    // settings.v1 written by 1.0.x has no 'music' entry.
    final r = AppSettings.fromJson({
      'themeMode': 'dark',
      'soundEffects': false,
    });
    expect(r.music, isTrue);
    expect(r.themeMode, AppThemeMode.dark);
    expect(r.soundEffects, isFalse);
    expect(r.reminderNudgeDone, isFalse);
  });

  test('the daily reminder text follows the chosen UI language', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final notifications = FakeNotificationService();
    final controller = SettingsController(
      storage: storage,
      notifications: notifications,
    );

    await controller.setLanguage('tr');
    await controller.setReminder(enabled: true);
    expect(notifications.scheduledTitle, 'Günlük şifren hazır');
    expect(notifications.scheduledBody, contains('Serini canlı tut'));

    await controller.setLanguage('en');
    await controller.setReminder(enabled: true);
    expect(notifications.scheduledTitle, 'Your daily cryptogram is ready');
  });

  test(
    'a grant made from system settings enables the reminder (no Settings loop)',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n = FakeNotificationService();
      final c = SettingsController(storage: storage, notifications: n);
      await c.setLanguage('en');

      // Reproduce the Android 13+ trap that caused the "keeps sending me back
      // to Settings" loop: the in-app permission REQUEST reports failure (no
      // dialog is shown for an already-decided permission), yet the user has
      // turned notifications ON from the system settings page.
      n.permissionGranted = false; // requestNotificationsPermission() -> false
      n.osEnabled = true; // ...but the OS actually allows them now

      final ok = await c.setReminder(enabled: true);

      // The reminder enables instead of dead-ending: the request falls back to
      // the real OS state, so the grant is finally honored.
      expect(ok, isTrue);
      expect(c.settings.reminderEnabled, isTrue);
      expect(n.scheduledAt, isNotNull);
    },
  );

  test('a genuinely blocked permission keeps the reminder off', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final n = FakeNotificationService();
    final c = SettingsController(storage: storage, notifications: n);
    await c.setLanguage('en');

    // Truly blocked: the OS refuses AND reports notifications off.
    n.permissionGranted = false;
    n.osEnabled = false;

    final ok = await c.setReminder(enabled: true);
    expect(ok, isFalse);
    expect(c.settings.reminderEnabled, isFalse);
    expect(n.scheduledAt, isNull);
  });

  test(
    'first denial is respected; a later attempt routes to system settings',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n = FakeNotificationService();
      final c = SettingsController(storage: storage, notifications: n);
      await c.setLanguage('en');

      // Blocked at the OS. The first enable shows the system prompt (denied here),
      // so the toggle stays off and we DON'T redirect — the "No" is honored.
      n.permissionGranted = false;
      n.osEnabled = false;
      expect(await c.setReminder(enabled: true), isFalse);
      expect(c.settings.reminderPermissionAsked, isTrue);
      expect(n.openSettingsCalls, 0);

      // A second attempt: Android won't show the prompt again, so the only path
      // back on is the OS settings page — open it directly (no custom modal).
      expect(await c.setReminder(enabled: true), isFalse);
      expect(c.settings.reminderEnabled, isFalse);
      expect(n.openSettingsCalls, 1);
    },
  );

  test(
    'granting in system settings completes a pending enable on resume',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n = FakeNotificationService();
      final c = SettingsController(storage: storage, notifications: n);
      await c.setLanguage('en');

      n.permissionGranted = false;
      n.osEnabled = false;
      await c.setReminder(enabled: true); // first: denied, records the ask
      await c.setReminder(enabled: true); // second: routed to system settings
      expect(n.openSettingsCalls, 1);
      expect(c.settings.reminderEnabled, isFalse);

      // The user grants notifications in system settings, then returns to the app.
      n.osEnabled = true;
      c.didChangeAppLifecycleState(AppLifecycleState.resumed);
      // Let the fire-and-forget resume reconciliation finish.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(c.settings.reminderEnabled, isTrue);
      expect(n.scheduledAt, isNotNull);
    },
  );

  test('hapticIntensity round-trips and defaults to full strength', () {
    expect(AppSettings().hapticIntensity, 1.0);
    final r = AppSettings.fromJson(AppSettings(hapticIntensity: 0.4).toJson());
    expect(r.hapticIntensity, 0.4);
    // Upgraders without the key get full strength, not silence.
    expect(AppSettings.fromJson(const {}).hapticIntensity, 1.0);
  });

  test(
    'rescheduleDailyIfEnabled re-arms an enabled reminder on startup',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n1 = FakeNotificationService();
      final c1 = SettingsController(storage: storage, notifications: n1);
      await c1.setLanguage('en'); // pin locale so l10n lookup needs no binding
      await c1.setReminder(enabled: true);
      expect(n1.scheduledTitle, isNotNull);

      // A fresh process (new controller + notification service) reads the saved
      // "enabled" flag and re-schedules without re-prompting for permission.
      final n2 = FakeNotificationService();
      final c2 = SettingsController(storage: storage, notifications: n2);
      expect(n2.scheduledTitle, isNull); // nothing scheduled yet
      await c2.rescheduleDailyIfEnabled();
      expect(n2.scheduledTitle, isNotNull);

      // When the reminder is off, startup re-scheduling is a no-op.
      await c2.setReminder(enabled: false);
      final n3 = FakeNotificationService();
      final c3 = SettingsController(storage: storage, notifications: n3);
      await c3.rescheduleDailyIfEnabled();
      expect(n3.scheduledTitle, isNull);
    },
  );

  test('syncReminderWithOsPermission turns the toggle off when the OS disabled '
      'notifications', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final n = FakeNotificationService();
    final c = SettingsController(storage: storage, notifications: n);
    await c.setLanguage('en');
    await c.setReminder(enabled: true);
    expect(c.settings.reminderEnabled, isTrue);

    // The user turns notifications off from system settings.
    n.osEnabled = true; // still enabled -> no change
    await c.syncReminderWithOsPermission();
    expect(c.settings.reminderEnabled, isTrue);

    n.osEnabled = false; // now disabled in the OS
    await c.syncReminderWithOsPermission();
    expect(c.settings.reminderEnabled, isFalse);
    expect(n.cancelCalls, greaterThan(0));
  });

  test('setMusic persists and survives a controller restart', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final controller = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
    );
    expect(controller.settings.music, isTrue);

    await controller.setMusic(false);
    final saved = storage.readJson(StorageService.settingsKey);
    expect(saved?['music'], isFalse);

    final reloaded = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
    );
    expect(reloaded.settings.music, isFalse);
  });

  test(
    'a scheduling failure keeps the reminder ON (permission granted) and never '
    'throws — it retries instead of reverting the toggle',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final controller = SettingsController(
        storage: storage,
        notifications: _ThrowingNotificationService(),
      );

      // The OS grants permission, but scheduling blows up. The toggle reflects
      // PERMISSION, not the alarm call, so it must stay ON; the call completes
      // normally (no crash) and the failed schedule is retried later. This is
      // the fix for "permission granted but the switch never turns on".
      final ok = await controller.setReminder(enabled: true);
      expect(ok, isTrue);
      expect(controller.settings.reminderEnabled, isTrue);
    },
  );

  test(
    'enables even when the permission request under-reports the grant '
    '(returns false) — setReminder trusts the OS state, not the return value',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n = _UnderReportingNotificationService();
      final c = SettingsController(storage: storage, notifications: n);
      await c.setLanguage('en');

      // Fresh install: not granted, never asked. The request returns false even
      // though the user tapped Allow (the real Android 13 quirk); the OS recheck
      // sees the grant, so the reminder turns ON.
      final ok = await c.setReminder(enabled: true);
      expect(ok, isTrue);
      expect(c.settings.reminderEnabled, isTrue);
      expect(n.scheduledAt, isNotNull);
    },
  );
}

/// Mimics the Android 13 quirk where the permission REQUEST returns false even
/// though the user tapped Allow (the grant lands out-of-band); [areEnabled] then
/// reports true. Proves setReminder trusts the OS state, not the request return.
class _UnderReportingNotificationService extends FakeNotificationService {
  _UnderReportingNotificationService() {
    permissionGranted = false;
    osEnabled = false;
  }

  @override
  Future<bool> requestPermission() async {
    osEnabled = true; // the user actually granted it...
    return false; // ...but the plugin under-reports the result
  }
}

/// Grants permission but throws when scheduling, to prove the reminder path
/// can never crash the app from the settings toggle.
class _ThrowingNotificationService extends FakeNotificationService {
  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    throw StateError('simulated plugin failure');
  }
}
