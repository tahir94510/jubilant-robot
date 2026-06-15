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
}
