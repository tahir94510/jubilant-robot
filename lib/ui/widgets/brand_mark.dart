import 'package:flutter/material.dart';

/// The Quotecrack logo drawn with pure widgets — the same geometry as the
/// generated app icon (tool/generate_icons.py), so it is vector-crisp at
/// any size and DPI: a serif Q on the brand gradient, a coral question
/// mark at its shoulder, and the cryptogram underline beneath.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  // "Ink & Gold" brand: a warm-ink gradient tile, an ivory serif Q, a
  // champagne-gold question mark at its shoulder, and a slim gold underline.
  static const _gradientTop = Color(0xFF1A1814);
  static const _gradientBottom = Color(0xFF2E2A22);
  static const _paper = Color(0xFFF3EEE2);
  static const _gold = Color(0xFFE0B85A);
  static const _underline = Color(0xFFCBA24E);

  @override
  Widget build(BuildContext context) {
    // Brand text is part of the artwork: it must not scale with system text.
    final lineHeight = size * 0.05;
    return Semantics(
      image: true,
      label: 'Quotecrack logo',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          // Clip glyphs to the rounded tile exactly like the generated icon.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gradientTop, _gradientBottom],
            ),
          ),
          child: Stack(
            children: [
              // Font sizes and centres mirror the icon generator
              // (tool/generate_icons.py). The Q is lifted (y -0.16) and sized
              // down (0.56) and the underline pushed to y 0.87 so the serif
              // Q's tail keeps a clear optical gap above the bar instead of
              // fusing into it.
              Align(
                alignment: const Alignment(-0.12, -0.16),
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontVariations: const [FontVariation('wght', 600)],
                    fontSize: size * 0.56,
                    height: 1,
                    color: _paper,
                  ),
                  textScaler: TextScaler.noScaling,
                ),
              ),
              Align(
                alignment: const Alignment(0.52, -0.42),
                child: Text(
                  '?',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: size * 0.235,
                    height: 1,
                    color: _gold,
                  ),
                  textScaler: TextScaler.noScaling,
                ),
              ),
              Positioned(
                left: size * 0.20,
                right: size * 0.20,
                top: size * 0.87 - lineHeight / 2,
                height: lineHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _underline,
                    borderRadius: BorderRadius.circular(lineHeight / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
