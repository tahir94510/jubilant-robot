import 'package:flutter/foundation.dart';

/// =====================================================================
///  GELIR AYARLARI - DUZENLEYECEGINIZ TEK DART DOSYASI BU.
///  (The ONLY Dart file you need to edit for monetization.)
///
///  1) AdMob hesabinizi acin: https://admob.google.com
///  2) Uygulama olusturun, asagidaki 3 reklam birimini olusturun:
///       - Banner, Gecis reklami (Interstitial), Odullu (Rewarded)
///  3) Asagidaki *_AdUnitIdProd sabitlerini kendi ID'lerinizle degistirin.
///  4) android/app/build.gradle.kts icindeki "admobAppId" degerini de
///     kendi AdMob UYGULAMA kimliginizle degistirin.
///  5) Play Console'da "premium_unlock" adinda "Yonetilen urun" olusturun
///     (urun kimligi AYNEN boyle olmali).
///
///  Adim adim rehber: docs/MONETIZASYON.md
/// =====================================================================
abstract final class MonetizationConfig {
  /// Debug derlemede HER ZAMAN Google'in resmi test reklamlari kullanilir.
  /// Release derleme asagidaki "prod" ID'leri kullanir; onlari kendi
  /// ID'lerinizle degistirmediyseniz test ID'leri devrede kalir (guvenli).
  static bool get useTestAds => kDebugMode;

  // ---- Google'in resmi TEST reklam birimleri (degistirmeyin) ----
  static const String _bannerTest = 'ca-app-pub-3940256099942544/9214589741';
  static const String _interstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  // ---- KENDI reklam birimlerinizle DEGISTIRIN (docs/MONETIZASYON.md) ----
  static const String _bannerProd = _bannerTest; // TODO(owner): degistir
  static const String _interstitialProd = _interstitialTest; // TODO(owner)
  static const String _rewardedProd = _rewardedTest; // TODO(owner)

  static String get bannerAdUnitId => useTestAds ? _bannerTest : _bannerProd;
  static String get interstitialAdUnitId =>
      useTestAds ? _interstitialTest : _interstitialProd;
  static String get rewardedAdUnitId =>
      useTestAds ? _rewardedTest : _rewardedProd;

  /// Play Console'daki tek seferlik "reklamlari kaldir + premium" urunu.
  /// Console'da urun kimligi birebir ayni olmali.
  static const String premiumProductId = 'premium_unlock';
}
