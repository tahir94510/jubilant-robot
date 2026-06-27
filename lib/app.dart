import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'l10n/app_localizations.dart';
import 'services/haptics_service.dart';
import 'services/music_service.dart';
import 'state/settings_controller.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/theme/app_themes.dart';
import 'ui/widgets/haptic_route_observer.dart';

class QuotecrackApp extends StatefulWidget {
  const QuotecrackApp({super.key});

  @override
  State<QuotecrackApp> createState() => _QuotecrackAppState();
}

class _QuotecrackAppState extends State<QuotecrackApp> {
  // A single, stable observer for the app's lifetime: it gives every screen
  // transition, bottom sheet and dialog the same settings-gated tap haptic the
  // puzzle already has. Created once (not per build) so theme/locale rebuilds
  // never churn the Navigator's observer list.
  late final HapticRouteObserver _hapticObserver = HapticRouteObserver(
    context.read<HapticsService>(),
  );

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().settings;
    final music = context.read<MusicService>();
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final theme = AppThemes.resolve(
      settings.themeMode,
      colorblind: settings.colorblindMode,
      platformBrightness: platformBrightness,
    );
    // Edge-to-edge: transparent status + navigation bars with icon brightness
    // matched to the active theme, so the system bars blend into the app and
    // their icons stay legible in light, dark and sepia. Contrast enforcement
    // is off so Android doesn't paint a grey scrim behind the nav bar.
    final isLight = theme.brightness == Brightness.light;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isLight
          ? Brightness.dark
          : Brightness.light,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    );

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_hapticObserver],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // null follows the device locale; a saved choice overrides it.
      locale: settings.languageCode == null
          ? null
          : Locale(settings.languageCode!),
      theme: theme,
      builder: (context, child) {
        // Combine the user's in-app text-size choice with the OS setting,
        // clamped so the board always stays playable.
        final mq = MediaQuery.of(context);
        final combined = mq.textScaler
            .scale(settings.textScale)
            .clamp(0.85, 1.6);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(combined)),
          // Apply the transparent, theme-matched system-bar style app-wide.
          // Screens with an AppBar still set their own status-bar style; this
          // governs the navigation bar everywhere and the status bar on
          // AppBar-less screens (e.g. Home).
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            // Browsers only allow audio after a user gesture, so the music
            // bed re-attempts on taps until one sticks (no-op once playing,
            // and on Android, where the post-frame start already succeeded).
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => music.ensureStarted(),
              child: child!,
            ),
          ),
        );
      },
      home: settings.onboardingDone
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
