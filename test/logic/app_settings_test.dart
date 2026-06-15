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
    expect(legacy.musicVolume, 0.65);
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
}
