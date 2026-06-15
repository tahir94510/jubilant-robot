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
}
