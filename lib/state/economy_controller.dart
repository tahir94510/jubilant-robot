import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../services/ads/ads_service.dart';
import '../services/purchases/purchase_service.dart';
import '../services/storage_service.dart';

/// Owns hint tokens and the premium flag.
///
/// Listens to [PurchaseService.premiumOwned]; when premium flips on it
/// permanently disables ads and caches the flag locally so the next launch
/// starts ad-free before the store even responds.
class EconomyController extends ChangeNotifier {
  EconomyController({
    required StorageService storage,
    required PurchaseService purchases,
    required AdsService ads,
  }) : _storage = storage,
       _purchases = purchases,
       _ads = ads {
    final saved = storage.readJson(StorageService.economyKey);
    _tokens = saved?['tokens'] as int? ?? AppConfig.startingHintTokens;
    _premium = saved?['premium'] as bool? ?? false;
    _completedCount = saved?['completedCount'] as int? ?? 0;

    _purchases.premiumOwned.addListener(_onPremiumChanged);
    // Pick up a purchase that was already owned before we attached (e.g.
    // the store responded before this controller was constructed).
    _onPremiumChanged();
  }

  final StorageService _storage;
  final PurchaseService _purchases;
  final AdsService _ads;

  int _tokens = AppConfig.startingHintTokens;
  bool _premium = false;
  int _completedCount = 0;

  int get tokens => _tokens;
  bool get premium => _premium;

  /// Lifetime completed-puzzle counter driving interstitial cadence.
  int get completedCount => _completedCount;

  bool get canUseHint => _premium || _tokens > 0;

  void _onPremiumChanged() {
    if (_purchases.premiumOwned.value && !_premium) {
      _premium = true;
      // Persist the entitlement BEFORE the async ad-disable so a crash in the
      // gap can't lose it (which would re-show ads next launch); the cached flag
      // also makes the next startup ad-free before the store even responds.
      _persist();
      _ads.disable();
      notifyListeners();
    }
  }

  /// Spends one token for a reveal. Returns false when broke (and not
  /// premium). Premium never decrements.
  bool spendHintToken() {
    if (_premium) return true;
    if (_tokens <= 0) return false;
    _tokens -= 1;
    _persist();
    notifyListeners();
    return true;
  }

  /// +1 token per solve; also advances the interstitial counter.
  void onPuzzleCompleted() {
    _completedCount += 1;
    if (!_premium) _tokens += AppConfig.tokensPerSolve;
    _persist();
    notifyListeners();
  }

  /// Rewarded-ad payout.
  void grantRewardedTokens() {
    _tokens += AppConfig.tokensPerRewardedAd;
    _persist();
    notifyListeners();
  }

  Future<void> _persist() => _storage.writeJson(StorageService.economyKey, {
    'tokens': _tokens,
    'premium': _premium,
    'completedCount': _completedCount,
  });

  @override
  void dispose() {
    _purchases.premiumOwned.removeListener(_onPremiumChanged);
    super.dispose();
  }
}
