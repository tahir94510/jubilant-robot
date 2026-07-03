import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/config/app_config.dart';
import 'package:quotecrack/services/ads/interstitial_policy.dart';
import 'package:quotecrack/services/storage_service.dart';
import 'package:quotecrack/state/economy_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_services.dart';

Future<(EconomyController, FakePurchaseService, FakeAdsService)>
_setup() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.init();
  final purchases = FakePurchaseService();
  final ads = FakeAdsService();
  final economy = EconomyController(
    storage: storage,
    purchases: purchases,
    ads: ads,
  );
  return (economy, purchases, ads);
}

void main() {
  group('hint economy', () {
    test('a hint is never granted without a watched ad (no free fallback)', () {
      // Production economy policy: the rewarded button enables only while a real
      // ad is loaded, so a reward is impossible without watching one — and
      // offline shows a disabled button, never a free hint. This constant pins
      // that guarantee so the old closed-test fallback can never ship by accident.
      expect(AppConfig.grantHintsWithoutAd, isFalse);
    });

    test('starts with the configured stock', () async {
      final (economy, _, _) = await _setup();
      expect(economy.tokens, AppConfig.startingHintTokens);
    });

    test('spend decrements and floors at zero', () async {
      final (economy, _, _) = await _setup();
      for (var i = 0; i < AppConfig.startingHintTokens; i++) {
        expect(economy.spendHintToken(), isTrue);
      }
      expect(economy.tokens, 0);
      expect(economy.spendHintToken(), isFalse);
      expect(economy.tokens, 0);
    });

    test('spendHintTokens is all-or-nothing (word-reveal pricing)', () async {
      final (economy, purchases, _) = await _setup();
      final start = economy.tokens;

      // Affordable multi-spend decrements exactly the asked amount.
      expect(economy.spendHintTokens(3), isTrue);
      expect(economy.tokens, start - 3);

      // Unaffordable spend changes NOTHING — never a partial charge.
      expect(economy.spendHintTokens(economy.tokens + 1), isFalse);
      expect(economy.tokens, start - 3);

      // Premium never decrements, whatever the count.
      purchases.owned.value = true;
      final before = economy.tokens;
      expect(economy.spendHintTokens(99), isTrue);
      expect(economy.tokens, before);
    });

    test('solving earns tokens and advances the counter', () async {
      final (economy, _, _) = await _setup();
      final before = economy.tokens;
      economy.onPuzzleCompleted();
      expect(economy.tokens, before + AppConfig.tokensPerSolve);
      expect(economy.completedCount, 1);
    });

    test('rewarded ad grants exactly the configured amount', () async {
      final (economy, _, _) = await _setup();
      final before = economy.tokens;
      economy.grantRewardedTokens();
      expect(economy.tokens, before + AppConfig.tokensPerRewardedAd);
    });

    test('premium never decrements and disables ads', () async {
      final (economy, purchases, ads) = await _setup();
      purchases.owned.value = true; // simulate purchase completing
      await Future<void>.delayed(Duration.zero);

      expect(economy.premium, isTrue);
      expect(ads.disabled, isTrue);
      final before = economy.tokens;
      expect(economy.spendHintToken(), isTrue);
      expect(economy.tokens, before);
    });

    test('premium flag survives a restart via the local cache', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final purchases = FakePurchaseService();
      final ads = FakeAdsService();
      final e1 = EconomyController(
        storage: storage,
        purchases: purchases,
        ads: ads,
      );
      purchases.owned.value = true;
      await Future<void>.delayed(Duration.zero);
      expect(e1.premium, isTrue);

      final e2 = EconomyController(
        storage: storage,
        purchases: FakePurchaseService(),
        ads: ads,
      );
      expect(e2.premium, isTrue, reason: 'cached flag must persist');
    });

    test('tokens persist across restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final e1 = EconomyController(
        storage: storage,
        purchases: FakePurchaseService(),
        ads: FakeAdsService(),
      );
      e1.spendHintToken();
      e1.spendHintToken();
      final remaining = e1.tokens;

      final e2 = EconomyController(
        storage: storage,
        purchases: FakePurchaseService(),
        ads: FakeAdsService(),
      );
      expect(e2.tokens, remaining);
    });
  });

  group('InterstitialPolicy', () {
    const policy = InterstitialPolicy();
    final now = DateTime(2026, 6, 11, 12);

    test('fires only on every Nth completion', () {
      final n = AppConfig.interstitialEveryNSolves;
      for (var count = 1; count <= n * 3; count++) {
        final expected = count % n == 0;
        expect(
          policy.shouldShow(completedCount: count, lastShownAt: null, now: now),
          expected,
          reason: 'count=$count',
        );
      }
    });

    test('respects the cooldown window', () {
      final n = AppConfig.interstitialEveryNSolves;
      final justNow = now.subtract(const Duration(seconds: 10));
      expect(
        policy.shouldShow(completedCount: n, lastShownAt: justNow, now: now),
        isFalse,
      );
      final longAgo = now.subtract(
        AppConfig.interstitialCooldown + const Duration(seconds: 1),
      );
      expect(
        policy.shouldShow(completedCount: n, lastShownAt: longAgo, now: now),
        isTrue,
      );
    });

    test('never fires for zero or negative counts', () {
      expect(
        policy.shouldShow(completedCount: 0, lastShownAt: null, now: now),
        isFalse,
      );
    });
  });
}
