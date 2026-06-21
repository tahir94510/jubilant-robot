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
  String get pressBackAgainToExit =>
      'Appuyez à nouveau sur retour pour quitter';

  @override
  String get homeContinueLabel => 'CONTINUER';

  @override
  String get homeContinueSubtitle => 'Reprenez là où vous vous êtes arrêté';

  @override
  String get continuePlaying => 'Continuer';

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
      'Un pack Classiques exclusif de voix intemporelles, et plus à venir';

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
  String statsHeatmapCaption(int weeks, String start, String end) {
    return '$weeks dernières semaines · $start à $end';
  }

  @override
  String get puzzleAlreadySolved => 'Vous avez déjà résolu celui-ci.';

  @override
  String get showSolution => 'Afficher la solution';

  @override
  String get backToPuzzle => 'Revenir à ma grille';

  @override
  String get actionPrev => 'Lettre précédente';

  @override
  String get actionNext => 'Lettre suivante';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionRedo => 'Rétablir';

  @override
  String get dailyPuzzleTitle => 'Énigme du jour';

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

  @override
  String get packTitleBeginner => 'Débutant';

  @override
  String get packTaglineBeginner => 'Citations longues, chiffres doux';

  @override
  String get packTitleCasual => 'Détente';

  @override
  String get packTaglineCasual => 'Un défi confortable';

  @override
  String get packTitleSkilled => 'Confirmé';

  @override
  String get packTaglineSkilled => 'Pour les déchiffreurs aguerris';

  @override
  String get packTitleExpert => 'Expert';

  @override
  String get packTaglineExpert => 'Court, tranchant, impitoyable';

  @override
  String get packTitleShortSweet => 'Court & Concis';

  @override
  String get packTaglineShortSweet =>
      'De courtes citations pour une victoire rapide';

  @override
  String get packTitleProverbs => 'Proverbes';

  @override
  String get packTaglineProverbs => 'La sagesse populaire du monde';

  @override
  String get packTitleWisdom => 'Sagesse';

  @override
  String get packTaglineWisdom => 'Penseurs et hommes d’État';

  @override
  String get packTitleLiterature => 'Littérature';

  @override
  String get packTaglineLiterature => 'Des lignes de grands livres';

  @override
  String get packTitleWit => 'Esprit';

  @override
  String get packTaglineWit => 'Reparties vives et bons mots';

  @override
  String get packTitleClassics => 'Classiques';

  @override
  String get packTaglineClassics => 'Voix intemporelles, triées sur le volet';

  @override
  String get packTitleInspire => 'Cœur & Courage';

  @override
  String get packTaglineInspire =>
      'Proverbes d\'amour, d\'amitié et de ténacité';

  @override
  String get achDescFirst => 'Résolvez votre premier cryptogramme';

  @override
  String achDescSolve(int count) {
    return 'Résolvez $count énigmes';
  }

  @override
  String achDescStreak(int count) {
    return 'Atteignez une série de $count jours';
  }

  @override
  String achDescNoHints(int count) {
    return 'Résolvez $count énigmes sans indice';
  }

  @override
  String achDescSpeed(int count) {
    return 'Résolvez une énigme en moins de $count secondes';
  }

  @override
  String achDescDaily(int count) {
    return 'Résolvez $count énigmes quotidiennes';
  }

  @override
  String get achTitleFirstSolve => 'Premier Décryptage';

  @override
  String get achTitleSolve10 => 'Décrypteur Apprenti';

  @override
  String get achTitleSolve25 => 'Briseur de Codes';

  @override
  String get achTitleSolve50 => 'Limier des Chiffres';

  @override
  String get achTitleSolve100 => 'Centurion';

  @override
  String get achTitleSolve250 => 'Maître Cryptologue';

  @override
  String get achTitleSolve500 => 'Grand Maître';

  @override
  String get achTitleStreak3 => 'Échauffement';

  @override
  String get achTitleStreak7 => 'Une Semaine Pleine';

  @override
  String get achTitleStreak14 => 'Quinzaine de Focus';

  @override
  String get achTitleStreak30 => 'Dévouement Mensuel';

  @override
  String get achTitleStreak100 => 'Incassable';

  @override
  String get achTitleStreak365 => 'Décrypteur de l’Année';

  @override
  String get achTitleNoHints10 => 'Puriste';

  @override
  String get achTitleNoHints25 => 'Autonome';

  @override
  String get achTitleNoHints50 => 'Volonté de Fer';

  @override
  String get achTitleNoHints100 => 'Esprit sans Aide';

  @override
  String get achTitleSpeed30 => 'En un Clin d’Œil';

  @override
  String get achTitleSpeed60 => 'Rapide comme l’Éclair';

  @override
  String get achTitleSpeed120 => 'Esprit Vif';

  @override
  String get achTitleDaily10 => 'Rituel Quotidien';

  @override
  String get achTitleDaily25 => 'Solveur Fidèle';

  @override
  String get achTitleDaily50 => 'Café du Matin';

  @override
  String get achTitleDaily100 => 'Cent Matins';

  @override
  String get hintRevealLetter => 'Révéler une lettre';

  @override
  String hintRevealLetterCount(int count) {
    return 'Révéler une lettre ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count indices ajoutés';
  }

  @override
  String get adNoVideo =>
      'Aucune vidéo n’est disponible pour le moment. Réessayez dans un instant.';

  @override
  String get badgeNew => 'NOUVEAU';
}
