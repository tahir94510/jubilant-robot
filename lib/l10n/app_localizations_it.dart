// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get sectionLanguage => 'Lingua';

  @override
  String get sectionGameplay => 'Gioco';

  @override
  String get sectionDailyReminder => 'Promemoria giornaliero';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Privacy e informazioni';

  @override
  String get appLanguage => 'Lingua dell’app';

  @override
  String get languageSystem => 'Predefinita di sistema';

  @override
  String get theme => 'Tema';

  @override
  String get themeAutoSubtitle => 'Automatico (segue il dispositivo)';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSepia => 'Seppia';

  @override
  String get textSize => 'Dimensione del testo';

  @override
  String get colorblindTitle => 'Colori per daltonici';

  @override
  String get colorblindSubtitle =>
      'Evidenziazioni blu/arancio invece del rosso';

  @override
  String get errorCheckingTitle => 'Controllo errori';

  @override
  String get errorCheckingSubtitle =>
      'Segna le lettere sbagliate quando la griglia è piena';

  @override
  String get showTimerTitle => 'Mostra timer';

  @override
  String get showTimerSubtitle =>
      'Disattivalo per un’esperienza totalmente zen';

  @override
  String get hapticsTitle => 'Feedback aptico';

  @override
  String get soundEffectsTitle => 'Effetti sonori';

  @override
  String get soundEffectsSubtitle =>
      'Tocchi dei tasti delicati e suoni gentili';

  @override
  String get effectsVolume => 'Volume effetti';

  @override
  String get musicTitle => 'Musica';

  @override
  String get musicSubtitle => 'Musica d’atmosfera rilassante mentre giochi';

  @override
  String get musicVolume => 'Volume musica';

  @override
  String get remindMeDaily => 'Ricordamelo ogni giorno';

  @override
  String reminderAt(String time) {
    return 'Alle $time';
  }

  @override
  String get neverMissStreak => 'Non perdere mai la tua serie';

  @override
  String get reminderTime => 'Ora del promemoria';

  @override
  String get reminderDenied =>
      'Autorizzazione alle notifiche negata nelle impostazioni di sistema.';

  @override
  String get premiumActive => 'Premium attivo';

  @override
  String get premiumActiveSubtitle => 'Grazie per supportare Quotecrack!';

  @override
  String get goPremium => 'Passa a Premium';

  @override
  String get goPremiumSubtitle =>
      'Niente pubblicità, indizi illimitati, pacchetti bonus';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get checkingPurchases => 'Controllo degli acquisti precedenti…';

  @override
  String get privacyOptions => 'Opzioni sulla privacy';

  @override
  String get privacyOptionsSubtitle =>
      'Gestisci le tue preferenze sul consenso pubblicitario';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get openSourceLicenses => 'Licenze open source';

  @override
  String get version => 'Versione';
}
