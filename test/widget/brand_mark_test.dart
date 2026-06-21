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
}
