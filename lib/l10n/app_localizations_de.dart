// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionAppearance => 'Darstellung';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get sectionGameplay => 'Spiel';

  @override
  String get sectionDailyReminder => 'Tägliche Erinnerung';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Datenschutz & Info';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get theme => 'Design';

  @override
  String get themeAutoSubtitle => 'Automatisch (folgt deinem Gerät)';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get textSize => 'Textgröße';

  @override
  String get colorblindTitle => 'Farbenblind-freundliche Farben';

  @override
  String get colorblindSubtitle => 'Blau/Orange statt Rot';

  @override
  String get errorCheckingTitle => 'Fehlerprüfung';

  @override
  String get errorCheckingSubtitle =>
      'Falsche Buchstaben markieren, sobald das Feld voll ist';

  @override
  String get showTimerTitle => 'Timer anzeigen';

  @override
  String get showTimerSubtitle =>
      'Für ein ganz entspanntes Erlebnis ausschalten';

  @override
  String get hapticsTitle => 'Haptisches Feedback';

  @override
  String get soundEffectsTitle => 'Soundeffekte';

  @override
  String get soundEffectsSubtitle => 'Sanfte Tastentöne und feine Klänge';

  @override
  String get effectsVolume => 'Effektlautstärke';

  @override
  String get musicTitle => 'Musik';

  @override
  String get musicSubtitle => 'Ruhige Hintergrundmusik beim Spielen';

  @override
  String get musicVolume => 'Musiklautstärke';

  @override
  String get remindMeDaily => 'Täglich erinnern';

  @override
  String reminderAt(String time) {
    return 'Um $time';
  }

  @override
  String get neverMissStreak => 'Verpasse nie deine Serie';

  @override
  String get reminderTime => 'Erinnerungszeit';

  @override
  String get reminderDenied =>
      'Benachrichtigungsberechtigung in den Systemeinstellungen verweigert.';

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get premiumActiveSubtitle => 'Danke, dass du Quotecrack unterstützt!';

  @override
  String get goPremium => 'Premium holen';

  @override
  String get goPremiumSubtitle =>
      'Keine Werbung, unbegrenzte Hinweise, Bonus-Pakete';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get checkingPurchases => 'Frühere Käufe werden geprüft…';

  @override
  String get privacyOptions => 'Datenschutzoptionen';

  @override
  String get privacyOptionsSubtitle => 'Verwalte deine Einwilligung zu Werbung';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get version => 'Version';

  @override
  String get homeDailyLabel => 'TÄGLICHES RÄTSEL';

  @override
  String get homeDailySolved => 'Gelöst! Komm morgen für ein neues wieder.';

  @override
  String homeDailyAwaits(String author) {
    return 'Ein Geheimtext von $author wartet auf dich.';
  }

  @override
  String get playNow => 'Jetzt spielen';

  @override
  String get replay => 'Nochmal spielen';

  @override
  String get puzzlePacks => 'Rätselpakete';

  @override
  String packsSolved(int solved, int total) {
    return '$solved von $total gelöst';
  }

  @override
  String get statistics => 'Statistiken';

  @override
  String get statisticsSubtitle => 'Serien, Zeiten und deine Heatmap';

  @override
  String get achievements => 'Erfolge';

  @override
  String achievementsUnlocked(int count) {
    return '$count freigeschaltet';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Werbefrei · unbegrenzte Hinweise · Bonus-Pakete';

  @override
  String get musicToggleTooltip => 'Musik an/aus';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Löse ohne Grenzen';

  @override
  String get paywallSubhead => 'Einmal kaufen. Für immer deins. Kein Abo.';

  @override
  String get paywallNoAdsTitle => 'Nie wieder Werbung';

  @override
  String get paywallNoAdsBody =>
      'Alle Banner und Vollbild-Anzeigen verschwinden';

  @override
  String get paywallHintsTitle => 'Unbegrenzte Hinweise';

  @override
  String get paywallHintsBody =>
      'Deck einen Buchstaben auf, wann immer du feststeckst';

  @override
  String get paywallPacksTitle => 'Exklusive Bonus-Pakete';

  @override
  String get paywallPacksBody =>
      'Shakespeare, stoische Weisheit und mehr in Arbeit';

  @override
  String get paywallSupportTitle => 'Unterstütze das Spiel';

  @override
  String get paywallSupportBody => 'Ein Kauf hilft Quotecrack zu wachsen';

  @override
  String get paywallActive => 'Premium aktiv. Viel Spaß!';

  @override
  String get paywallUnavailable => 'Käufe sind in der Android-App verfügbar.';

  @override
  String get paywallLoadingPrice => 'Preis wird geladen…';

  @override
  String paywallUnlock(String price) {
    return 'Premium freischalten · $price';
  }

  @override
  String get paywallRestore => 'Früheren Kauf wiederherstellen';

  @override
  String get completeDailyTitle => 'Tagesrätsel gelöst!';

  @override
  String get completeTitle => 'Gelöst!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hinweise',
      one: '1 Hinweis',
      zero: 'Keine Hinweise',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage Serie',
      one: '1 Tag Serie',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erfolge freigeschaltet',
      one: 'Erfolg freigeschaltet',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Ergebnis teilen';

  @override
  String get nextPuzzle => 'Nächstes Rätsel';

  @override
  String get backToMenu => 'Zurück zum Menü';

  @override
  String get reminderNudgeTitle => 'Schütze deine Serie';

  @override
  String get reminderNudgeBody =>
      'Ein sanfter Hinweis pro Tag, damit dir das morgige Rätsel nie entgeht. Die Uhrzeit kannst du in den Einstellungen ändern.';

  @override
  String get reminderNudgeNo => 'Jetzt nicht';

  @override
  String get reminderNudgeDenied =>
      'Benachrichtigungsberechtigung verweigert. Du kannst sie jederzeit in den Einstellungen aktivieren.';
}
