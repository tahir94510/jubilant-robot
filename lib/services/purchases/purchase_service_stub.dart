import 'package:flutter/foundation.dart';

import 'purchase_service.dart';

PurchaseService createPurchaseService() => StubPurchaseService();

/// Web/no-op implementation: purchases unavailable, never premium.
class StubPurchaseService extends PurchaseService {
  StubPurchaseService() : super.base();

  final ValueNotifier<bool> _owned = ValueNotifier(false);
  final ValueNotifier<String?> _price = ValueNotifier(null);

  @override
  bool get supported => false;

  @override
  ValueListenable<bool> get premiumOwned => _owned;

  @override
  ValueListenable<String?> get premiumPrice => _price;

  @override
  Future<void> initialize({required bool initialPremium}) async {
    _owned.value = initialPremium;
  }

  @override
  Future<void> buyPremium() async {}

  @override
  Future<void> restore() async {}

  @override
  void dispose() {}
}
