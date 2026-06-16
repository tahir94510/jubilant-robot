// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get sectionGameplay => 'Gameplay';

  @override
  String get sectionDailyReminder => 'Daily reminder';

  @override
  String get sectionPremium => 'Premium';

  @override
  String get sectionPrivacyAbout => 'Privacy & about';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageSystem => 'System default';

  @override
  String get theme => 'Theme';

  @override
  String get themeAutoSubtitle => 'Auto (follows your device)';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get textSize => 'Text size';

  @override
  String get colorblindTitle => 'Colorblind-friendly colors';

  @override
  String get colorblindSubtitle => 'Blue/orange highlights instead of red';

  @override
  String get errorCheckingTitle => 'Error checking';

  @override
  String get errorCheckingSubtitle =>
      'Mark wrong letters once the board is full';

  @override
  String get showTimerTitle => 'Show timer';

  @override
  String get showTimerSubtitle => 'Turn off for a fully zen experience';

  @override
  String get hapticsTitle => 'Haptic feedback';

  @override
  String get soundEffectsTitle => 'Sound effects';

  @override
  String get soundEffectsSubtitle => 'Soft key taps and gentle chimes';

  @override
  String get effectsVolume => 'Effects volume';

  @override
  String get musicTitle => 'Music';

  @override
  String get musicSubtitle => 'Calm ambient loop while you play';

  @override
  String get musicVolume => 'Music volume';

  @override
  String get remindMeDaily => 'Remind me daily';

  @override
  String reminderAt(String time) {
    return 'At $time';
  }

  @override
  String get neverMissStreak => 'Never miss your streak';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderDenied =>
      'Notification permission was denied in system settings.';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveSubtitle => 'Thank you for supporting Quotecrack!';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get goPremiumSubtitle => 'Remove ads, unlimited hints, bonus packs';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get checkingPurchases => 'Checking previous purchases…';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get privacyOptionsSubtitle => 'Manage your ad consent choices';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get version => 'Version';

  @override
  String get homeDailyLabel => 'DAILY PUZZLE';

  @override
  String get homeDailySolved => 'Solved! Come back tomorrow for a new one.';

  @override
  String homeDailyAwaits(String author) {
    return 'A cipher by $author awaits.';
  }

  @override
  String get playNow => 'Play now';

  @override
  String get replay => 'Replay';

  @override
  String get puzzlePacks => 'Puzzle packs';

  @override
  String packsSolved(int solved, int total) {
    return '$solved of $total solved';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsSubtitle => 'Streaks, times, and your heatmap';

  @override
  String get achievements => 'Achievements';

  @override
  String achievementsUnlocked(int count) {
    return '$count unlocked';
  }

  @override
  String get goPremiumSubtitleHome =>
      'Remove ads · unlimited hints · bonus packs';

  @override
  String get musicToggleTooltip => 'Music on/off';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get paywallTitle => 'Quotecrack Premium';

  @override
  String get paywallHeadline => 'Solve without limits';

  @override
  String get paywallSubhead => 'One purchase. Yours forever. No subscription.';

  @override
  String get paywallNoAdsTitle => 'No ads, ever';

  @override
  String get paywallNoAdsBody => 'Every banner and full-screen ad, gone';

  @override
  String get paywallHintsTitle => 'Unlimited hints';

  @override
  String get paywallHintsBody => 'Reveal a letter whenever you\'re stuck';

  @override
  String get paywallPacksTitle => 'Exclusive bonus packs';

  @override
  String get paywallPacksBody =>
      'Shakespeare, Stoic wisdom, and more on the way';

  @override
  String get paywallSupportTitle => 'Support the game';

  @override
  String get paywallSupportBody => 'One purchase helps Quotecrack keep growing';

  @override
  String get paywallActive => 'Premium active. Enjoy!';

  @override
  String get paywallUnavailable =>
      'Purchases are available in the Android app.';

  @override
  String get paywallLoadingPrice => 'Loading price…';

  @override
  String paywallUnlock(String price) {
    return 'Unlock Premium · $price';
  }

  @override
  String get paywallRestore => 'Restore previous purchase';

  @override
  String get completeDailyTitle => 'Daily solved!';

  @override
  String get completeTitle => 'Solved!';

  @override
  String solveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hints',
      one: '1 hint',
      zero: 'No hints',
    );
    return '$_temp0';
  }

  @override
  String solveStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String achievementsUnlockedHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Achievements unlocked',
      one: 'Achievement unlocked',
    );
    return '$_temp0';
  }

  @override
  String get shareResult => 'Share result';

  @override
  String get nextPuzzle => 'Next puzzle';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get reminderNudgeTitle => 'Protect your streak';

  @override
  String get reminderNudgeBody =>
      'One gentle nudge a day, so tomorrow\'s puzzle never slips by. You can change the time in Settings.';

  @override
  String get reminderNudgeNo => 'Not now';

  @override
  String get reminderNudgeDenied =>
      'Notification permission was denied. You can enable it anytime in Settings.';

  @override
  String get packsSectionByDifficulty => 'By difficulty';

  @override
  String get packsDifficultyHint =>
      'Counterintuitive but true: shorter quotes are the hardest. Fewer letters mean fewer clues to work from.';

  @override
  String get packsSectionThemed => 'Themed';

  @override
  String get statsFirstRun =>
      'Crack today\'s cipher to start your stats and streak.';

  @override
  String get statPuzzlesSolved => 'Puzzles solved';

  @override
  String get statCurrentStreak => 'Current streak';

  @override
  String get statBestStreak => 'Best streak';

  @override
  String get statFastestSolve => 'Fastest solve';

  @override
  String get statNoHintSolves => 'No-hint solves';

  @override
  String get statDailiesSolved => 'Dailies solved';

  @override
  String get statsDailyActivity => 'Daily activity';

  @override
  String statsHeatmapCaption(int weeks, String start, String end) {
    return 'Last $weeks weeks · $start to $end';
  }

  @override
  String achievementsCountTitle(int unlocked, int total) {
    return 'Achievements ($unlocked/$total)';
  }

  @override
  String get onbStep1Title => 'Every letter is swapped';

  @override
  String get onbStep1Body =>
      'In a cryptogram, each letter of the alphabet stands for a different one. E might be K, T might be A, but the swap is consistent everywhere.';

  @override
  String get onbStep2Title => 'Crack it with patterns';

  @override
  String get onbStep2Body =>
      'Short words are footholds: a single letter is usually A or I, and THE is everywhere. Letter frequency is your friend.';

  @override
  String get onbStep3Title => 'Tap, then type';

  @override
  String get onbStep3Body =>
      'Tap any cell to select that cipher letter, then choose its real letter on the keyboard. Identical letters fill in together.';

  @override
  String get onbNext => 'Next';

  @override
  String get onbTryOne => 'Try one (30 seconds)';

  @override
  String get onbSkip => 'Skip';

  @override
  String get notificationDailyTitle => 'Your daily cryptogram is ready';

  @override
  String get notificationDailyBody =>
      'A fresh quote is waiting to be decoded. Keep your streak alive!';

  @override
  String shareSolvedIn(String time) {
    return 'solved in $time';
  }

  @override
  String get packTitleBeginner => 'Beginner';

  @override
  String get packTaglineBeginner => 'Long quotes, gentle ciphers';

  @override
  String get packTitleCasual => 'Casual';

  @override
  String get packTaglineCasual => 'A comfortable challenge';

  @override
  String get packTitleSkilled => 'Skilled';

  @override
  String get packTaglineSkilled => 'For practiced decoders';

  @override
  String get packTitleExpert => 'Expert';

  @override
  String get packTaglineExpert => 'Short, sharp, unforgiving';

  @override
  String get packTitleProverbs => 'Proverbs';

  @override
  String get packTaglineProverbs => 'Folk wisdom of the world';

  @override
  String get packTitleHumor => 'Humor';

  @override
  String get packTaglineHumor => 'Wit from Twain to Wilde';

  @override
  String get packTitleWisdom => 'Wisdom';

  @override
  String get packTaglineWisdom => 'Thinkers and statesmen';

  @override
  String get packTitleLiterature => 'Literature';

  @override
  String get packTaglineLiterature => 'Lines from great books';

  @override
  String get packTitleScience => 'Science';

  @override
  String get packTaglineScience => 'Minds that moved the world';

  @override
  String get packTitleShakespeare => 'Shakespeare';

  @override
  String get packTaglineShakespeare => 'The Bard, uncut';

  @override
  String get packTitleStoic => 'Stoic Wisdom';

  @override
  String get packTaglineStoic => 'Marcus, Seneca, Epictetus';

  @override
  String get achDescFirst => 'Solve your first cryptogram';

  @override
  String achDescSolve(int count) {
    return 'Solve $count puzzles';
  }

  @override
  String achDescStreak(int count) {
    return 'Reach a $count-day daily streak';
  }

  @override
  String achDescNoHints(int count) {
    return 'Solve $count puzzles without hints';
  }

  @override
  String achDescSpeed(int count) {
    return 'Solve a puzzle in under $count seconds';
  }

  @override
  String achDescDaily(int count) {
    return 'Solve $count daily puzzles';
  }

  @override
  String get achTitleFirstSolve => 'First Crack';

  @override
  String get achTitleSolve10 => 'Apprentice Decoder';

  @override
  String get achTitleSolve25 => 'Code Breaker';

  @override
  String get achTitleSolve50 => 'Cipher Sleuth';

  @override
  String get achTitleSolve100 => 'Centurion';

  @override
  String get achTitleSolve250 => 'Master Cryptologist';

  @override
  String get achTitleSolve500 => 'Grandmaster';

  @override
  String get achTitleStreak3 => 'Warming Up';

  @override
  String get achTitleStreak7 => 'One Solid Week';

  @override
  String get achTitleStreak14 => 'Fortnight Focus';

  @override
  String get achTitleStreak30 => 'Monthly Devotion';

  @override
  String get achTitleStreak100 => 'Unbreakable';

  @override
  String get achTitleStreak365 => 'Year-Round Decoder';

  @override
  String get achTitleNoHints10 => 'Purist';

  @override
  String get achTitleNoHints25 => 'Self-Reliant';

  @override
  String get achTitleNoHints50 => 'Iron Will';

  @override
  String get achTitleNoHints100 => 'Unaided Mind';

  @override
  String get achTitleSpeed30 => 'Blink of an Eye';

  @override
  String get achTitleSpeed60 => 'Lightning Fast';

  @override
  String get achTitleSpeed120 => 'Quick Thinker';

  @override
  String get achTitleDaily10 => 'Daily Ritual';

  @override
  String get achTitleDaily25 => 'Faithful Solver';

  @override
  String get achTitleDaily50 => 'Morning Coffee';

  @override
  String get achTitleDaily100 => 'Hundred Mornings';

  @override
  String get packsSectionLanguages => 'Languages';

  @override
  String get packTitleTurkish => 'Türkçe';

  @override
  String get packTaglineTurkish => 'Turkish proverbs & sayings';

  @override
  String get packTitleSpanish => 'Español';

  @override
  String get packTaglineSpanish => 'Spanish proverbs & sayings';

  @override
  String get packTitleGerman => 'Deutsch';

  @override
  String get packTaglineGerman => 'German proverbs & sayings';

  @override
  String get packTitleFrench => 'Français';

  @override
  String get packTaglineFrench => 'French proverbs & sayings';

  @override
  String get packTitleItalian => 'Italiano';

  @override
  String get packTaglineItalian => 'Italian proverbs & sayings';

  @override
  String get packTitlePortuguese => 'Português';

  @override
  String get packTaglinePortuguese => 'Portuguese proverbs & sayings';

  @override
  String get hintRevealLetter => 'Reveal letter';

  @override
  String hintRevealLetterCount(int count) {
    return 'Reveal letter ($count)';
  }

  @override
  String hintTokensAdded(int count) {
    return '+$count hints added';
  }

  @override
  String get adNoVideo =>
      'No video is available right now. Please try again in a moment.';
}
