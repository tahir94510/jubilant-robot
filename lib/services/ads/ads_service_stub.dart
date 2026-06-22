import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ads_service.dart';

AdsService createAdsService() => StubAdsService();

/// Web/no-op implementation: no ads, no consent, nothing to do.
class StubAdsService extends AdsService {
  StubAdsService() : super.base();

  final ValueNotifier<bool> _never = ValueNotifier(false);

  @override
  bool get supported => false;

  @override
  ValueListenable<bool> get canRequestAds => _never;

  @override
  Future<void> initialize({required bool premium}) async {}

  @override
  Widget? buildAdaptiveBanner(BuildContext context, {required Key key}) => null;

  @override
  Future<void> maybeShowInterstitial({required int completedCount}) async {}

  @override
  Future<bool> showRewardedForHints() async => false;

  @override
  bool get rewardedReady => false;

  @override
  ValueListenable<bool> get rewardedAvailable => _never;

  @override
  bool get rewardedEverServed => false;

  @override
  Future<bool> get privacyOptionsRequired async => false;

  @override
  Future<void> showPrivacyOptionsForm() async {}

  @override
  Future<void> disable() async {}
}
