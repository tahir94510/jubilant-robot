import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ads_service_stub.dart'
    if (dart.library.io) 'ads_service_mobile.dart';

/// Facade for ads + UMP consent. The rest of the app imports ONLY this file.
///
/// On web the stub implementation is compiled in and google_mobile_ads never
/// enters the JS bundle; the preview build simply shows no monetization UI.
abstract class AdsService {
  factory AdsService() => createAdsService();

  AdsService.base();

  /// False on web/stub.
  bool get supported;

  /// Gated by UMP consent; ad widgets/load calls must wait for `true`.
  ValueListenable<bool> get canRequestAds;

  /// Runs the UMP consent flow (if required) and initializes the SDK.
  /// Call after first frame; never blocks startup. No-op when [premium].
  Future<void> initialize({required bool premium});

  /// An adaptive banner for [context]'s width, or null (web/premium/no
  /// consent/not loaded yet).
  Widget? buildAdaptiveBanner(BuildContext context, {required Key key});

  /// Maybe shows an interstitial: every Nth completion, cooldown-limited.
  Future<void> maybeShowInterstitial({required int completedCount});

  /// Shows a rewarded ad; resolves `true` if the reward was earned.
  Future<bool> showRewardedForHints();

  /// Whether the UMP privacy-options entry point must be shown in settings.
  Future<bool> get privacyOptionsRequired;

  Future<void> showPrivacyOptionsForm();

  /// Tears ads down permanently (premium purchased).
  Future<void> disable();
}
