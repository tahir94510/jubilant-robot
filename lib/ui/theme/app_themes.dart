import 'package:flutter/material.dart';

import '../../models/app_settings.dart';
import 'page_transitions.dart';
import 'palette.dart';

/// Three handcrafted themes. UI text is Inter; quotes render in Lora
/// (set per-widget). The sepia theme is the "reading lamp" mode word-puzzle
/// players love.
abstract final class AppThemes {
  static const String uiFont = 'Inter';
  static const String quoteFont = 'Lora';

  static ThemeData light({required bool colorblind}) {
    const surface = Color(0xFFF7F5F0);
    const onSurface = Color(0xFF23262B);
    const primary = Color(0xFF3D5A80);
    return _base(
      brightness: Brightness.light,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: Colors.white,
      cardColor: Colors.white,
      palette: GamePalette.light(colorblind: colorblind),
    );
  }

  static ThemeData dark({required bool colorblind}) {
    const surface = Color(0xFF15181E);
    const onSurface = Color(0xFFECEFF4);
    const primary = Color(0xFF98C1D9);
    return _base(
      brightness: Brightness.dark,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: const Color(0xFF15181E),
      cardColor: const Color(0xFF1F242C),
      palette: GamePalette.dark(colorblind: colorblind),
    );
  }

  static ThemeData sepia({required bool colorblind}) {
    const surface = Color(0xFFF4EBDC);
    const onSurface = Color(0xFF42351F);
    const primary = Color(0xFF8B5E34);
    return _base(
      brightness: Brightness.light,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: Colors.white,
      cardColor: const Color(0xFFFBF3E4),
      palette: GamePalette.sepia(colorblind: colorblind),
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color surface,
    required Color onSurface,
    required Color primary,
    required Color onPrimary,
    required Color cardColor,
    required GamePalette palette,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: onPrimary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: uiFont,
      scaffoldBackgroundColor: surface,
    );
    return base.copyWith(
      extensions: [palette],
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const FadeThroughPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: uiFont,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: onSurface.withValues(alpha: .07)),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: uiFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: .08),
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Defense-in-depth: the reminder picker opens input-only, but if a
      // dial ever becomes reachable it should match the app's look.
      timePickerTheme: TimePickerThemeData(
        backgroundColor: cardColor,
        dialHandColor: primary,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData resolve(
    AppThemeMode mode, {
    required bool colorblind,
    required Brightness platformBrightness,
  }) {
    return switch (mode) {
      AppThemeMode.light => light(colorblind: colorblind),
      AppThemeMode.dark => dark(colorblind: colorblind),
      AppThemeMode.sepia => sepia(colorblind: colorblind),
      AppThemeMode.system =>
        platformBrightness == Brightness.dark
            ? dark(colorblind: colorblind)
            : light(colorblind: colorblind),
    };
  }
}
