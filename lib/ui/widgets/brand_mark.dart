import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// The Quotecrack logo, drawn with a [CustomPainter] so it is vector-crisp at
/// any size and DPI: a serif Q, a champagne-gold question mark at its shoulder,
/// and the cryptogram underline beneath.
///
/// TRANSPARENT background + THEME-ADAPTIVE colors. The Q takes the active
/// theme's [ColorScheme.onSurface] and the ? / underline take the theme's brand
/// gold ([GamePalette.revealed], which is tuned to clear WCAG AA on every
/// theme's surface), so the mark always reads with strong contrast on whatever
/// surface it sits on — light, dark or sepia — with no baked tile that could
/// clash with the page. The colors come from the ACTIVE app theme (never the
/// device), so a light-themed app on a dark device still shows the light mark
/// and can never "disappear" by drawing a light glyph on a light page or vice
/// versa.
///
/// Why a painter and not stacked [Align]s: the generated app icon
/// (tool/generate_icons.py) centres each glyph by its *ink box*, but `Align`
/// centres the *line box* (font ascent/descent included), which dropped the
/// serif Q lower than in the icon and let its tail fuse into the underline.
/// Here the underline is positioned strictly below the Q's layout box, so the
/// descender can never reach it — at size 24 or 240.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Semantics(
      image: true,
      label: 'Quotecrack logo',
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            // Glyph in the theme's text color, accents in the theme's brand
            // gold: a transparent, fully theme-matched mark.
            painter: _BrandPainter(
              glyph: scheme.onSurface,
              gold: palette.revealed,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter({required this.glyph, required this.gold});

  /// The serif Q — the theme's onSurface, so it reads on any surface/theme.
  final Color glyph;

  /// The ? and underline — the theme's brand gold (AA-contrast per theme).
  final Color gold;

  TextPainter _glyphTp(String ch, double fontSize, int weight, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: ch,
        style: TextStyle(
          fontFamily: 'Lora',
          fontVariations: [FontVariation('wght', weight.toDouble())],
          fontSize: fontSize,
          height: 1,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling, // the logo is artwork, never scaled
    )..layout();
    return tp;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    // Q: box centred at (0.44, 0.42) like the icon. Its box bottom lands near
    // 0.70s, comfortably above the underline at 0.80s.
    final q = _glyphTp('Q', s * 0.56, 600, glyph);
    q.paint(canvas, Offset(s * 0.44 - q.width / 2, s * 0.42 - q.height / 2));

    // Question mark at the shoulder (no descender, so no clearance worry).
    final mark = _glyphTp('?', s * 0.235, 700, gold);
    mark.paint(
      canvas,
      Offset(s * 0.76 - mark.width / 2, s * 0.30 - mark.height / 2),
    );

    // The cryptogram underline: a slim rounded bar, always clear of the Q.
    final lineH = s * 0.05;
    final lineY = s * 0.80;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.20, lineY - lineH / 2, s * 0.80, lineY + lineH / 2),
        Radius.circular(lineH / 2),
      ),
      Paint()..color = gold,
    );
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) =>
      oldDelegate.glyph != glyph || oldDelegate.gold != gold;
}

/// The serif wordmark. Kept as a literal Text('Quotecrack') — tests and
/// accessibility both read the brand by name.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 26, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Quotecrack',
      style: TextStyle(
        fontFamily: 'Lora',
        fontVariations: const [FontVariation('wght', 600)],
        fontSize: fontSize,
        letterSpacing: -0.5,
        height: 1.1,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
