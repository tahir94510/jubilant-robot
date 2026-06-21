import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quotecrack/services/ads/ads_service.dart';
import 'package:quotecrack/services/clock.dart';
import 'package:quotecrack/services/music_service.dart';
import 'package:quotecrack/services/notifications/notification_service.dart';
import 'package:quotecrack/services/purchases/purchase_service.dart';
import 'package:quotecrack/services/sound_service.dart';

/// Records monetization calls instead of talking to plugins.
class FakeAdsService extends AdsService {
  FakeAdsService() : super.base();

  final ValueNotifier<bool> canRequest = ValueNotifier(true);
  final List<int> interstitialRequests = [];
  bool rewardedResult = true;
  bool rewardedReadyValue = true;
  bool everServedValue = false;
  int rewardedShown = 0;
  bool disabled = false;

  @override
  bool get supported => true;

  @override
  ValueListenable<bool> get canRequestAds => canRequest;

  @override
  Future<void> initialize({required bool premium}) async {}

  @override
  Widget? buildAdaptiveBanner(BuildContext context, {required Key key}) =>
      Container(key: key, height: 50, color: const Color(0xFFEEEEEE));

  @override
  Future<void> maybeShowInterstitial({required int completedCount}) async {
    interstitialRequests.add(completedCount);
  }

  @override
  Future<bool> showRewardedForHints() async {
    rewardedShown += 1;
    return rewardedResult;
  }

  @override
  bool get rewardedReady => rewardedReadyValue;

  @override
  bool get rewardedEverServed => everServedValue;

  @override
  Future<bool> get privacyOptionsRequired async => false;

  @override
  Future<void> showPrivacyOptionsForm() async {}

  @override
  Future<void> disable() async {
    disabled = true;
    canRequest.value = false;
  }
}

/// Scriptable purchases: tests flip [premiumOwned] to simulate a purchase.
class FakePurchaseService extends PurchaseService {
  FakePurchaseService({bool initiallyOwned = false}) : super.base() {
    owned.value = initiallyOwned;
  }

  final ValueNotifier<bool> owned = ValueNotifier(false);
  final ValueNotifier<String?> price = ValueNotifier(r'$4.99');
  final ValueNotifier<bool> inProgress = ValueNotifier(false);
  final ValueNotifier<int> errorTick = ValueNotifier(0);
  int buyCalls = 0;
  int restoreCalls = 0;

  @override
  bool get supported => true;

  @override
  ValueListenable<bool> get premiumOwned => owned;

  @override
  ValueListenable<String?> get premiumPrice => price;

  @override
  ValueListenable<bool> get purchaseInProgress => inProgress;

  @override
  ValueListenable<int> get purchaseErrorTick => errorTick;

  @override
  Future<void> initialize({required bool initialPremium}) async {
    if (initialPremium) owned.value = true;
  }

  @override
  Future<void> buyPremium() async {
    buyCalls += 1;
    owned.value = true;
  }

  @override
  Future<void> restore() async {
    restoreCalls += 1;
  }

  @override
  void dispose() {}
}

class FakeNotificationService extends NotificationService {
  FakeNotificationService() : super.base();

  bool permissionGranted = true;
  bool osEnabled = true;
  TimeOfDay? scheduledAt;
  int cancelCalls = 0;

  @override
  bool get supported => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> areEnabled() async => osEnabled;

  String? scheduledTitle;
  String? scheduledBody;

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    scheduledAt = time;
    scheduledTitle = title;
    scheduledBody = body;
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls += 1;
    scheduledAt = null;
  }
}

/// Records which effects were requested instead of touching the plugin.
/// (Never call initialize(); recording honors the same isEnabled gate the
/// real service uses, so settings toggles are testable.)
class FakeSoundService extends SoundService {
  FakeSoundService({required super.isEnabled});

  final List<String> played = [];

  void _record(String name) {
    if (isEnabled()) played.add(name);
  }

  @override
  void tap() => _record('tap');

  @override
  void hint() => _record('hint');

  @override
  void conflict() => _record('conflict');

  @override
  void success() => _record('success');

  @override
  void achievement() => _record('achievement');

  @override
  void wordComplete() => _record('word');
}

/// Records music calls instead of touching the plugin.
class FakeMusicService extends MusicService {
  FakeMusicService({required super.isEnabled});

  final List<String> calls = [];

  @override
  Future<void> initialize() async {}

  @override
  void ensureStarted() {
    if (isEnabled()) calls.add('ensureStarted');
  }

  @override
  void duck({Duration hold = const Duration(milliseconds: 1800)}) {
    if (isEnabled()) calls.add('duck');
  }

  @override
  Future<void> setEnabled(bool on) async {
    calls.add('enabled:$on');
  }

  @override
  void dispose() {}
}

/// A clock whose `now` the test controls.
class FakeClock extends Clock {
  FakeClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;

  void advanceDays(int days) => value = value.add(Duration(days: days));
}
