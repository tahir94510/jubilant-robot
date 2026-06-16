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
    return Semantics(
      image: true,
      label: 'Quotecrack logo',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(painter: _BrandPainter()),
        ),
      ),
    );
  }
}

class _BrandPainter extends CustomPainter {
  // "Ink & Gold" brand: a warm-ink gradient tile, an ivory serif Q, a
  // champagne-gold question mark at its shoulder, and a slim gold underline.
  static const _gradientTop = Color(0xFF1A1814);
  static const _gradientBottom = Color(0xFF2E2A22);
  static const _paper = Color(0xFFF3EEE2);
  static const _gold = Color(0xFFE0B85A);
  static const _underline = Color(0xFFCBA24E);

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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientTop, _gradientBottom],
        ).createShader(Offset.zero & size),
    );

    // Q: box centred at (0.44, 0.42) like the icon. Its box bottom lands near
    // 0.70s, comfortably above the underline at 0.80s.
    final q = _glyph('Q', s * 0.56, 600, _paper);
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
  }

  @override
  bool shouldRepaint(_BrandPainter oldDelegate) => false;
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
