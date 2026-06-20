import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/models/pack.dart';
import 'package:quotecrack/ui/screens/paywall_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/widgets/banner_ad_slot.dart';
import 'package:quotecrack/ui/widgets/hint_bar.dart';

import '../fakes/test_harness.dart';

void main() {
  testWidgets('premium hides banner ads', (tester) async {
    final h = await Harness.create(premium: true);
    expect(h.economy.premium, isTrue);

    await tester.pumpWidget(h.app(const BannerAdSlot(slotName: 'test')));
    await tester.pump();

    // The slot renders nothing for premium owners.
    expect(find.byKey(const ValueKey('banner-test')), findsNothing);
  });

  testWidgets('free users get a banner from the (fake) ads service', (
    tester,
  ) async {
    final h = await Harness.create();

    await tester.pumpWidget(h.app(const BannerAdSlot(slotName: 'test')));
    await tester.pump();

    expect(find.byKey(const ValueKey('banner-test')), findsOneWidget);
  });

  testWidgets('premium hint bar shows no token count and no rewarded button', (
    tester,
  ) async {
    final h = await Harness.create(premium: true);
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    expect(find.text('Reveal letter'), findsOneWidget);
    expect(find.textContaining('+3'), findsNothing);

    // Unlimited: spending does not decrement.
    final before = h.economy.tokens;
    await tester.tap(find.text('Reveal letter'));
    await tester.pump();
    expect(h.economy.tokens, before);

    h.game.stopTimer();
  });

  testWidgets('free hint bar shows rewarded button that grants tokens', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final before = h.economy.tokens;
    await tester.tap(
      find.descendant(
        of: find.byType(HintBar),
        matching: find.textContaining('+3'),
      ),
    );
    await tester.pump();

    expect(h.ads.rewardedShown, 1);
    expect(h.economy.tokens, before + 3);

    h.game.stopTimer();
  });

  testWidgets('paywall buys premium through the purchase service', (
    tester,
  ) async {
    final h = await Harness.create();

    await tester.pumpWidget(h.app(const PaywallScreen()));
    await tester.pump();

    await tester.tap(find.textContaining('Unlock Premium'));
    await tester.pump();

    expect(h.purchases.buyCalls, 1);
    expect(h.economy.premium, isTrue);
    expect(h.ads.disabled, isTrue);
  });

  test('premium packs are flagged in the catalog', () {
    final premiumPacks = Pack.catalog
        .where((p) => p.premiumOnly)
        .map((p) => p.id)
        .toSet();
    expect(premiumPacks, {'classics', 'inspire'});
  });
}
