// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get sectionLanguage => 'Langue';

  @override
  String get sectionGameplay => 'Jeu';

  @override
  String get sectionDailyReminder => 'Rappel quotidien';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Confidentialité et à propos';

  @override
  String get appLanguage => 'Langue de l’application';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get theme => 'Thème';

  @override
  String get themeAutoSubtitle => 'Auto (suit votre appareil)';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSepia => 'Sépia';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get colorblindTitle => 'Couleurs adaptées au daltonisme';

  @override
  String get colorblindSubtitle => 'Surbrillance bleue/orange au lieu de rouge';

  @override
  String get errorCheckingTitle => 'Vérification des erreurs';

  @override
  String get errorCheckingSubtitle =>
      'Marquer les lettres fausses une fois la grille remplie';

  @override
  String get showTimerTitle => 'Afficher le chrono';

  @override
  String get showTimerSubtitle => 'Désactivez-le pour une expérience zen';

  @override
  String get hapticsTitle => 'Retour haptique';

  @override
  String get soundEffectsTitle => 'Effets sonores';

  @override
  String get soundEffectsSubtitle => 'Touches douces et carillons délicats';

  @override
  String get effectsVolume => 'Volume des effets';

  @override
  String get musicTitle => 'Musique';

  @override
  String get musicSubtitle => 'Musique d’ambiance calme pendant le jeu';

  @override
  String get musicVolume => 'Volume de la musique';

  @override
  String get remindMeDaily => 'Me rappeler chaque jour';

  @override
  String reminderAt(String time) {
    return 'À $time';
  }

  @override
  String get neverMissStreak => 'Ne manquez jamais votre série';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get reminderDenied =>
      'L’autorisation de notification a été refusée dans les réglages système.';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get premiumActiveSubtitle => 'Merci de soutenir Quotecrack !';

  @override
  String get goPremium => 'Passer Premium';

  @override
  String get goPremiumSubtitle => 'Sans pub, indices illimités, packs bonus';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get checkingPurchases => 'Vérification des achats précédents…';

  @override
  String get privacyOptions => 'Options de confidentialité';

  @override
  String get privacyOptionsSubtitle =>
      'Gérez vos choix de consentement publicitaire';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get openSourceLicenses => 'Licences open source';

  @override
  String get version => 'Version';
}
