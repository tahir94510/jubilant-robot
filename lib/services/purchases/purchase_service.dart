import 'package:flutter/foundation.dart';

import 'purchase_service_stub.dart'
    if (dart.library.io) 'purchase_service_mobile.dart';

/// Facade for the one-time premium unlock purchase.
abstract class PurchaseService {
  factory PurchaseService() => createPurchaseService();

  PurchaseService.base();

  /// False on web/stub.
  bool get supported;

  /// True once the premium_unlock purchase is owned (live-updating).
  ValueListenable<bool> get premiumOwned;

  /// Localized price string for the paywall (e.g. "$4.99"), null until the
  /// product query completes.
  ValueListenable<String?> get premiumPrice;

  /// True while a buy/restore flow is in flight (incl. a `pending` purchase),
  /// so the paywall can show a spinner and disable the buttons.
  ValueListenable<bool> get purchaseInProgress;

  /// Bumps each time a purchase fails (store error). The paywall watches it to
  /// surface a one-shot "couldn't complete" message; user cancellations do not
  /// bump it (no error to report).
  ValueListenable<int> get purchaseErrorTick;

  /// Attaches the purchase stream listener, then queries the product.
  /// [initialPremium] seeds the flag from the local cache so the UI is
  /// correct before the store responds.
  Future<void> initialize({required bool initialPremium});

  /// Starts the purchase flow. Result arrives via [premiumOwned].
  Future<void> buyPremium();

  /// Restores prior purchases (mandatory UX for non-consumables).
  Future<void> restore();

  void dispose();
}
