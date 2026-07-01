/// Central tunables for gameplay, economy, and pacing.
///
/// Everything that defines "how the game feels" lives here so it can be
/// tuned without hunting through the codebase.
abstract final class AppConfig {
  // --- Hint economy ---
  /// Tokens a brand-new player starts with.
  static const int startingHintTokens = 10;

  /// Tokens earned for every solved puzzle.
  static const int tokensPerSolve = 1;

  /// Tokens granted for watching one rewarded ad.
  static const int tokensPerRewardedAd = 3;

  /// Economy policy: a hint is NEVER granted without a genuinely watched
  /// rewarded ad. The "+N hints" button enables only while a rewarded ad is
  /// loaded ([AdsService.rewardedAvailable]) and greys out otherwise — so an
  /// offline player (ads can't load) sees a disabled button instead of a free
  /// hint, and the rewarded economy is never undercut. Kept as a named,
  /// test-pinned constant so the "no free hints" guarantee stays explicit.
  ///
  /// (Earlier builds allowed `true` as a brief closed-test convenience before
  /// AdMob first served; that fallback path has been removed.)
  static const bool grantHintsWithoutAd = false;

  // --- Interstitial pacing ---
  /// Show an interstitial after every N completed puzzles...
  static const int interstitialEveryNSolves = 3;

  /// ...but never more often than this.
  static const Duration interstitialCooldown = Duration(seconds: 120);

  // --- Difficulty score thresholds (0-100), see engine/difficulty.dart ---
  // Set at the dataset's quartiles so each bucket is well stocked; if the
  // dataset changes shape, re-derive (quotes_validation_test enforces it).
  static const double beginnerMax = 48;
  static const double casualMax = 55;
  static const double skilledMax = 62;

  // --- Daily puzzle ---
  /// Day numbering epoch for "Quotecrack #N" share text.
  static final DateTime puzzleEpoch = DateTime(2026, 1, 1);

  // --- Review prompt ---
  /// Ask for a store review once, after this many total solves.
  static const int reviewPromptAfterSolves = 5;

  // --- Links (replace listingUrl after the app is live on Google Play) ---
  static const String listingUrl =
      'https://play.google.com/store/apps/details?id=io.github.tahir94510.quotecrack';
  // Kalici adres (Play Console'a da bu girilir). Bu reponun Pages sitesi
  // uzerinde yasar; repo kalici olarak public tutulur (karar: tek repo). Bu
  // derlemeye-gomulu link CI tarafindan degistirilmez, o yuzden repo adiyla
  // (quotecrack) elle guncel tutulur.
  static const String privacyPolicyUrl =
      'https://tahir94510.github.io/quotecrack/privacy.html';

  static const String appName = 'Quotecrack';

  /// Shown in Settings. Bump together with `version:` in pubspec.yaml on
  /// every release.
  static const String appVersion = '2.7.0';

  /// Monotonic content revision. Bump by 1 whenever a batch of new packs or
  /// achievements ships; items tagged with this number show a "NEW" badge
  /// until the player opens the screen that lists them. (1 = launch content,
  /// 2 = the v1.1.5 achievement batch.)
  static const int contentVersion = 2;
}
