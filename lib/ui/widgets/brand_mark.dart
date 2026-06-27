import 'package:flutter/material.dart';

/// The Quotecrack logo, drawn with a [CustomPainter] so it is vector-crisp at
/// any size and DPI: a serif Q on the brand gradient, a champagne-gold question
/// mark at its shoulder, and the cryptogram underline beneath.
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
    final radius = size * 0.22;
    // The brand is a light "paper" tile. On the light and sepia themes that
    // tile color is almost identical to the page surface, so without a frame the
    // logo's edge vanishes and it reads as "broken/disappeared". A clearer
    // hairline border plus a two-layer lifted shadow make the mark a distinct,
    // premium raised card on EVERY theme (and cleanly frame the bright tile on
    // dark) — same brand, never blending into the background.
    final borderColor = scheme.onSurface.withValues(alpha: 0.22);
    // Warm, deep-brown shadow rather than pure black: on the cream light/sepia
    // pages a black drop read as a hard grey smudge, the "problematic" look. A
    // warm tint at low alpha melts into the paper as a gentle premium lift, and
    // the hairline frame below does the actual edge separation.
    const shadowColor = Color(0xFF2A2018);
    return Semantics(
      image: true,
      label: 'Quotecrack logo',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              // A soft two-layer "lifted card" shadow: a wide, diffuse ambient
              // halo plus a slightly tighter contact shadow. Kept low-alpha and
              // warm so it reads as a refined raised card on EVERY surface —
              // including the light/sepia pages whose color nearly matches the
              // tile — without the harsh hard-edged drop of the old version.
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.10),
                blurRadius: size * 0.20,
                offset: Offset(0, size * 0.05),
              ),
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.13),
                blurRadius: size * 0.085,
                offset: Offset(0, size * 0.04),
                spreadRadius: -size * 0.02,
              ),
            ],
          ),
          child: CustomPaint(painter: _BrandPainter(borderColor: borderColor)),
        ),
      ),
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter({required this.borderColor});

  /// Theme-derived hairline frame color so the tile edge reads on any surface.
  final Color borderColor;

  // "Ink & Gold" on a warm PAPER field: a light champagne-cream gradient tile,
  // a dark-ink serif Q, a deepened bronze-gold question mark at its shoulder,
  // and a slim deep-gold underline. Matches the light app icon
  // (tool/generate_icons.py); the gold is deepened so it keeps contrast on the
  // light field instead of washing out.
  static const _gradientSheen = Color(0xFFFCFAF3);
  static const _gradientTop = Color(0xFFF7F4EC);
  static const _gradientBottom = Color(0xFFEAE1CE);
  static const _ink = Color(0xFF26221C);
  static const _gold = Color(0xFFAA7C22);
  static const _underline = Color(0xFF966E1E);

  TextPainter _glyph(String ch, double fontSize, int weight, Color color) {
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
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(s * 0.22),
    );

    // Gradient tile, clipped to the rounded square — matches the app icon.
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          // A subtle near-white sheen at the top fading into the warm cream:
          // soft "light from above" that gives the tile premium dimension.
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradientSheen, _gradientTop, _gradientBottom],
          stops: [0.0, 0.4, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Q: box centred at (0.44, 0.42) like the icon. Its box bottom lands near
    // 0.70s, comfortably above the underline at 0.80s.
    final q = _glyph('Q', s * 0.56, 600, _ink);
    q.paint(canvas, Offset(s * 0.44 - q.width / 2, s * 0.42 - q.height / 2));

    // Question mark at the shoulder (no descender, so no clearance worry).
    final mark = _glyph('?', s * 0.235, 700, _gold);
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
      Paint()..color = _underline,
    );
    canvas.restore();

    // Hairline frame, drawn AFTER the clip is lifted so the stroke isn't halved
    // — keeps the tile's rounded edge visible on light/sepia where tile ≈ page.
    final stroke = s * 0.012;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(stroke / 2),
        Radius.circular(s * 0.22 - stroke / 2),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
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
