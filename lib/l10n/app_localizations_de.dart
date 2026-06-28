// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutThisQuote => 'Über dieses Zitat';

  @override
  String a11yLetterCellEmpty(String letter) {
    return 'Buchstabe $letter, leer';
  }

  @override
  String a11yLetterCellFilled(String letter, String guess) {
    return 'Buchstabe $letter, Antwort $guess';
  }

  @override
  String get a11yDismiss => 'Schließen';

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
  String get vibrationStrength => 'Vibrationsstärke';

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
  String get startupErrorTitle => 'Quotecrack konnte nicht starten';

  @override
  String get startupErrorBody =>
      'Bitte schließe die App vollständig und öffne sie erneut. Falls das Problem weiterhin auftritt, behebt eine Neuinstallation es.';

  @override
  String get homeDailyLabel => 'TÄGLICHES RÄTSEL';

  @override
  String get homeDailySolved => 'Gelöst! Komm morgen für ein neues wieder.';

  @override
  String homeDailyAwaits(String author) {
    return 'Ein Geheimtext von $author wartet auf dich.';
  }

  @override
  String get pressBackAgainToExit => 'Zum Beenden erneut „Zurück“ drücken';

  @override
  String get homeContinueLabel => 'FORTSETZEN';

  @override
  String get homeContinueSubtitle => 'Mach dort weiter, wo du aufgehört hast';

  @override
  String get continuePlaying => 'Fortsetzen';

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
      'Ein exklusives Klassiker-Paket mit zeitlosen Stimmen, und mehr ist unterwegs';

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
  String get premiumUnlockedTitle => 'Premium freigeschaltet!';

  @override
  String get premiumUnlockedBody =>
      'Keine Werbung mehr und unbegrenzte Hinweise. Danke, dass du Quotecrack unterstützt!';

  @override
  String get premiumContinue => 'Losspielen';

  @override
  String get purchaseFailed =>
      'Kauf konnte nicht abgeschlossen werden. Bitte erneut versuchen.';

  @override
  String get purchaseRestoring => 'Kauf wird wiederhergestellt…';

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
  String get packsSectionByDifficulty => 'Nach Schwierigkeit';

  @override
  String get packsDifficultyHint =>
      'Überraschend, aber wahr: Kürzere Zitate sind die schwersten. Weniger Buchstaben bedeuten weniger Anhaltspunkte.';

  @override
  String get packsSectionThemed => 'Themen';

  @override
  String get statsFirstRun =>
      'Löse das heutige Rätsel, um deine Statistik und Serie zu starten.';

  @override
  String get statPuzzlesSolved => 'Gelöste Rätsel';

  @override
  String get statCurrentStreak => 'Aktuelle Serie';

  @override
  String get statBestStreak => 'Beste Serie';

  @override
  String get statFastestSolve => 'Schnellste Lösung';

  @override
  String get statNoHintSolves => 'Ohne Hinweise';

  @override
  String get statDailiesSolved => 'Gelöste Tagesrätsel';

  @override
  String get statsDailyActivity => 'Tägliche Aktivität';

  @override
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Letzte $weeks Wochen · $start bis $end';
  }

  @override
  String get puzzleAlreadySolved => 'Das hast du schon geknackt.';

  @override
  String get showSolution => 'Lösung anzeigen';

  @override
  String get backToPuzzle => 'Zurück zu meinem Versuch';

  @override
  String get actionPrev => 'Vorheriger Buchstabe';

  @override
  String get actionNext => 'Nächster Buchstabe';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionRedo => 'Wiederholen';

  @override
  String get dailyPuzzleTitle => 'Tägliches Rätsel';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Erfolge ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Jeder Buchstabe ist vertauscht';

  @override
  String get onbStep1Body =>
      'In einem Kryptogramm steht jeder Buchstabe des Alphabets für einen anderen. E kann K sein, T kann A sein, aber die Ersetzung ist überall gleich.';

  @override
  String get onbStep2Title => 'Knack es mit Mustern';

  @override
  String get onbStep2Body =>
      'Kurze Wörter sind Stützen: häufige Buchstaben sind E und N, und Wörter wie DER, DIE und UND tauchen überall auf. Buchstabenhäufigkeit ist dein Freund.';

  @override
  String get onbStep3Title => 'Tippen, dann eingeben';

  @override
  String get onbStep3Body =>
      'Tippe auf eine Zelle, um diesen Geheimbuchstaben auszuwählen, und wähle dann seinen echten Buchstaben auf der Tastatur. Gleiche Buchstaben füllen sich gemeinsam.';

  @override
  String get onbNext => 'Weiter';

  @override
  String get onbTryOne => 'Probier eins (30 Sekunden)';

  @override
  String get onbSkip => 'Überspringen';

  @override
  String get onbDone => 'Fertig';

  @override
  String get replayTutorial => 'Tutorial wiederholen';

  @override
  String get notificationDailyTitle => 'Dein Tagesrätsel ist bereit';

  @override
  String get notificationDailyBody =>
      'Ein neues Zitat wartet darauf, entschlüsselt zu werden. Halte deine Serie am Leben!';

  @override
  String shareSolvedIn(String time) {
    return 'gelöst in $time';
  }

  @override
  String get packTitleBeginner => 'Anfänger';

  @override
  String get packTaglineBeginner => 'Lange Zitate, sanfte Chiffren';

  @override
  String get packTitleCasual => 'Locker';

  @override
  String get packTaglineCasual => 'Eine angenehme Herausforderung';

  @override
  String get packTitleSkilled => 'Geübt';

  @override
  String get packTaglineSkilled => 'Für geübte Entschlüssler';

  @override
  String get packTitleExpert => 'Experte';

  @override
  String get packTaglineExpert => 'Kurz, scharf, gnadenlos';

  @override
  String get packTitleShortSweet => 'Kurz & Knackig';

  @override
  String get packTaglineShortSweet =>
      'Kleine Zitate für einen schnellen Erfolg';

  @override
  String get packTitleProverbs => 'Sprichwörter';

  @override
  String get packTaglineProverbs => 'Volksweisheit aus aller Welt';

  @override
  String get packTitleWisdom => 'Weisheit';

  @override
  String get packTaglineWisdom => 'Denker und Staatsmänner';

  @override
  String get packTitleLiterature => 'Literatur';

  @override
  String get packTaglineLiterature => 'Zeilen aus großen Büchern';

  @override
  String get packTitleWit => 'Witz';

  @override
  String get packTaglineWit => 'Scharfzüngig und schlagfertig';

  @override
  String get packTitleClassics => 'Klassiker';

  @override
  String get packTaglineClassics => 'Zeitlose Stimmen, handverlesen';

  @override
  String get packTitleInspire => 'Herz & Mut';

  @override
  String get packTaglineInspire =>
      'Sprichwörter über Liebe, Freundschaft und Ausdauer';

  @override
  String get achDescFirst => 'Löse dein erstes Kryptogramm';

  @override
  String achDescSolve(int count) {
    return 'Löse $count Rätsel';
  }

  @override
  String achDescStreak(int count) {
    return 'Erreiche eine Serie von $count Tagen';
  }

  @override
  String achDescNoHints(int count) {
    return 'Löse $count Rätsel ohne Hinweise';
  }

  @override
  String achDescSpeed(int count) {
    return 'Löse ein Rätsel in unter $count Sekunden';
  }

  @override
  String achDescDaily(int count) {
    return 'Löse $count Tagesrätsel';
  }

  @override
  String get achTitleFirstSolve => 'Erster Knacker';

  @override
  String get achTitleSolve10 => 'Entschlüssler-Lehrling';

  @override
  String get achTitleSolve25 => 'Codeknacker';

  @override
  String get achTitleSolve50 => 'Chiffren-Spürhund';

  @override
  String get achTitleSolve100 => 'Zenturio';

  @override
  String get achTitleSolve250 => 'Meister-Kryptologe';

  @override
  String get achTitleSolve500 => 'Großmeister';

  @override
  String get achTitleStreak3 => 'Aufwärmen';

  @override
  String get achTitleStreak7 => 'Eine ganze Woche';

  @override
  String get achTitleStreak14 => 'Zwei Wochen Fokus';

  @override
  String get achTitleStreak30 => 'Monatliche Hingabe';

  @override
  String get achTitleStreak100 => 'Unzerbrechlich';

  @override
  String get achTitleStreak365 => 'Ganzjahres-Entschlüssler';

  @override
  String get achTitleNoHints10 => 'Purist';

  @override
  String get achTitleNoHints25 => 'Eigenständig';

  @override
  String get achTitleNoHints50 => 'Eiserner Wille';

  @override
  String get achTitleNoHints100 => 'Geist ohne Hilfe';

  @override
  String get achTitleSpeed30 => 'Im Handumdrehen';

  @override
  String get achTitleSpeed60 => 'Blitzschnell';

  @override
  String get achTitleSpeed120 => 'Schnelldenker';

  @override
  String get achTitleDaily10 => 'Tägliches Ritual';

  @override
  String get achTitleDaily25 => 'Treuer Löser';

  @override
  String get achTitleDaily50 => 'Morgenkaffee';

  @override
  String get achTitleDaily100 => 'Hundert Morgen';

  @override
  String get hintRevealLetter => 'Buchstabe aufdecken';

  @override
  String hintRevealLetterCount(int count) {
    return 'Buchstabe aufdecken ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count Hinweise hinzugefügt';
  }

  @override
  String get adNoVideo =>
      'Gerade ist kein Video verfügbar. Bitte versuche es gleich noch einmal.';

  @override
  String get badgeNew => 'NEU';
}
