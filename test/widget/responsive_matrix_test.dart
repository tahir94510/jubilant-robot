import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/quote.dart';
import 'package:quotecrack/ui/screens/home_screen.dart';
import 'package:quotecrack/ui/screens/packs_screen.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';
import 'package:quotecrack/ui/screens/stats_screen.dart';

import '../fakes/test_harness.dart';

/// Responsive stress matrix: every key screen must lay out WITHOUT a single
/// overflow on the smallest mainstream phone (320dp wide) at the largest
/// in-app text size (1.6x), in the longest-string locale (German) — and the
/// puzzle screen additionally under the widest keyboard (Turkish, 29 letters).
/// Flutter reports RenderFlex overflows as test exceptions, so a squeezed,
/// broken layout can never ship silently.
void main() {
  // A deliberately nasty board: near the 180-char dataset cap with a long word
  // ("generalizations"-class), so the fit math is exercised at its floor.
  final longQuote = Quote(
    id: 'stress-001',
    text:
        'Extraordinary accomplishments demand uncomfortable generalizations, '
        'relentless perseverance and unshakeable determination throughout.',
    author: 'Stress Fixture',
    source: 'Responsive matrix',
    category: 'wisdom',
  );

  final sizes = <String, Size>{
    // Logical dp; dpr 3 keeps the physical size realistic for small phones.
    '320x568': const Size(320, 568),
    '412x732': const Size(412, 732),
  };
  final scales = [1.0, 1.6];

  Future<void> pumpAt(
    WidgetTester t,
    Size logical,
    double scale,
    String locale,
    Widget screen, {
    void Function(Harness)? setup,
  }) async {
    t.view.physicalSize = logical * 3;
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);
    final h = await Harness.create(quotes: [shortQuote, longQuote]);
    setup?.call(h);
    await t.pumpWidget(h.app(screen, textScale: scale, locale: Locale(locale)));
    await t.pump(const Duration(milliseconds: 400));
    if (setup != null) h.game.stopTimer();
  }

  for (final size in sizes.entries) {
    for (final scale in scales) {
      final label = '${size.key} @${scale}x';
      testWidgets('home lays out clean on $label (de)', (t) async {
        await pumpAt(t, size.value, scale, 'de', const HomeScreen());
      });
      testWidgets('settings lays out clean on $label (de)', (t) async {
        await pumpAt(t, size.value, scale, 'de', const SettingsScreen());
      });
      testWidgets('paywall lays out clean on $label (de)', (t) async {
        await pumpAt(t, size.value, scale, 'de', const PaywallScreen());
      });
      testWidgets('packs lays out clean on $label (de)', (t) async {
        await pumpAt(t, size.value, scale, 'de', const PacksScreen());
      });
      // German has the longest stat labels (two-line wraps) — the exact case
      // the fixed-slot stat cards must absorb without overflow or misalign.
      testWidgets('stats lays out clean on $label (de)', (t) async {
        await pumpAt(t, size.value, scale, 'de', const StatsScreen());
      });
      testWidgets('stats lays out clean on $label (tr)', (t) async {
        await pumpAt(t, size.value, scale, 'tr', const StatsScreen());
      });
      testWidgets('long-quote puzzle lays out clean on $label (de)', (t) async {
        await pumpAt(
          t,
          size.value,
          scale,
          'de',
          const PuzzleScreen(),
          setup: (h) => h.game.start(longQuote, daily: false),
        );
      });
      testWidgets('puzzle + 29-letter keyboard lays out on $label (tr)', (
        t,
      ) async {
        // Turkish: the widest on-screen keyboard (29 letters) is the
        // sharpest key-width squeeze the app can face.
        await pumpAt(
          t,
          size.value,
          scale,
          'tr',
          const PuzzleScreen(),
          setup: (h) => h.game.start(shortQuote, daily: false),
        );
      });
    }
  }
}
