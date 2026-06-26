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
    // Sensible mix defaults: effects at full, the bed sitting under them.
    expect(s.soundVolume, 1.0);
    expect(s.musicVolume, lessThan(1.0));
  });

  test('volume preferences round-trip and default for legacy JSON', () {
    final s = AppSettings(soundVolume: 0.4, musicVolume: 0.2);
    final r = AppSettings.fromJson(s.toJson());
    expect(r.soundVolume, 0.4);
    expect(r.musicVolume, 0.2);
    // Upgraders without the keys fall back to the defaults, not silence.
    final legacy = AppSettings.fromJson({'music': true});
    expect(legacy.soundVolume, 1.0);
    expect(legacy.musicVolume, 0.80);
  });

  test('toJson/fromJson round-trips every field', () {
    final s = AppSettings(
      themeMode: AppThemeMode.sepia,
      textScale: 1.2,
      colorblindMode: true,
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
    'sendTestNotification posts a localized test only when granted',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final n = FakeNotificationService();
      final c = SettingsController(storage: storage, notifications: n);
      await c.setLanguage('en');

      n.permissionGranted = true;
      expect(await c.sendTestNotification(), isTrue);
      expect(n.testCalls, 1);
      expect(n.testTitle, 'Your daily cryptogram is ready');

      // Denied permission: nothing fires and the call reports failure.
      n.permissionGranted = false;
      expect(await c.sendTestNotification(), isFalse);
      expect(n.testCalls, 1);
    },
  );

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
    'a scheduling failure leaves the reminder off and never throws',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final controller = SettingsController(
        storage: storage,
        notifications: _ThrowingNotificationService(),
      );

      // The OS grants permission, but scheduling blows up: the toggle must end
      // up OFF and the call must complete normally (no crash bubbles to the UI).
      final ok = await controller.setReminder(enabled: true);
      expect(ok, isFalse);
      expect(controller.settings.reminderEnabled, isFalse);
    },
  );
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
