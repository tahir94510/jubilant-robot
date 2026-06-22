// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String a11yLetterCellEmpty(String letter) {
    return '$letter harfi, boş';
  }

  @override
  String a11yLetterCellFilled(String letter, String guess) {
    return '$letter harfi, cevap $guess';
  }

  @override
  String get a11yDismiss => 'Kapat';

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
  String get themeAutoSubtitle => 'Otomatik (cihazını izler)';

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
  String get showTimerSubtitle => 'Tamamen sakin bir deneyim için kapat';

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
  String get remindMeDaily => 'Bana her gün hatırlat';

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
      'Quotecrack’i desteklediğin için teşekkürler!';

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
  String get privacyOptionsSubtitle => 'Reklam onay tercihlerini yönet';

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
    return '$author imzalı bir şifre seni bekliyor.';
  }

  @override
  String get pressBackAgainToExit => 'Çıkmak için tekrar geri\'ye bas';

  @override
  String get homeContinueLabel => 'DEVAM ET';

  @override
  String get homeContinueSubtitle => 'Kaldığın yerden devam et';

  @override
  String get continuePlaying => 'Devam et';

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
  String get paywallPacksBody =>
      'Zamansız seslerden oluşan özel bir Klasikler paketi; dahası yolda';

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
  String get premiumUnlockedTitle => 'Premium açıldı!';

  @override
  String get premiumUnlockedBody =>
      'Reklamlar tamamen kalktı, ipuçların artık sınırsız. Quotecrack\'e destek olduğun için teşekkürler!';

  @override
  String get premiumContinue => 'Oynamaya başla';

  @override
  String get purchaseFailed =>
      'Satın alma tamamlanamadı. Lütfen tekrar deneyin.';

  @override
  String get purchaseRestoring => 'Satın alımınız geri yükleniyor…';

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
      one: '1 günlük seri',
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

  @override
  String get packsSectionByDifficulty => 'Zorluğa göre';

  @override
  String get packsDifficultyHint =>
      'Sezgiye aykırı ama gerçek: kısa sözler en zorudur. Daha az harf, üzerinde çalışacağın daha az ipucu demektir.';

  @override
  String get packsSectionThemed => 'Temalı';

  @override
  String get statsFirstRun =>
      'İstatistiklerini ve serini başlatmak için bugünün şifresini çöz.';

  @override
  String get statPuzzlesSolved => 'Çözülen bulmaca';

  @override
  String get statCurrentStreak => 'Güncel seri';

  @override
  String get statBestStreak => 'En iyi seri';

  @override
  String get statFastestSolve => 'En hızlı çözüm';

  @override
  String get statNoHintSolves => 'İpucusuz çözüm';

  @override
  String get statDailiesSolved => 'Çözülen günlük';

  @override
  String get statsDailyActivity => 'Günlük etkinlik';

  @override
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Son $weeks hafta · $start ile $end';
  }

  @override
  String get puzzleAlreadySolved => 'Bunu zaten çözdün.';

  @override
  String get showSolution => 'Çözümü göster';

  @override
  String get backToPuzzle => 'Denememe dön';

  @override
  String get actionPrev => 'Önceki harf';

  @override
  String get actionNext => 'Sonraki harf';

  @override
  String get actionUndo => 'Geri al';

  @override
  String get actionRedo => 'İleri al';

  @override
  String get dailyPuzzleTitle => 'Günlük bulmaca';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Başarımlar ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Her harf yer değiştirir';

  @override
  String get onbStep1Body =>
      'Bir kriptogramda alfabedeki her harf, başka bir harfin yerine geçer. E aslında K olabilir, T aslında A olabilir; ama bu değişim metnin her yerinde tutarlıdır.';

  @override
  String get onbStep2Title => 'Örüntülerle çöz';

  @override
  String get onbStep2Body =>
      'Kısa kelimeler dayanak noktandır: en sık harfler genelde A ve E’dir, VE ile BİR her yerde geçer. Harf sıklığı en büyük yardımcın.';

  @override
  String get onbStep3Title => 'Dokun, sonra yaz';

  @override
  String get onbStep3Body =>
      'Bir şifre harfini seçmek için herhangi bir kutucuğa dokun, sonra klavyeden gerçek harfini seç. Aynı harfler birlikte dolar.';

  @override
  String get onbNext => 'İleri';

  @override
  String get onbTryOne => 'Bir tane dene (30 saniye)';

  @override
  String get onbSkip => 'Atla';

  @override
  String get notificationDailyTitle => 'Günlük şifren hazır';

  @override
  String get notificationDailyBody =>
      'Çözülmeyi bekleyen taze bir söz var. Serini canlı tut!';

  @override
  String shareSolvedIn(String time) {
    return '$time sürede çözüldü';
  }

  @override
  String get packTitleBeginner => 'Başlangıç';

  @override
  String get packTaglineBeginner => 'Uzun sözler, yumuşak şifreler';

  @override
  String get packTitleCasual => 'Rahat';

  @override
  String get packTaglineCasual => 'Keyifli bir meydan okuma';

  @override
  String get packTitleSkilled => 'Usta';

  @override
  String get packTaglineSkilled => 'Deneyimli çözücüler için';

  @override
  String get packTitleExpert => 'Uzman';

  @override
  String get packTaglineExpert => 'Kısa, keskin, affetmez';

  @override
  String get packTitleShortSweet => 'Kısa ve Öz';

  @override
  String get packTaglineShortSweet => 'Hızlı bir zafer için minik sözler';

  @override
  String get packTitleProverbs => 'Atasözleri';

  @override
  String get packTaglineProverbs => 'Dünyanın halk bilgeliği';

  @override
  String get packTitleWisdom => 'Bilgelik';

  @override
  String get packTaglineWisdom => 'Düşünürler ve devlet adamları';

  @override
  String get packTitleLiterature => 'Edebiyat';

  @override
  String get packTaglineLiterature => 'Büyük kitaplardan satırlar';

  @override
  String get packTitleWit => 'Nükte';

  @override
  String get packTaglineWit => 'Keskin diller, zekice espriler';

  @override
  String get packTitleClassics => 'Klasikler';

  @override
  String get packTaglineClassics => 'Zamansız sesler, özenle seçildi';

  @override
  String get packTitleInspire => 'Yürek & Cesaret';

  @override
  String get packTaglineInspire => 'Sevgi, dostluk ve azim atasözleri';

  @override
  String get achDescFirst => 'İlk kriptogramını çöz';

  @override
  String achDescSolve(int count) {
    return '$count bulmaca çöz';
  }

  @override
  String achDescStreak(int count) {
    return '$count günlük seriye ulaş';
  }

  @override
  String achDescNoHints(int count) {
    return 'İpucu kullanmadan $count bulmaca çöz';
  }

  @override
  String achDescSpeed(int count) {
    return 'Bir bulmacayı $count saniyenin altında çöz';
  }

  @override
  String achDescDaily(int count) {
    return '$count günlük bulmaca çöz';
  }

  @override
  String get achTitleFirstSolve => 'İlk Kırış';

  @override
  String get achTitleSolve10 => 'Çırak Çözücü';

  @override
  String get achTitleSolve25 => 'Şifre Kırıcı';

  @override
  String get achTitleSolve50 => 'Şifre Dedektifi';

  @override
  String get achTitleSolve100 => 'Yüzbaşı';

  @override
  String get achTitleSolve250 => 'Usta Kriptolog';

  @override
  String get achTitleSolve500 => 'Büyük Usta';

  @override
  String get achTitleStreak3 => 'Isınıyor';

  @override
  String get achTitleStreak7 => 'Tam Bir Hafta';

  @override
  String get achTitleStreak14 => 'İki Hafta İstikrar';

  @override
  String get achTitleStreak30 => 'Aylık Adanmışlık';

  @override
  String get achTitleStreak100 => 'Kırılmaz';

  @override
  String get achTitleStreak365 => 'Yıl Boyu Çözücü';

  @override
  String get achTitleNoHints10 => 'Saf Çözücü';

  @override
  String get achTitleNoHints25 => 'Kendine Yeten';

  @override
  String get achTitleNoHints50 => 'Demir İrade';

  @override
  String get achTitleNoHints100 => 'Yardımsız Zihin';

  @override
  String get achTitleSpeed30 => 'Göz Açıp Kapayana Dek';

  @override
  String get achTitleSpeed60 => 'Şimşek Hızı';

  @override
  String get achTitleSpeed120 => 'Hızlı Düşünür';

  @override
  String get achTitleDaily10 => 'Günlük Ritüel';

  @override
  String get achTitleDaily25 => 'Sadık Çözücü';

  @override
  String get achTitleDaily50 => 'Sabah Kahvesi';

  @override
  String get achTitleDaily100 => 'Yüz Sabah';

  @override
  String get hintRevealLetter => 'Harf aç';

  @override
  String hintRevealLetterCount(int count) {
    return 'Harf aç ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count ipucu eklendi';
  }

  @override
  String get adNoVideo => 'Şu anda video yok. Lütfen birazdan tekrar dene.';

  @override
  String get badgeNew => 'YENİ';
}
