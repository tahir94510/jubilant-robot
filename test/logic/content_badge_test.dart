import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/config/app_config.dart';
import 'package:quotecrack/models/achievement.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

/// Locks the TIME-BASED "NEW" badge contract: freshly-shipped content wears
/// its badge for [AppConfig.newBadgeWindow] after the update first launches,
/// then normalizes on its own — for every player, independent of which
/// screens they open.
void main() {
  Future<SettingsController> makeController(DateTime Function() now) async {
    final storage = await StorageService.init();
    return SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
      now: now,
    );
  }

  test('new-content fields round-trip through JSON', () {
    final restored = AppSettings.fromJson(
      AppSettings(
        seenContentVersion: 5,
        newContentSinceVersion: 3,
        newContentNoticedAtMs: 1234,
      ).toJson(),
    );
    expect(restored.seenContentVersion, 5);
    expect(restored.newContentSinceVersion, 3);
    expect(restored.newContentNoticedAtMs, 1234);
  });

  test(
    'NEW shows for the discovery window, then normalizes by itself',
    () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 7, 1, 12);
      final c = await makeController(() => now);

      // First launch noticed the current batch: launch content (revision 1) is
      // never "new"; the current batch is — with no user action at all.
      expect(c.isContentNew(1), isFalse);
      expect(c.isContentNew(AppConfig.contentVersion), isTrue);

      // Still new near the end of the window...
      now = now.add(AppConfig.newBadgeWindow - const Duration(hours: 1));
      expect(c.isContentNew(AppConfig.contentVersion), isTrue);

      // ...and normal right after it, without anyone opening a screen.
      now = now.add(const Duration(hours: 2));
      expect(c.isContentNew(AppConfig.contentVersion), isFalse);
    },
  );

  test('the window survives a restart instead of restarting', () async {
    SharedPreferences.setMockInitialValues({});
    var now = DateTime(2026, 7, 1, 12);
    final storage = await StorageService.init();
    SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
      now: () => now,
    );

    // Relaunch after the window has passed: the stamp persisted, so badges
    // stay expired (a restart must never resurrect them).
    now = now.add(AppConfig.newBadgeWindow + const Duration(days: 1));
    final c2 = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
      now: () => now,
    );
    expect(c2.isContentNew(AppConfig.contentVersion), isFalse);
  });

  test('a legacy save that already viewed the batch never re-badges', () async {
    // Old view-based saves stored seenContentVersion == contentVersion with no
    // window fields; the migration must treat that as "window closed".
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    await storage.writeJson(StorageService.settingsKey, {
      'seenContentVersion': AppConfig.contentVersion,
    });
    final c = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
      now: () => DateTime(2026, 7, 1),
    );
    expect(c.isContentNew(AppConfig.contentVersion), isFalse);
  });

  test(
    'a clock rolled back past the stamp self-heals instead of sticking',
    () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 7, 10);
      final storage = await StorageService.init();
      SettingsController(
        storage: storage,
        notifications: FakeNotificationService(),
        now: () => now,
      );

      // Device clock rolled back BEFORE the stamp: reconcile re-stamps to "now"
      // so the badge window still measures forward and can expire normally.
      now = DateTime(2026, 7, 5);
      final c2 = SettingsController(
        storage: storage,
        notifications: FakeNotificationService(),
        now: () => now,
      );
      expect(c2.isContentNew(AppConfig.contentVersion), isTrue);
      now = now.add(AppConfig.newBadgeWindow + const Duration(minutes: 1));
      expect(c2.isContentNew(AppConfig.contentVersion), isFalse);
    },
  );

  test('the v1.1.5 achievement batch is present and tagged', () {
    expect(Achievement.catalog.length, 24);
    final fresh = Achievement.catalog
        .where((a) => a.addedInVersion >= 2)
        .length;
    expect(fresh, 8);
    // contentVersion must cover the newest achievement, or its badge would
    // never appear (and the batch would never be noticed).
    final maxAdded = Achievement.catalog
        .map((a) => a.addedInVersion)
        .reduce((a, b) => a > b ? a : b);
    expect(AppConfig.contentVersion, greaterThanOrEqualTo(maxAdded));
  });
}
