import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quotecrack/engine/quote_repository.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/services/ads/ads_service.dart';
import 'package:quotecrack/services/haptics_service.dart';
import 'package:quotecrack/services/notifications/notification_service.dart';
import 'package:quotecrack/services/purchases/purchase_service.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/economy_controller.dart';
import 'package:quotecrack/state/game_controller.dart';
import 'package:quotecrack/state/progress_controller.dart';
import 'package:quotecrack/state/settings_controller.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_services.dart';

/// Everything a widget test needs, wired with fakes and in-memory prefs.
class Harness {
  Harness._({
    required this.storage,
    required this.repo,
    required this.ads,
    required this.purchases,
    required this.notifications,
    required this.settings,
    required this.progress,
    required this.economy,
    required this.game,
  });

  final StorageService storage;
  final QuoteRepository repo;
  final FakeAdsService ads;
  final FakePurchaseService purchases;
  final FakeNotificationService notifications;
  final SettingsController settings;
  final ProgressController progress;
  final EconomyController economy;
  final GameController game;

  static Future<Harness> create({
    List<Quote>? quotes,
    bool premium = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final repo = QuoteRepository.fromQuotes(quotes ?? [shortQuote]);
    final ads = FakeAdsService();
    final purchases = FakePurchaseService(initiallyOwned: premium);
    final notifications = FakeNotificationService();
    final settings =
        SettingsController(storage: storage, notifications: notifications);
    final progress = ProgressController(storage: storage);
    final economy =
        EconomyController(storage: storage, purchases: purchases, ads: ads);
    final game = GameController(storage: storage);
    if (premium) {
      // Mirror production: the purchase stream listener flips the flag.
      purchases.owned.value = true;
      await Future<void>.delayed(Duration.zero);
    }
    return Harness._(
      storage: storage,
      repo: repo,
      ads: ads,
      purchases: purchases,
      notifications: notifications,
      settings: settings,
      progress: progress,
      economy: economy,
      game: game,
    );
  }

  /// Wraps [child] in the full provider tree inside a MaterialApp.
  Widget app(Widget child) {
    return MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: repo),
        Provider<AdsService>.value(value: ads),
        Provider<PurchaseService>.value(value: purchases),
        Provider<NotificationService>.value(value: notifications),
        Provider.value(
            value: HapticsService(isEnabled: () => settings.settings.haptics)),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider.value(value: economy),
        ChangeNotifierProvider.value(value: game),
      ],
      child: MaterialApp(
        theme: AppThemes.light(colorblind: false),
        home: child,
      ),
    );
  }
}

/// A tiny fixture quote: 7 distinct letters, quick to solve in tests.
final Quote shortQuote = Quote(
  id: 'test-001',
  text: 'Less is more.',
  author: 'Robert Browning',
  source: 'Andrea del Sarto, 1855',
  category: 'wisdom',
);
