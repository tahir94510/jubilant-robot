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
