import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'engine/quote_repository.dart';
import 'services/ads/ads_service.dart';
import 'services/haptics_service.dart';
import 'services/notifications/notification_service.dart';
import 'services/purchases/purchase_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';
import 'state/economy_controller.dart';
import 'state/game_controller.dart';
import 'state/progress_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.init();
  final quotes = await QuoteRepository.load();

  final ads = AdsService();
  final purchases = PurchaseService();
  final notifications = NotificationService();
  await notifications.initialize();

  final settings = SettingsController(
    storage: storage,
    notifications: notifications,
  );
  final progress = ProgressController(storage: storage);
  final economy = EconomyController(
    storage: storage,
    purchases: purchases,
    ads: ads,
  );
  final game = GameController(storage: storage);
  final haptics = HapticsService(isEnabled: () => settings.settings.haptics);
  final sounds = SoundService(isEnabled: () => settings.settings.soundEffects);
  await sounds.initialize();

  // Store layer first (cached premium flag), then ads (skipped entirely for
  // premium). Both run post-launch and never block the first frame.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await purchases.initialize(initialPremium: economy.premium);
    await ads.initialize(premium: economy.premium);
  });

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        Provider.value(value: quotes),
        Provider<AdsService>.value(value: ads),
        Provider<PurchaseService>.value(value: purchases),
        Provider<NotificationService>.value(value: notifications),
        Provider.value(value: haptics),
        Provider.value(value: sounds),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider.value(value: economy),
        ChangeNotifierProvider.value(value: game),
      ],
      child: const QuotecrackApp(),
    ),
  );
}
