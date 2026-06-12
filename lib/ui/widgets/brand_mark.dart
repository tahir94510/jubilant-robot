import 'package:flutter/material.dart';

/// The Quotecrack logo drawn with pure widgets — the same geometry as the
/// generated app icon (tool/generate_icons.py), so it is vector-crisp at
/// any size and DPI: a serif Q on the brand gradient, a coral question
/// mark at its shoulder, and the cryptogram underline beneath.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  static const _gradientTop = Color(0xFF1C2541);
  static const _gradientBottom = Color(0xFF3D5A80);
  static const _paper = Color(0xFFF7F5F0);
  static const _coral = Color(0xFFEE6C4D);
  static const _underline = Color(0xFF98C1D9);

  @override
  Widget build(BuildContext context) {
    // Brand text is part of the artwork: it must not scale with system text.
    final lineHeight = size * 0.055;
    return Semantics(
      image: true,
      label: 'Quotecrack logo',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.176),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_gradientTop, _gradientBottom],
            ),
          ),
          child: Stack(
            children: [
              // Fractional centers mirror the icon generator: Q at
              // (0.42, 0.44), ? at (0.78, 0.28), underline at y 0.82.
              Align(
                alignment: const Alignment(-0.16, -0.30),
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: size * 0.52,
                    height: 1,
                    color: _paper,
                  ),
                  textScaler: TextScaler.noScaling,
                ),
              ),
              Align(
                alignment: const Alignment(0.56, -0.60),
                child: Text(
                  '?',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontVariations: const [FontVariation('wght', 700)],
                    fontSize: size * 0.23,
                    height: 1,
                    color: _coral,
                  ),
                  textScaler: TextScaler.noScaling,
                ),
              ),
              Positioned(
                left: size * 0.16,
                right: size * 0.16,
                top: size * 0.82 - lineHeight / 2,
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
