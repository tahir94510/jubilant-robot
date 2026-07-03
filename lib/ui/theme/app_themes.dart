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

  static ThemeData light({
    required bool colorblind,
    bool highContrast = false,
  }) {
    // Warm ivory "paper", deep ink text, antique-gold primary. High contrast
    // deepens the gold so off-white button text clears AAA (7.20:1, was 4.9).
    const surface = Color(0xFFF7F4EC);
    const onSurface = Color(0xFF211E1A);
    final primary = highContrast
        ? const Color(0xFF6D5217)
        : const Color(0xFF936F1F);
    return _base(
      brightness: Brightness.light,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: const Color(0xFFFFFDF8),
      cardColor: const Color(0xFFFFFDF8),
      highContrast: highContrast,
      palette: GamePalette.light(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
    );
  }

  static ThemeData dark({required bool colorblind, bool highContrast = false}) {
    // Deep warm "ink" charcoal, ivory text, champagne-gold primary. The gold
    // already reads 9.1:1 over the ink onPrimary, so high contrast keeps it.
    const surface = Color(0xFF161512);
    const onSurface = Color(0xFFF2EDE2);
    const primary = Color(0xFFD9B25A);
    return _base(
      brightness: Brightness.dark,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: const Color(0xFF161512),
      cardColor: const Color(0xFF211F1A),
      highContrast: highContrast,
      palette: GamePalette.dark(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
    );
  }

  static ThemeData sepia({
    required bool colorblind,
    bool highContrast = false,
  }) {
    const surface = Color(0xFFF4EBDC);
    const onSurface = Color(0xFF3A2E1C);
    // Deepened from 0xFF9C7B33 so off-white button text on the gold primary
    // clears WCAG AA (4.95:1, was 3.90); also lifts every primary-on-surface
    // accent's contrast in sepia. High contrast deepens further to AAA (7.14).
    final primary = highContrast
        ? const Color(0xFF6C531F)
        : const Color(0xFF8A6A28);
    return _base(
      brightness: Brightness.light,
      surface: surface,
      onSurface: onSurface,
      primary: primary,
      onPrimary: const Color(0xFFFFFDF8),
      cardColor: const Color(0xFFFBF3E4),
      highContrast: highContrast,
      palette: GamePalette.sepia(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
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
    bool highContrast = false,
  }) {
    // The roadmap's "stronger borders": hairlines that are decorative at .07
    // become clearly visible structure in high contrast.
    final outlineAlpha = highContrast ? .30 : .07;
    final dividerAlpha = highContrast ? .30 : .08;
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
          side: BorderSide(color: onSurface.withValues(alpha: outlineAlpha)),
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
        color: onSurface.withValues(alpha: dividerAlpha),
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
    bool highContrast = false,
  }) {
    return switch (mode) {
      AppThemeMode.light => light(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
      AppThemeMode.dark => dark(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
      AppThemeMode.sepia => sepia(
        colorblind: colorblind,
        highContrast: highContrast,
      ),
      AppThemeMode.system =>
        platformBrightness == Brightness.dark
            ? dark(colorblind: colorblind, highContrast: highContrast)
            : light(colorblind: colorblind, highContrast: highContrast),
    };
  }
}
