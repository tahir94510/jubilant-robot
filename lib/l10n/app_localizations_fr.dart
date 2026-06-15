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

  @override
  String get homeDailyLabel => 'ÉNIGME DU JOUR';

  @override
  String get homeDailySolved => 'Résolu ! Revenez demain pour une nouvelle.';

  @override
  String homeDailyAwaits(String author) {
    return 'Un message chiffré de $author vous attend.';
  }

  @override
  String get playNow => 'Jouer';

  @override
  String get replay => 'Rejouer';

  @override
  String get puzzlePacks => 'Packs d’énigmes';

  @override
  String packsSolved(int solved, int total) {
    return '$solved sur $total résolues';
  }

  @override
  String get statistics => 'Statistiques';

  @override
  String get statisticsSubtitle =>
      'Séries, temps et votre calendrier d’activité';

  @override
  String get achievements => 'Succès';

  @override
  String achievementsUnlocked(int count) {
    return '$count débloqués';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Sans pub · indices illimités · packs bonus';

  @override
  String get musicToggleTooltip => 'Musique activée/désactivée';

  @override
  String get settingsTooltip => 'Paramètres';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Résolvez sans limites';

  @override
  String get paywallSubhead =>
      'Un seul achat. À vous pour toujours. Sans abonnement.';

  @override
  String get paywallNoAdsTitle => 'Plus aucune publicité';

  @override
  String get paywallNoAdsBody =>
      'Toutes les bannières et pubs plein écran disparaissent';

  @override
  String get paywallHintsTitle => 'Indices illimités';

  @override
  String get paywallHintsBody => 'Révélez une lettre dès que vous bloquez';

  @override
  String get paywallPacksTitle => 'Packs bonus exclusifs';

  @override
  String get paywallPacksBody =>
      'Shakespeare, sagesse stoïcienne et plus à venir';

  @override
  String get paywallSupportTitle => 'Soutenez le jeu';

  @override
  String get paywallSupportBody => 'Un achat aide Quotecrack à grandir';

  @override
  String get paywallActive => 'Premium actif. Profitez-en !';

  @override
  String get paywallUnavailable =>
      'Les achats sont disponibles dans l’app Android.';

  @override
  String get paywallLoadingPrice => 'Chargement du prix…';

  @override
  String paywallUnlock(String price) {
    return 'Débloquer Premium · $price';
  }

  @override
  String get paywallRestore => 'Restaurer l’achat précédent';

  @override
  String get completeDailyTitle => 'Énigme du jour résolue !';

  @override
  String get completeTitle => 'Résolu !';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count indices',
      one: '1 indice',
      zero: 'Aucun indice',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Succès débloqués',
      one: 'Succès débloqué',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Partager le résultat';

  @override
  String get nextPuzzle => 'Énigme suivante';

  @override
  String get backToMenu => 'Retour au menu';

  @override
  String get reminderNudgeTitle => 'Protégez votre série';

  @override
  String get reminderNudgeBody =>
      'Un petit rappel par jour, pour ne jamais manquer l’énigme du lendemain. Vous pouvez changer l’heure dans les Paramètres.';

  @override
  String get reminderNudgeNo => 'Pas maintenant';

  @override
  String get reminderNudgeDenied =>
      'L’autorisation de notification a été refusée. Vous pouvez l’activer à tout moment dans les Paramètres.';

  @override
  String get packsSectionByDifficulty => 'Par difficulté';

  @override
  String get packsDifficultyHint =>
      'Contre-intuitif mais vrai : les citations courtes sont les plus dures. Moins de lettres, c’est moins d’indices pour avancer.';

  @override
  String get packsSectionThemed => 'Thématiques';

  @override
  String get statsFirstRun =>
      'Résolvez l’énigme du jour pour lancer vos statistiques et votre série.';

  @override
  String get statPuzzlesSolved => 'Énigmes résolues';

  @override
  String get statCurrentStreak => 'Série actuelle';

  @override
  String get statBestStreak => 'Meilleure série';

  @override
  String get statFastestSolve => 'Résolution la plus rapide';

  @override
  String get statNoHintSolves => 'Sans indice';

  @override
  String get statDailiesSolved => 'Quotidiennes résolues';

  @override
  String get statsDailyActivity => 'Activité quotidienne';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Succès ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Chaque lettre est remplacée';

  @override
  String get onbStep1Body =>
      'Dans un cryptogramme, chaque lettre de l’alphabet en représente une autre. E peut être K, T peut être A, mais la substitution est cohérente partout.';

  @override
  String get onbStep2Title => 'Déchiffrez par les motifs';

  @override
  String get onbStep2Body =>
      'Les mots courts sont des appuis : les lettres fréquentes sont E et A, et LE, LA, ET reviennent partout. La fréquence des lettres est votre alliée.';

  @override
  String get onbStep3Title => 'Touchez, puis tapez';

  @override
  String get onbStep3Body =>
      'Touchez une case pour sélectionner cette lettre chiffrée, puis choisissez sa vraie lettre au clavier. Les lettres identiques se remplissent ensemble.';

  @override
  String get onbNext => 'Suivant';

  @override
  String get onbTryOne => 'Essayez-en une (30 secondes)';

  @override
  String get onbSkip => 'Passer';

  @override
  String get notificationDailyTitle => 'Votre cryptogramme du jour est prêt';

  @override
  String get notificationDailyBody =>
      'Une nouvelle citation attend d’être déchiffrée. Gardez votre série en vie !';

  @override
  String shareSolvedIn(String time) {
    return 'résolu en $time';
  }
}
