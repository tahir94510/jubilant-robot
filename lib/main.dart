import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'engine/quote_repository.dart';
import 'services/ads/ads_service.dart';
import 'services/haptics_service.dart';
import 'services/music_service.dart';
import 'services/notifications/notification_service.dart';
import 'services/purchases/purchase_service.dart';
import 'services/sound_service.dart';
import 'services/update_service.dart';
import 'services/storage_service.dart';
import 'state/economy_controller.dart';
import 'state/game_controller.dart';
import 'state/progress_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  // Every startup error is caught here so a failing plugin or a bad frame
  // can never instant-close the app: in release the handlers swallow
  // non-fatal errors, and the worst case falls back to a readable screen
  // instead of a crash.
  runZonedGuarded(
    _start,
    (error, stack) => debugPrint('Uncaught zone error: $error\n$stack'),
  );
}

Future<void> _start() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait: the board + custom on-screen keyboard are designed for a
  // tall layout, and in landscape the keyboard squeezes the board. A no-op on
  // desktop/web/TV (where this is ignored and a physical keyboard is used).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Draw behind the status + navigation bars. Android 15 (targetSdk 35+)
  // enforces this anyway; enabling it explicitly keeps the look consistent on
  // older versions too. Content stays clear of the bars via SafeArea/PageBody,
  // and app.dart sets a transparent, theme-adaptive bar style.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load date-formatting symbols for every locale so DateFormat renders the
  // daily header (and heatmap captions) in the player's language — without
  // this, intl silently falls back to English month/day names.
  await initializeDateFormatting();

  // Don't let a single non-fatal framework/async error tear the app down in
  // release (the red screen only exists in debug anyway).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error: $error\n$stack');
    return true; // handled — do not crash
  };

  // The two pieces of state the game genuinely cannot run without. If either
  // throws we show a friendly screen rather than dying silently.
  final StorageService storage;
  final QuoteRepository quotes;
  try {
    storage = await StorageService.init();
    quotes = await QuoteRepository.load();
  } catch (e, s) {
    debugPrint('Fatal startup error loading core data: $e\n$s');
    runApp(const _StartupErrorApp());
    return;
  }

  final ads = AdsService();
  final purchases = PurchaseService();
  final notifications = NotificationService();
  // Non-essential: a notification-init failure must not block the game.
  try {
    await notifications.initialize();
  } catch (e) {
    debugPrint('Notification init failed (continuing): $e');
  }

  final settings = SettingsController(
    storage: storage,
    notifications: notifications,
  );
  // Re-arm the reminder on every resume (not just launch): upgrades to exact
  // after the user grants the Android 14+ exact-alarm permission, and re-arms an
  // alarm an aggressive OEM dropped while backgrounded.
  WidgetsBinding.instance.addObserver(settings);
  // Re-arm an enabled daily reminder on startup: the OS boot receiver covers
  // reboots, but a force-stop/app update can drop the alarm. Fire-and-forget so
  // it never delays the first frame.
  unawaited(settings.rescheduleDailyIfEnabled());
  // If the user turned notifications off in system settings while away, reflect
  // that in the in-app reminder toggle on next launch.
  unawaited(settings.syncReminderWithOsPermission());
  // For the one-time stats.v1 -> stats.v2 migration: route each previously
  // solved quote into its own language, and carry the non-splittable counters
  // into the player's current language (clamped to a supported one).
  const supportedLocales = {'en', 'tr', 'es', 'de', 'fr', 'it', 'pt'};
  final deviceLang = PlatformDispatcher.instance.locale.languageCode;
  final migrationLocale = settings.settings.languageCode ?? deviceLang;
  final progress = ProgressController(
    storage: storage,
    quoteLocales: {for (final q in quotes.all) q.id: q.locale},
    migrationLocale: supportedLocales.contains(migrationLocale)
        ? migrationLocale
        : 'en',
  );
  final economy = EconomyController(
    storage: storage,
    purchases: purchases,
    ads: ads,
  );
  final game = GameController(storage: storage);
  final haptics = HapticsService(isEnabled: () => settings.settings.haptics);
  final sounds = SoundService(isEnabled: () => settings.settings.soundEffects);
  await sounds.initialize(); // already internally guarded
  sounds.setUserVolume(settings.settings.soundVolume);
  final music = MusicService(isEnabled: () => settings.settings.music)
    ..setUserVolume(settings.settings.musicVolume);
  // Pauses/resumes the ambient bed with the app lifecycle.
  WidgetsBinding.instance.addObserver(music);

  // Everything below runs post-launch and never blocks the first frame. Each
  // step is isolated so one plugin failing can't take the others (or the
  // app) down.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await music.initialize();
      music.ensureStarted();
    } catch (e) {
      debugPrint('Music init failed (continuing): $e');
    }
    try {
      await purchases.initialize(initialPremium: economy.premium);
    } catch (e) {
      debugPrint('Purchases init failed (continuing): $e');
    }
    try {
      await ads.initialize(premium: economy.premium);
    } catch (e) {
      debugPrint('Ads init failed (continuing): $e');
    }
    // Offer a Play in-app update if one is available (no-op off Play / on web).
    try {
      await UpdateService().maybePromptUpdate();
    } catch (e) {
      debugPrint('Update check failed (continuing): $e');
    }
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
        Provider.value(value: music),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider.value(value: economy),
        ChangeNotifierProvider.value(value: game),
      ],
      child: const QuotecrackApp(),
    ),
  );
}

/// Shown only if the core dataset fails to load — a last-resort, dependency-
/// free screen so the app is never a blank instant-close.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF161512),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.refresh, color: Color(0xFFD9B25A), size: 48),
                SizedBox(height: 16),
                Text(
                  "Quotecrack couldn't start",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF3EEE2),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Please close the app fully and open it again. If this '
                  'keeps happening, reinstalling will fix it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFC3BBA9), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
