import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../config/monetization_config.dart';
import 'purchase_service.dart';

PurchaseService createPurchaseService() => MobilePurchaseService();

/// Google Play Billing implementation for the premium_unlock non-consumable.
///
/// Defensive by design: the purchaseStream listener is attached BEFORE any
/// query so restored/pending purchases delivered at startup are never lost,
/// and `pending` is treated as not-yet-owned (Play will redeliver).
class MobilePurchaseService extends PurchaseService {
  MobilePurchaseService() : super.base();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ValueNotifier<bool> _owned = ValueNotifier(false);
  final ValueNotifier<String?> _price = ValueNotifier(null);
  final ValueNotifier<bool> _inProgress = ValueNotifier(false);
  final ValueNotifier<int> _errorTick = ValueNotifier(0);
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  @override
  bool get supported => true;

  @override
  ValueListenable<bool> get premiumOwned => _owned;

  @override
  ValueListenable<String?> get premiumPrice => _price;

  @override
  ValueListenable<bool> get purchaseInProgress => _inProgress;

  @override
  ValueListenable<int> get purchaseErrorTick => _errorTick;

  @override
  Future<void> initialize({required bool initialPremium}) async {
    _owned.value = initialPremium;

    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});

    if (!await _iap.isAvailable()) return;

    final response = await _iap.queryProductDetails({
      MonetizationConfig.premiumProductId,
    });
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
      _price.value = _product!.price;
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != MonetizationConfig.premiumProductId) {
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _owned.value = true;
          _inProgress.value = false;
        case PurchaseStatus.error:
          // Surface store failures so the paywall can tell the user instead of
          // leaving the button stuck "loading".
          _errorTick.value++;
          _inProgress.value = false;
        case PurchaseStatus.canceled:
          // A user cancel is not an error — just clear the in-flight state.
          _inProgress.value = false;
        case PurchaseStatus.pending:
          // Play will redeliver; keep showing progress until it resolves.
          _inProgress.value = true;
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  @override
  Future<void> buyPremium() async {
    final product = _product;
    if (product == null) return;
    _inProgress.value = true;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      // Launch failure (e.g. billing unavailable): report and reset.
      _errorTick.value++;
      _inProgress.value = false;
    }
  }

  @override
  Future<void> restore() async {
    _inProgress.value = true;
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _errorTick.value++;
    } finally {
      // restorePurchases re-delivers owned purchases via the stream (handled in
      // _onPurchases); if nothing is owned, no event arrives, so clear here so
      // the button never stays stuck.
      _inProgress.value = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
  }
}
