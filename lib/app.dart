import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'l10n/app_localizations.dart';
import 'services/music_service.dart';
import 'state/settings_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/theme/app_themes.dart';

class QuotecrackApp extends StatelessWidget {
  const QuotecrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().settings;
    final music = context.read<MusicService>();
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // null follows the device locale; a saved choice overrides it.
      locale: settings.languageCode == null
          ? null
          : Locale(settings.languageCode!),
      theme: AppThemes.resolve(
        settings.themeMode,
        colorblind: settings.colorblindMode,
        platformBrightness: platformBrightness,
      ),
      builder: (context, child) {
        // Combine the user's in-app text-size choice with the OS setting,
        // clamped so the board always stays playable.
        final mq = MediaQuery.of(context);
        final combined = mq.textScaler
            .scale(settings.textScale)
            .clamp(0.85, 1.6);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(combined)),
          // Browsers only allow audio after a user gesture, so the music
          // bed re-attempts on taps until one sticks (no-op once playing,
          // and on Android, where the post-frame start already succeeded).
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => music.ensureStarted(),
            child: child!,
          ),
        );
      },
      home: settings.onboardingDone
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
