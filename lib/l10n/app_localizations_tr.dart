// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get sectionLanguage => 'Dil';

  @override
  String get sectionGameplay => 'Oynanış';

  @override
  String get sectionDailyReminder => 'Günlük hatırlatma';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Gizlilik ve hakkında';

  @override
  String get appLanguage => 'Uygulama dili';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get theme => 'Tema';

  @override
  String get themeAutoSubtitle => 'Otomatik (cihazınızı izler)';

  @override
  String get themeAuto => 'Otomatik';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSepia => 'Sepya';

  @override
  String get textSize => 'Yazı boyutu';

  @override
  String get colorblindTitle => 'Renk körlüğüne uygun renkler';

  @override
  String get colorblindSubtitle => 'Kırmızı yerine mavi/turuncu vurgular';

  @override
  String get errorCheckingTitle => 'Hata denetimi';

  @override
  String get errorCheckingSubtitle =>
      'Tahta dolduğunda yanlış harfleri işaretle';

  @override
  String get showTimerTitle => 'Süreyi göster';

  @override
  String get showTimerSubtitle => 'Tamamen sakin bir deneyim için kapatın';

  @override
  String get hapticsTitle => 'Dokunsal geri bildirim';

  @override
  String get soundEffectsTitle => 'Ses efektleri';

  @override
  String get soundEffectsSubtitle => 'Yumuşak tuş sesleri ve nazik tınılar';

  @override
  String get effectsVolume => 'Efekt ses düzeyi';

  @override
  String get musicTitle => 'Müzik';

  @override
  String get musicSubtitle => 'Oynarken sakin bir ortam müziği';

  @override
  String get musicVolume => 'Müzik ses düzeyi';

  @override
  String get remindMeDaily => 'Beni her gün hatırlat';

  @override
  String reminderAt(String time) {
    return 'Saat $time';
  }

  @override
  String get neverMissStreak => 'Serini hiç kaçırma';

  @override
  String get reminderTime => 'Hatırlatma saati';

  @override
  String get reminderDenied => 'Bildirim izni sistem ayarlarında reddedildi.';

  @override
  String get premiumActive => 'Premium etkin';

  @override
  String get premiumActiveSubtitle =>
      'Quotecrack’i desteklediğiniz için teşekkürler!';

  @override
  String get goPremium => 'Premium’a geç';

  @override
  String get goPremiumSubtitle =>
      'Reklamları kaldır, sınırsız ipucu, bonus paketler';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get checkingPurchases => 'Önceki satın alımlar denetleniyor…';

  @override
  String get privacyOptions => 'Gizlilik seçenekleri';

  @override
  String get privacyOptionsSubtitle => 'Reklam onay tercihlerinizi yönetin';

  @override
  String get privacyPolicy => 'Gizlilik politikası';

  @override
  String get openSourceLicenses => 'Açık kaynak lisansları';

  @override
  String get version => 'Sürüm';

  @override
  String get homeDailyLabel => 'GÜNLÜK BULMACA';

  @override
  String get homeDailySolved => 'Çözüldü! Yarın yenisi için tekrar uğra.';

  @override
  String homeDailyAwaits(String author) {
    return '$author imzalı bir şifre sizi bekliyor.';
  }

  @override
  String get playNow => 'Hemen oyna';

  @override
  String get replay => 'Tekrar oyna';

  @override
  String get puzzlePacks => 'Bulmaca paketleri';

  @override
  String packsSolved(int solved, int total) {
    return '$total bulmacanın $solved tanesi çözüldü';
  }

  @override
  String get statistics => 'İstatistikler';

  @override
  String get statisticsSubtitle => 'Seriler, süreler ve ısı haritan';

  @override
  String get achievements => 'Başarımlar';

  @override
  String achievementsUnlocked(int count) {
    return '$count açıldı';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Reklamsız · sınırsız ipucu · bonus paketler';

  @override
  String get musicToggleTooltip => 'Müzik açık/kapalı';

  @override
  String get settingsTooltip => 'Ayarlar';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Sınırsız çöz';

  @override
  String get paywallSubhead =>
      'Tek seferlik alım. Sonsuza dek senin. Abonelik yok.';

  @override
  String get paywallNoAdsTitle => 'Hiç reklam yok';

  @override
  String get paywallNoAdsBody => 'Tüm banner ve tam ekran reklamlar kalkar';

  @override
  String get paywallHintsTitle => 'Sınırsız ipucu';

  @override
  String get paywallHintsBody => 'Takıldığında istediğin an bir harf aç';

  @override
  String get paywallPacksTitle => 'Özel bonus paketler';

  @override
  String get paywallPacksBody => 'Shakespeare, Stoacı bilgelik ve dahası yolda';

  @override
  String get paywallSupportTitle => 'Oyuna destek ol';

  @override
  String get paywallSupportBody =>
      'Tek bir alım Quotecrack’in büyümesine yardım eder';

  @override
  String get paywallActive => 'Premium etkin. Keyfini çıkar!';

  @override
  String get paywallUnavailable =>
      'Satın alma yalnızca Android uygulamasında mevcut.';

  @override
  String get paywallLoadingPrice => 'Fiyat yükleniyor…';

  @override
  String paywallUnlock(String price) {
    return 'Premium’u aç · $price';
  }

  @override
  String get paywallRestore => 'Önceki satın alımı geri yükle';

  @override
  String get completeDailyTitle => 'Günlük çözüldü!';

  @override
  String get completeTitle => 'Çözüldü!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ipucu',
      one: '1 ipucu',
      zero: 'İpucu yok',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük seri',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Başarımlar açıldı',
      one: 'Başarım açıldı',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Sonucu paylaş';

  @override
  String get nextPuzzle => 'Sonraki bulmaca';

  @override
  String get backToMenu => 'Ana menüye dön';

  @override
  String get reminderNudgeTitle => 'Serini koru';

  @override
  String get reminderNudgeBody =>
      'Günde bir nazik hatırlatma, böylece yarının bulmacası asla kaçmaz. Saati Ayarlar’dan değiştirebilirsin.';

  @override
  String get reminderNudgeNo => 'Şimdi değil';

  @override
  String get reminderNudgeDenied =>
      'Bildirim izni reddedildi. İstediğin zaman Ayarlar’dan açabilirsin.';
}
