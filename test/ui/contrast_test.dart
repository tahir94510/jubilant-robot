import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:quotecrack/ui/theme/palette.dart';

/// Locks the color system's contrast so a future palette tweak can never
/// quietly drop readable text below WCAG. Ratios are computed from the actual
/// ThemeData each theme ships, for every theme x colorblind x high-contrast
/// combination (12 configurations).
///
/// Standard thresholds: 4.5:1 = WCAG AA for normal text; 3.0:1 = AA for
/// large/secondary text and meaningful icons. In HIGH CONTRAST both floors
/// rise a full tier: 7.0:1 (AAA normal text) and 4.5:1 (AAA large / AA
/// normal), plus a 3.0:1 UI-component floor for the board underline
/// (WCAG 1.4.11) that standard themes deliberately keep decorative.
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

  final themes =
      <
        String,
        ThemeData Function({required bool colorblind, bool highContrast})
      >{
        'light': AppThemes.light,
        'dark': AppThemes.dark,
        'sepia': AppThemes.sepia,
      };

  for (final entry in themes.entries) {
    for (final colorblind in [false, true]) {
      for (final highContrast in [false, true]) {
        final label =
            '${entry.key}'
            '${colorblind ? ' (colorblind)' : ''}'
            '${highContrast ? ' (high contrast)' : ''}';
        // The two floors, one WCAG tier higher in high contrast.
        final normal = highContrast ? 7.0 : 4.5;
        final large = highContrast ? 4.5 : 3.0;
        test('contrast holds in $label', () {
          final t = entry.value(
            colorblind: colorblind,
            highContrast: highContrast,
          );
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

          // Primary readable text + board/keyboard text: the normal-text floor.
          atLeast('onSurface/surface', cs.onSurface, cs.surface, normal);
          atLeast('textSecondary/surface', p.textSecondary, cs.surface, normal);
          atLeast('guessText/surface', p.guessText, cs.surface, normal);
          atLeast('keyText/keyBg', p.keyText, p.keyBg, normal);
          atLeast('onPrimary/primary', cs.onPrimary, cs.primary, normal);

          // Secondary / de-emphasised text + meaningful icons: the large floor.
          atLeast('textFaint/surface', p.textFaint, cs.surface, large);
          // The small cipher letter under each cell is genuinely SMALL text, so it
          // must clear the full normal-text floor, not just the large-text one.
          atLeast('cipherText/surface', p.cipherText, cs.surface, normal);
          atLeast('keyUsedText/keyUsedBg', p.keyUsedText, p.keyUsedBg, large);
          // Locked key glyphs sit on their OWN recessed background and must still
          // stay legible (the earlier translucent treatment read ~1.6:1).
          atLeast(
            'keyDisabledText/keyLockedBg',
            p.keyDisabledText,
            p.keyLockedBg,
            large,
          );

          // Semantic state colors render as the board LETTER over the (near
          // transparent) cell, i.e. over the surface — so they carry meaning as
          // text and must clear the full normal floor, in every theme AND the
          // colorblind variant. This locks the fix for the orange colorblind
          // conflict that read ~2:1 on the cream/sepia paper themes.
          atLeast('conflict/surface', p.conflict, cs.surface, normal);
          atLeast('error/surface', p.error, cs.surface, normal);
          atLeast('revealed/surface', p.revealed, cs.surface, normal);
          // A JUST-REVEALED hint letter (gold) sits briefly on the translucent
          // gold [boardCellRevealedBg] wash; composite it over the surface and
          // confirm the gold letter still clears the large-text floor (the board
          // glyph is bold). This locks the gold-on-gold fix so a future tweak can
          // never let the wash darken back toward the low-contrast gold-on-green.
          atLeast(
            'revealed/revealedWash',
            p.revealed,
            Color.alphaBlend(p.boardCellRevealedBg, cs.surface),
            large,
          );
          atLeast('confirmed/surface', p.confirmed, cs.surface, normal);
          // A JUST-COMPLETED word's letters (green [confirmed]) sit briefly on the
          // green [boardCellLastMoveBg] "just-locked" wash — the green twin of the
          // gold-on-gold case above. Composite the wash over the surface and confirm
          // the green letter still clears the large-text floor, so a future wash
          // tweak can never darken it back toward an unreadable green-on-green.
          atLeast(
            'confirmed/lastMoveWash',
            p.confirmed,
            Color.alphaBlend(p.boardCellLastMoveBg, cs.surface),
            large,
          );
          atLeast('success/surface', p.success, cs.surface, normal);
          // The streak flame accent renders as an icon + large number on the
          // surface and on cards (home/stats), so it must clear the large/icon
          // floor in every theme, not just look good on one.
          atLeast('streakFlame/surface', p.streakFlame, cs.surface, large);

          // Text on CARD surfaces (home/settings tiles, paywall, completion).
          // The card fill differs from the scaffold surface on every theme — on
          // the dark theme a lighter card LOWERS contrast for the light text — so
          // the readable text colors must clear their floor over the card too, not
          // only over the surface.
          final card = t.cardTheme.color!;
          atLeast('onSurface/card', cs.onSurface, card, normal);
          atLeast('textSecondary/card', p.textSecondary, card, normal);
          atLeast('textFaint/card', p.textFaint, card, large);
          // The small cipher letter also appears on card-backed surfaces.
          atLeast('cipherText/card', p.cipherText, card, normal);
          // The streak flame also sits on cards (home streak tile, stats).
          atLeast('streakFlame/card', p.streakFlame, card, large);

          // High contrast promises "stronger borders": the board underline is
          // meaningful structure (it marks where letters go), so it must meet
          // the WCAG 1.4.11 UI-component floor there. Standard themes keep it
          // deliberately decorative, so the check is high-contrast only.
          if (highContrast) {
            atLeast(
              'boardUnderline/surface',
              p.boardUnderline,
              cs.surface,
              3.0,
            );
          }
        });
      }
    }
  }
}
