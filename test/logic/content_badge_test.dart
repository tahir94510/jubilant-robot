import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/config/app_config.dart';
import 'package:quotecrack/models/achievement.dart';
import 'package:quotecrack/models/app_settings.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

void main() {
  test('seenContentVersion defaults to 1 and round-trips through JSON', () {
    expect(AppSettings().seenContentVersion, 1);
    final restored = AppSettings.fromJson(
      AppSettings(seenContentVersion: 5).toJson(),
    );
    expect(restored.seenContentVersion, 5);
  });

  test('NEW content shows until the screen is opened, then clears', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final c = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
    );

    // Launch content (revision 1) is never "new"; the current batch is.
    expect(c.isContentNew(1), isFalse);
    expect(c.isContentNew(AppConfig.contentVersion), isTrue);

    await c.markContentSeen();
    expect(c.settings.seenContentVersion, AppConfig.contentVersion);
    expect(c.isContentNew(AppConfig.contentVersion), isFalse);

    // The cleared state persists across a restart.
    final c2 = SettingsController(
      storage: storage,
      notifications: FakeNotificationService(),
    );
    expect(c2.isContentNew(AppConfig.contentVersion), isFalse);
  });

  test('the v1.1.5 achievement batch is present and tagged', () {
    expect(Achievement.catalog.length, 24);
    final fresh = Achievement.catalog
        .where((a) => a.addedInVersion >= 2)
        .length;
    expect(fresh, 8);
    // contentVersion must cover the newest achievement, or its badge would
    // never clear.
    final maxAdded = Achievement.catalog
        .map((a) => a.addedInVersion)
        .reduce((a, b) => a > b ? a : b);
    expect(AppConfig.contentVersion, greaterThanOrEqualTo(maxAdded));
  });
}
