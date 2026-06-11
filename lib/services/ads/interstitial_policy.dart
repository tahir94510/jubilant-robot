import '../../config/app_config.dart';

/// Pure decision logic for interstitial pacing, kept plugin-free so it can
/// be unit-tested: every Nth completed puzzle, but never within the
/// cooldown window of the previous one.
class InterstitialPolicy {
  const InterstitialPolicy();

  bool shouldShow({
    required int completedCount,
    required DateTime? lastShownAt,
    required DateTime now,
  }) {
    if (completedCount <= 0) return false;
    if (completedCount % AppConfig.interstitialEveryNSolves != 0) {
      return false;
    }
    if (lastShownAt != null &&
        now.difference(lastShownAt) < AppConfig.interstitialCooldown) {
      return false;
    }
    return true;
  }
}
