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
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  @override
  bool get supported => true;

  @override
  ValueListenable<bool> get premiumOwned => _owned;

  @override
  ValueListenable<String?> get premiumPrice => _price;

  @override
  Future<void> initialize({required bool initialPremium}) async {
    _owned.value = initialPremium;

    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (_) {});

    if (!await _iap.isAvailable()) return;

    final response = await _iap
        .queryProductDetails({MonetizationConfig.premiumProductId});
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
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
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
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  void dispose() {
    _sub?.cancel();
  }
}
