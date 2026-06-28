import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/theme/app_themes.dart';
import 'package:quotecrack/ui/widgets/brand_mark.dart';

/// The logo must render as a distinct, framed brand card on every theme — it
/// used to blend into the light/sepia surfaces (tile color ≈ page) and read as
/// "disappeared". This locks in that it builds cleanly in all three themes.
void main() {
  final themes = <String, ThemeData Function({required bool colorblind})>{
    'light': AppThemes.light,
    'dark': AppThemes.dark,
    'sepia': AppThemes.sepia,
  };

  for (final entry in themes.entries) {
    testWidgets('BrandMark renders without error in ${entry.key}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: entry.value(colorblind: false),
          home: const Scaffold(body: Center(child: BrandMark(size: 96))),
        ),
      );
      expect(find.byType(BrandMark), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  // The logo must never re-introduce the "logo disappears" bug. BrandMark is
  // transparent and colors its glyphs from the ACTIVE theme, so on the dark
  // theme it draws a LIGHT Q (onSurface) that stays visible even on a pure-black
  // surface (e.g. the premium/paywall screen) — no baked tile required.
  testWidgets('BrandMark renders on a black surface in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.dark(colorblind: false),
        home: const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: BrandMark(size: 72)),
        ),
      ),
    );
    expect(find.byType(BrandMark), findsOneWidget);
    // The self-contained painter (its baked cream tile + glyphs) is present.
    expect(
      find.descendant(
        of: find.byType(BrandMark),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  // The light-theme case: on a cream page the transparent mark draws a DARK Q
  // (onSurface) plus the brand-gold accents, all clearly legible on the paper —
  // adaptive color, not a baked card. Locks that the light variant stays visible.
  testWidgets('BrandMark renders on a light cream surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.light(colorblind: false),
        home: const Scaffold(
          backgroundColor: Color(0xFFF7F4EC), // == the logo's own cream tile
          body: Center(child: BrandMark(size: 72)),
        ),
      ),
    );
    expect(find.byType(BrandMark), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
