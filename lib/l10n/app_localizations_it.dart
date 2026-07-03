// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get aboutThisQuote => 'Su questa citazione';

  @override
  String a11yLetterCellEmpty(String letter) {
    return 'Lettera $letter, vuota';
  }

  @override
  String a11yLetterCellFilled(String letter, String guess) {
    return 'Lettera $letter, risposta $guess';
  }

  @override
  String get a11yDismiss => 'Chiudi';

  @override
  String get a11yBackspace => 'Backspace';

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
  String get highContrastTitle => 'Colori ad alto contrasto';

  @override
  String get highContrastSubtitle =>
      'Testo, bordi ed evidenziazioni più marcati';

  @override
  String get batterySaverTitle => 'Risparmio batteria';

  @override
  String get batterySaverSubtitle =>
      'Limita la frequenza di aggiornamento per risparmiare batteria';

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
  String get vibrationStrength => 'Intensità vibrazione';

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

  @override
  String get startupErrorTitle => 'Quotecrack non è riuscito ad avviarsi';

  @override
  String get startupErrorBody =>
      'Chiudi completamente l\'app e riaprila. Se il problema persiste, reinstallarla lo risolverà.';

  @override
  String get homeDailyLabel => 'ENIGMA DEL GIORNO';

  @override
  String get homeDailySolved => 'Risolto! Torna domani per uno nuovo.';

  @override
  String homeDailyAwaits(String author) {
    return 'Ti aspetta un messaggio cifrato di $author.';
  }

  @override
  String get pressBackAgainToExit => 'Premi di nuovo indietro per uscire';

  @override
  String get homeContinueLabel => 'CONTINUA';

  @override
  String get homeContinueSubtitle => 'Riprendi da dove avevi lasciato';

  @override
  String get continuePlaying => 'Continua';

  @override
  String get playNow => 'Gioca ora';

  @override
  String get replay => 'Rigioca';

  @override
  String get puzzlePacks => 'Pacchetti di enigmi';

  @override
  String packsSolved(int solved, int total) {
    return '$solved su $total risolti';
  }

  @override
  String get statistics => 'Statistiche';

  @override
  String get statisticsSubtitle => 'Serie, tempi e la tua mappa di attività';

  @override
  String get achievements => 'Obiettivi';

  @override
  String achievementsUnlocked(int count) {
    return '$count sbloccati';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Senza pubblicità · indizi illimitati · pacchetti bonus';

  @override
  String get musicToggleTooltip => 'Musica on/off';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Risolvi senza limiti';

  @override
  String get paywallSubhead =>
      'Un solo acquisto. Tuo per sempre. Nessun abbonamento.';

  @override
  String get paywallNoAdsTitle => 'Mai più pubblicità';

  @override
  String get paywallNoAdsBody =>
      'Tutti i banner e gli annunci a schermo intero spariscono';

  @override
  String get paywallHintsTitle => 'Indizi illimitati';

  @override
  String get paywallHintsBody => 'Rivela una lettera ogni volta che ti blocchi';

  @override
  String get paywallPacksTitle => 'Pacchetti bonus esclusivi';

  @override
  String get paywallPacksBody =>
      'Un pacchetto Classici esclusivo di voci senza tempo, e altro in arrivo';

  @override
  String get paywallSupportTitle => 'Sostieni il gioco';

  @override
  String get paywallSupportBody => 'Un acquisto aiuta Quotecrack a crescere';

  @override
  String get paywallActive => 'Premium attivo. Buon divertimento!';

  @override
  String get paywallUnavailable =>
      'Gli acquisti sono disponibili nell’app Android.';

  @override
  String get paywallLoadingPrice => 'Caricamento prezzo…';

  @override
  String paywallUnlock(String price) {
    return 'Sblocca Premium · $price';
  }

  @override
  String get paywallRestore => 'Ripristina l’acquisto precedente';

  @override
  String get premiumUnlockedTitle => 'Premium sbloccato!';

  @override
  String get premiumUnlockedBody =>
      'Niente più pubblicità e indizi illimitati. Grazie per supportare Quotecrack!';

  @override
  String get premiumContinue => 'Inizia a giocare';

  @override
  String get purchaseFailed => 'Acquisto non riuscito. Riprova.';

  @override
  String get purchaseRestoring => 'Ripristino dell’acquisto in corso…';

  @override
  String get completeDailyTitle => 'Enigma del giorno risolto!';

  @override
  String get completeTitle => 'Risolto!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count indizi',
      one: '1 indizio',
      zero: 'Nessun indizio',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie di $count giorni',
      one: 'Serie di 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Obiettivi sbloccati',
      one: 'Obiettivo sbloccato',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Condividi risultato';

  @override
  String get nextPuzzle => 'Prossimo enigma';

  @override
  String get backToMenu => 'Torna al menu';

  @override
  String get reminderNudgeTitle => 'Proteggi la tua serie';

  @override
  String get reminderNudgeBody =>
      'Un promemoria gentile al giorno, così l’enigma di domani non ti sfugge mai. Puoi cambiare l’ora nelle Impostazioni.';

  @override
  String get reminderNudgeNo => 'Non ora';

  @override
  String get packsSectionByDifficulty => 'Per difficoltà';

  @override
  String get packsDifficultyHint =>
      'Controintuitivo ma vero: le citazioni più corte sono le più difficili. Meno lettere significano meno indizi su cui lavorare.';

  @override
  String get packsSectionThemed => 'A tema';

  @override
  String get statsFirstRun =>
      'Risolvi il cifrato di oggi per avviare le tue statistiche e la tua serie.';

  @override
  String get statPuzzlesSolved => 'Enigmi risolti';

  @override
  String get statCurrentStreak => 'Serie attuale';

  @override
  String get statBestStreak => 'Serie migliore';

  @override
  String get statFastestSolve => 'Risoluzione più veloce';

  @override
  String get statNoHintSolves => 'Senza indizi';

  @override
  String get statDailiesSolved => 'Giornalieri risolti';

  @override
  String get statsDailyActivity => 'Attività giornaliera';

  @override
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Ultime $weeks settimane · da $start a $end';
  }

  @override
  String get puzzleAlreadySolved => 'Hai già risolto questo.';

  @override
  String get showSolution => 'Mostra soluzione';

  @override
  String get backToPuzzle => 'Torna al mio tentativo';

  @override
  String get actionPrev => 'Lettera precedente';

  @override
  String get actionNext => 'Lettera successiva';

  @override
  String get actionUndo => 'Annulla';

  @override
  String get actionRedo => 'Ripeti';

  @override
  String get dailyPuzzleTitle => 'Crittogramma del giorno';

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Obiettivi ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Ogni lettera è sostituita';

  @override
  String get onbStep1Body =>
      'In un crittogramma ogni lettera dell’alfabeto ne rappresenta un’altra. La E può essere K, la T può essere A, ma la sostituzione è coerente ovunque.';

  @override
  String get onbStep2Title => 'Risolvilo con gli schemi';

  @override
  String get onbStep2Body =>
      'Le parole corte sono appigli: le lettere più frequenti sono E e A, e parole come IL, LA, E sono ovunque. La frequenza delle lettere è tua amica.';

  @override
  String get onbStep3Title => 'Tocca, poi scrivi';

  @override
  String get onbStep3Body =>
      'Tocca una casella per selezionare quella lettera cifrata, poi scegli la sua lettera reale sulla tastiera. Le lettere identiche si riempiono insieme.';

  @override
  String get onbNext => 'Avanti';

  @override
  String get onbTryOne => 'Provane uno (30 secondi)';

  @override
  String get onbSkip => 'Salta';

  @override
  String get onbDone => 'Fatto';

  @override
  String get replayTutorial => 'Rivedi il tutorial';

  @override
  String get notificationDailyTitle =>
      'Il tuo crittogramma del giorno è pronto';

  @override
  String get notificationDailyBody =>
      'Una nuova citazione aspetta di essere decifrata. Tieni viva la tua serie!';

  @override
  String shareSolvedIn(String time) {
    return 'risolto in $time';
  }

  @override
  String get packTitleBeginner => 'Principiante';

  @override
  String get packTaglineBeginner => 'Citazioni lunghe, cifrari morbidi';

  @override
  String get packTitleCasual => 'Rilassato';

  @override
  String get packTaglineCasual => 'Una sfida comoda';

  @override
  String get packTitleSkilled => 'Esperto';

  @override
  String get packTaglineSkilled => 'Per decifratori allenati';

  @override
  String get packTitleExpert => 'Maestro';

  @override
  String get packTaglineExpert => 'Corto, tagliente, spietato';

  @override
  String get packTitleShortSweet => 'Brevi e Concise';

  @override
  String get packTaglineShortSweet => 'Citazioni brevi per una vittoria veloce';

  @override
  String get packTitleProverbs => 'Proverbi';

  @override
  String get packTaglineProverbs => 'La saggezza popolare del mondo';

  @override
  String get packTitleWisdom => 'Saggezza';

  @override
  String get packTaglineWisdom => 'Pensatori e statisti';

  @override
  String get packTitleLiterature => 'Letteratura';

  @override
  String get packTaglineLiterature => 'Versi dai grandi libri';

  @override
  String get packTitleWit => 'Arguzia';

  @override
  String get packTaglineWit => 'Battute argute e frecciate';

  @override
  String get packTitleClassics => 'Classici';

  @override
  String get packTaglineClassics => 'Voci senza tempo, scelte a mano';

  @override
  String get packTitleInspire => 'Cuore e Coraggio';

  @override
  String get packTaglineInspire => 'Proverbi d\'amore, amicizia e tenacia';

  @override
  String get achDescFirst => 'Risolvi il tuo primo crittogramma';

  @override
  String achDescSolve(int count) {
    return 'Risolvi $count enigmi';
  }

  @override
  String achDescStreak(int count) {
    return 'Raggiungi una serie di $count giorni';
  }

  @override
  String achDescNoHints(int count) {
    return 'Risolvi $count enigmi senza indizi';
  }

  @override
  String achDescSpeed(int count) {
    return 'Risolvi un enigma in meno di $count secondi';
  }

  @override
  String achDescDaily(int count) {
    return 'Risolvi $count enigmi giornalieri';
  }

  @override
  String get achTitleFirstSolve => 'Prima Decifrazione';

  @override
  String get achTitleSolve10 => 'Decifratore Apprendista';

  @override
  String get achTitleSolve25 => 'Forzatore di Codici';

  @override
  String get achTitleSolve50 => 'Segugio dei Cifrari';

  @override
  String get achTitleSolve100 => 'Centurione';

  @override
  String get achTitleSolve250 => 'Maestro Crittologo';

  @override
  String get achTitleSolve500 => 'Gran Maestro';

  @override
  String get achTitleStreak3 => 'Riscaldamento';

  @override
  String get achTitleStreak7 => 'Una Settimana Intera';

  @override
  String get achTitleStreak14 => 'Due Settimane di Focus';

  @override
  String get achTitleStreak30 => 'Devozione Mensile';

  @override
  String get achTitleStreak100 => 'Infrangibile';

  @override
  String get achTitleStreak365 => 'Decifratore di Tutto l’Anno';

  @override
  String get achTitleNoHints10 => 'Purista';

  @override
  String get achTitleNoHints25 => 'Autosufficiente';

  @override
  String get achTitleNoHints50 => 'Volontà di Ferro';

  @override
  String get achTitleNoHints100 => 'Mente senza Aiuto';

  @override
  String get achTitleSpeed30 => 'In un Batter d’Occhio';

  @override
  String get achTitleSpeed60 => 'Veloce come un Fulmine';

  @override
  String get achTitleSpeed120 => 'Pensatore Rapido';

  @override
  String get achTitleDaily10 => 'Rituale Quotidiano';

  @override
  String get achTitleDaily25 => 'Solutore Fedele';

  @override
  String get achTitleDaily50 => 'Caffè del Mattino';

  @override
  String get achTitleDaily100 => 'Cento Mattine';

  @override
  String get hintRevealLetter => 'Rivela una lettera';

  @override
  String hintRevealLetterCount(int count) {
    return 'Rivela una lettera ($count)';
  }

  @override
  String get hintRevealWord => 'Rivela la parola';

  @override
  String hintRevealWordCost(int count) {
    return 'Rivela la parola (-$count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count indizi aggiunti';
  }

  @override
  String get adNoVideo =>
      'Nessun video disponibile al momento. Riprova tra poco.';

  @override
  String get badgeNew => 'NUOVO';

  @override
  String get updateReadyBody =>
      'Aggiornamento scaricato: riavvia Quotecrack per applicarlo.';

  @override
  String get updateRestartAction => 'Riavvia';
}
