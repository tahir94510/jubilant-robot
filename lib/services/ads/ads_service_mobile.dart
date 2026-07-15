import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/monetization_config.dart';
import 'ads_service.dart';
import 'interstitial_policy.dart';

AdsService createAdsService() => MobileAdsService();

/// Real AdMob implementation with the UMP (GDPR) consent flow.
///
/// Flow: requestConsentInfoUpdate -> loadAndShowConsentFormIfRequired (only
/// appears where legally required) -> canRequestAds? -> MobileAds.initialize.
/// A UMP failure must never brick ads forever: we still check canRequestAds
/// (true outside consent geographies) and simply retry on next launch.
///
/// MEDIATION (bidding): the gma_mediation_{applovin,unity,pangle} adapters in
/// pubspec ride along automatically — MobileAds.initialize() initializes every
/// registered adapter, and each AdRequest below runs the bidding auction once
/// the ad sources are configured in the AdMob console. No per-network code is
/// needed here, and DELIBERATELY none is called for consent either: the UMP
/// GDPR message is an IAB TCF v2 CMP, so AppLovin/Unity/Pangle read the TCF
/// consent string directly from SharedPreferences themselves. Calling their
/// boolean consent setters (setHasUserConsent etc.) on top of TCF would
/// OVERRIDE the user's real per-vendor choices with a blanket value — worse
/// for compliance, not better. Verify adapter status via Ad Inspector
/// ([openAdInspector], debug settings tile).
class MobileAdsService extends AdsService {
  MobileAdsService() : super.base();

  final ValueNotifier<bool> _canRequestAds = ValueNotifier(false);
  bool _sdkInitialized = false;
  bool _disabled = false;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  final ValueNotifier<bool> _rewardedAvailable = ValueNotifier(false);
  DateTime? _lastInterstitialShown;

  /// Sticky: once a real rewarded ad serves, free hints are off for good.
  static const String _everServedKey = 'ads.rewarded_served';
  bool _everServed = false;

  @override
  bool get supported => true;

  @override
  ValueListenable<bool> get canRequestAds => _canRequestAds;

  @override
  bool get rewardedReady =>
      !_disabled && _canRequestAds.value && _rewarded != null;

  @override
  ValueListenable<bool> get rewardedAvailable => _rewardedAvailable;

  void _updateRewardedAvailable() => _rewardedAvailable.value = rewardedReady;

  @override
  bool get rewardedEverServed => _everServed;

  Future<void> _markEverServed() async {
    if (_everServed) return;
    _everServed = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_everServedKey, true);
    } catch (_) {}
  }

  @override
  Future<void> initialize({required bool premium}) async {
    if (premium || _disabled) return;

    // Restore the sticky "ads have served" flag first so a fresh launch in
    // production never reopens the free-hint fallback window.
    try {
      final prefs = await SharedPreferences.getInstance();
      _everServed = prefs.getBool(_everServedKey) ?? false;
    } catch (_) {}

    final params = ConsentRequestParameters();
    final consentDone = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        // Shows the GDPR form only where legally required, then continues.
        ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (!consentDone.isCompleted) consentDone.complete();
        });
      },
      (FormError error) {
        // Network/config error: proceed; canRequestAds stays authoritative.
        if (!consentDone.isCompleted) consentDone.complete();
      },
    );
    await consentDone.future;

    if (_disabled) return;
    if (await ConsentInformation.instance.canRequestAds()) {
      if (!_sdkInitialized) {
        await MobileAds.instance.initialize();
        _sdkInitialized = true;
      }
      _canRequestAds.value = true;
      _preloadInterstitial();
      _preloadRewarded();
    }
  }

  // ---- Banner ----

  @override
  Widget? buildAdaptiveBanner(BuildContext context, {required Key key}) {
    if (_disabled || !_canRequestAds.value) return null;
    final width = MediaQuery.sizeOf(context).width.truncate();
    return _AdaptiveBanner(key: key, width: width);
  }

  // ---- Interstitial ----

  void _preloadInterstitial() {
    if (_disabled || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: MonetizationConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // A premium purchase may have called disable() while this was in
          // flight; a disabled service must never retain an ad it can no longer
          // show, so dispose it instead of leaking it until process death.
          if (_disabled) {
            ad.dispose();
            return;
          }
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  @override
  Future<void> maybeShowInterstitial({required int completedCount}) async {
    if (_disabled || !_canRequestAds.value) return;
    const policy = InterstitialPolicy();
    if (!policy.shouldShow(
      completedCount: completedCount,
      lastShownAt: _lastInterstitialShown,
      now: DateTime.now(),
    )) {
      return;
    }

    final ad = _interstitial;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }
    _interstitial = null;

    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    _lastInterstitialShown = DateTime.now();
    await ad.show();
    await closed.future;
    _preloadInterstitial();
  }

  // ---- Rewarded ----

  void _preloadRewarded() {
    if (_disabled || _rewarded != null) return;
    RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // Disabled (premium) while loading: drop the ad rather than hold a
          // rewarded ad that can never be shown.
          if (_disabled) {
            ad.dispose();
            return;
          }
          _rewarded = ad;
          _updateRewardedAvailable();
          // A real ad loaded -> AdMob is live; close the free-hint fallback.
          unawaited(_markEverServed());
        },
        onAdFailedToLoad: (_) {
          _rewarded = null;
          _updateRewardedAvailable();
        },
      ),
    );
  }

  @override
  Future<bool> showRewardedForHints() async {
    if (_disabled || !_canRequestAds.value) return false;
    final ad = _rewarded;
    if (ad == null) {
      _preloadRewarded();
      return false;
    }
    _rewarded = null;
    _updateRewardedAvailable();

    var earned = false;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, reward) => earned = true);
    await closed.future;
    _preloadRewarded();
    return earned;
  }

  // ---- Privacy options (UMP) ----

  @override
  Future<bool> get privacyOptionsRequired async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (!done.isCompleted) done.complete();
    });
    await done.future;
  }

  @override
  Future<void> openAdInspector() async {
    // Debug-only diagnostics: lists every mediation adapter's init status and
    // per-ad-unit fill. Guarded here too (not just at the UI entry point) so a
    // future caller can never surface it in a release build by accident.
    if (!kDebugMode) return;
    final done = Completer<void>();
    MobileAds.instance.openAdInspector((error) {
      if (!done.isCompleted) done.complete();
    });
    await done.future;
  }

  @override
  Future<void> disable() async {
    _disabled = true;
    _canRequestAds.value = false;
    _interstitial?.dispose();
    _interstitial = null;
    _rewarded?.dispose();
    _rewarded = null;
    _updateRewardedAvailable();
  }
}

/// Loads an anchored adaptive banner sized to [width]. Reserves height only
/// after the ad actually loads, so there is no layout jump on failure.
class _AdaptiveBanner extends StatefulWidget {
  const _AdaptiveBanner({super.key, required this.width});

  final int width;

  @override
  State<_AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<_AdaptiveBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is unavailable in initState; kick off the single load here.
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    final orientation = MediaQuery.orientationOf(context);
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          orientation,
          widget.width,
        );
    if (size == null || !mounted) return;
    final banner = BannerAd(
      adUnitId: MonetizationConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
