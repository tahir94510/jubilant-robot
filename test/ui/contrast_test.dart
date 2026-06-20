import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:quotecrack/ui/theme/palette.dart';

/// Locks the color system's contrast so a future palette tweak can never
/// quietly drop readable text below WCAG. Ratios are computed from the actual
/// ThemeData each theme ships, for every theme x colorblind combination.
///
/// Thresholds: 4.5:1 = WCAG AA for normal text; 3.0:1 = AA for large/secondary
/// text and meaningful icons.
void main() {
  double channel(double c) {
    final s = c / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4) as double;
  }

  double luminance(Color c) {
    // Colors here are opaque; the values tested are never translucent.
    final r = channel((c.r * 255).roundToDouble());
    final g = channel((c.g * 255).roundToDouble());
    final b = channel((c.b * 255).roundToDouble());
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double ratio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  final themes = <String, ThemeData Function({required bool colorblind})>{
    'light': AppThemes.light,
    'dark': AppThemes.dark,
    'sepia': AppThemes.sepia,
  };

  for (final entry in themes.entries) {
    for (final colorblind in [false, true]) {
      final label = '${entry.key}${colorblind ? ' (colorblind)' : ''}';
      test('contrast holds in $label', () {
        final t = entry.value(colorblind: colorblind);
        final cs = t.colorScheme;
        final p = t.extension<GamePalette>()!;

        void atLeast(String what, Color fg, Color bg, double min) {
          final r = ratio(fg, bg);
          expect(
            r,
            greaterThanOrEqualTo(min),
            reason: '$label: $what contrast ${r.toStringAsFixed(2)} < $min',
          );
        }

        // Primary readable text + board/keyboard text: full AA.
        atLeast('onSurface/surface', cs.onSurface, cs.surface, 4.5);
        atLeast('textSecondary/surface', p.textSecondary, cs.surface, 4.5);
        atLeast('guessText/surface', p.guessText, cs.surface, 4.5);
        atLeast('keyText/keyBg', p.keyText, p.keyBg, 4.5);
        atLeast('onPrimary/primary', cs.onPrimary, cs.primary, 4.5);

        // Secondary / de-emphasised text + meaningful icons: large-text AA.
        atLeast('textFaint/surface', p.textFaint, cs.surface, 3.0);
        atLeast('cipherText/surface', p.cipherText, cs.surface, 3.0);
        atLeast('keyUsedText/keyUsedBg', p.keyUsedText, p.keyUsedBg, 3.0);
      });
    }
  }
}
