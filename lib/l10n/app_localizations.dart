import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('tr'),
  ];

  /// No description provided for @aboutThisQuote.
  ///
  /// In en, this message translates to:
  /// **'About this quote'**
  String get aboutThisQuote;

  /// No description provided for @a11yLetterCellEmpty.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}, empty'**
  String a11yLetterCellEmpty(String letter);

  /// No description provided for @a11yLetterCellFilled.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}, answer {guess}'**
  String a11yLetterCellFilled(String letter, String guess);

  /// No description provided for @a11yDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get a11yDismiss;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @sectionGameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get sectionGameplay;

  /// No description provided for @sectionDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get sectionDailyReminder;

  /// No description provided for @sectionPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get sectionPremium;

  /// No description provided for @sectionPrivacyAbout.
  ///
  /// In en, this message translates to:
  /// **'Privacy & about'**
  String get sectionPrivacyAbout;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto (follows your device)'**
  String get themeAutoSubtitle;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get themeSepia;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @colorblindTitle.
  ///
  /// In en, this message translates to:
  /// **'Colorblind-friendly colors'**
  String get colorblindTitle;

  /// No description provided for @colorblindSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Blue/orange highlights instead of red'**
  String get colorblindSubtitle;

  /// No description provided for @errorCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Error checking'**
  String get errorCheckingTitle;

  /// No description provided for @errorCheckingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark wrong letters once the board is full'**
  String get errorCheckingSubtitle;

  /// No description provided for @showTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Show timer'**
  String get showTimerTitle;

  /// No description provided for @showTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off for a fully zen experience'**
  String get showTimerSubtitle;

  /// No description provided for @hapticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticsTitle;

  /// No description provided for @vibrationStrength.
  ///
  /// In en, this message translates to:
  /// **'Vibration strength'**
  String get vibrationStrength;

  /// No description provided for @soundEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffectsTitle;

  /// No description provided for @soundEffectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Soft key taps and gentle chimes'**
  String get soundEffectsSubtitle;

  /// No description provided for @effectsVolume.
  ///
  /// In en, this message translates to:
  /// **'Effects volume'**
  String get effectsVolume;

  /// No description provided for @musicTitle.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicTitle;

  /// No description provided for @musicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calm ambient loop while you play'**
  String get musicSubtitle;

  /// No description provided for @musicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get musicVolume;

  /// No description provided for @remindMeDaily.
  ///
  /// In en, this message translates to:
  /// **'Remind me daily'**
  String get remindMeDaily;

  /// No description provided for @reminderAt.
  ///
  /// In en, this message translates to:
  /// **'At {time}'**
  String reminderAt(String time);

  /// No description provided for @neverMissStreak.
  ///
  /// In en, this message translates to:
  /// **'Never miss your streak'**
  String get neverMissStreak;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @premiumActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Quotecrack!'**
  String get premiumActiveSubtitle;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @goPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove ads, unlimited hints, bonus packs'**
  String get goPremiumSubtitle;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @checkingPurchases.
  ///
  /// In en, this message translates to:
  /// **'Checking previous purchases…'**
  String get checkingPurchases;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get privacyOptions;

  /// No description provided for @privacyOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your ad consent choices'**
  String get privacyOptionsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Quotecrack couldn\'t start'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please close the app fully and open it again. If this keeps happening, reinstalling will fix it.'**
  String get startupErrorBody;

  /// No description provided for @homeDailyLabel.
  ///
  /// In en, this message translates to:
  /// **'DAILY PUZZLE'**
  String get homeDailyLabel;

  /// No description provided for @homeDailySolved.
  ///
  /// In en, this message translates to:
  /// **'Solved! Come back tomorrow for a new one.'**
  String get homeDailySolved;

  /// No description provided for @homeDailyAwaits.
  ///
  /// In en, this message translates to:
  /// **'A cipher by {author} awaits.'**
  String homeDailyAwaits(String author);

  /// Shown as a snackbar when the player presses the system back button once on the home screen; a second press within ~2s exits the app.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @homeContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get homeContinueLabel;

  /// No description provided for @homeContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get homeContinueSubtitle;

  /// No description provided for @continuePlaying.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuePlaying;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get playNow;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @puzzlePacks.
  ///
  /// In en, this message translates to:
  /// **'Puzzle packs'**
  String get puzzlePacks;

  /// No description provided for @packsSolved.
  ///
  /// In en, this message translates to:
  /// **'{solved} of {total} solved'**
  String packsSolved(int solved, int total);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks, times, and your heatmap'**
  String get statisticsSubtitle;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} unlocked'**
  String achievementsUnlocked(int count);

  /// No description provided for @goPremiumSubtitleHome.
  ///
  /// In en, this message translates to:
  /// **'Remove ads · unlimited hints · bonus packs'**
  String get goPremiumSubtitleHome;

  /// No description provided for @musicToggleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Music on/off'**
  String get musicToggleTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Quotecrack Premium'**
  String get paywallTitle;

  /// No description provided for @paywallHeadline.
  ///
  /// In en, this message translates to:
  /// **'Solve without limits'**
  String get paywallHeadline;

  /// No description provided for @paywallSubhead.
  ///
  /// In en, this message translates to:
  /// **'One purchase. Yours forever. No subscription.'**
  String get paywallSubhead;

  /// No description provided for @paywallNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get paywallNoAdsTitle;

  /// No description provided for @paywallNoAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Every banner and full-screen ad, gone'**
  String get paywallNoAdsBody;

  /// No description provided for @paywallHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited hints'**
  String get paywallHintsTitle;

  /// No description provided for @paywallHintsBody.
  ///
  /// In en, this message translates to:
  /// **'Reveal a letter whenever you\'re stuck'**
  String get paywallHintsBody;

  /// No description provided for @paywallPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive bonus packs'**
  String get paywallPacksTitle;

  /// No description provided for @paywallPacksBody.
  ///
  /// In en, this message translates to:
  /// **'An exclusive Classics pack of timeless voices, with more on the way'**
  String get paywallPacksBody;

  /// No description provided for @paywallSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support the game'**
  String get paywallSupportTitle;

  /// No description provided for @paywallSupportBody.
  ///
  /// In en, this message translates to:
  /// **'One purchase helps Quotecrack keep growing'**
  String get paywallSupportBody;

  /// No description provided for @paywallActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active. Enjoy!'**
  String get paywallActive;

  /// No description provided for @paywallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are available in the Android app.'**
  String get paywallUnavailable;

  /// No description provided for @paywallLoadingPrice.
  ///
  /// In en, this message translates to:
  /// **'Loading price…'**
  String get paywallLoadingPrice;

  /// No description provided for @paywallUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium · {price}'**
  String paywallUnlock(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore previous purchase'**
  String get paywallRestore;

  /// Headline of the celebratory overlay shown the moment a premium purchase or restore completes.
  ///
  /// In en, this message translates to:
  /// **'Premium unlocked!'**
  String get premiumUnlockedTitle;

  /// Warm one-line reassurance under the premium-unlocked headline.
  ///
  /// In en, this message translates to:
  /// **'Ads are gone for good and hints are unlimited. Thank you for supporting Quotecrack!'**
  String get premiumUnlockedBody;

  /// Button on the premium-unlocked overlay that dismisses it and returns to the game.
  ///
  /// In en, this message translates to:
  /// **'Start playing'**
  String get premiumContinue;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase couldn\'t be completed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @purchaseRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring your purchase…'**
  String get purchaseRestoring;

  /// No description provided for @completeDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily solved!'**
  String get completeDailyTitle;

  /// No description provided for @completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get completeTitle;

  /// No description provided for @solveHints.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No hints} =1{1 hint} other{{count} hints}}'**
  String solveHints(int count);

  /// No description provided for @solveStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String solveStreak(int count);

  /// No description provided for @achievementsUnlockedHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Achievement unlocked} other{Achievements unlocked}}'**
  String achievementsUnlockedHeader(int count);

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get shareResult;

  /// No description provided for @nextPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Next puzzle'**
  String get nextPuzzle;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @reminderNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your streak'**
  String get reminderNudgeTitle;

  /// No description provided for @reminderNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'One gentle nudge a day, so tomorrow\'s puzzle never slips by. You can change the time in Settings.'**
  String get reminderNudgeBody;

  /// No description provided for @reminderNudgeNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get reminderNudgeNo;

  /// No description provided for @packsSectionByDifficulty.
  ///
  /// In en, this message translates to:
  /// **'By difficulty'**
  String get packsSectionByDifficulty;

  /// No description provided for @packsDifficultyHint.
  ///
  /// In en, this message translates to:
  /// **'Counterintuitive but true: shorter quotes are the hardest. Fewer letters mean fewer clues to work from.'**
  String get packsDifficultyHint;

  /// No description provided for @packsSectionThemed.
  ///
  /// In en, this message translates to:
  /// **'Themed'**
  String get packsSectionThemed;

  /// No description provided for @statsFirstRun.
  ///
  /// In en, this message translates to:
  /// **'Crack today\'s cipher to start your stats and streak.'**
  String get statsFirstRun;

  /// No description provided for @statPuzzlesSolved.
  ///
  /// In en, this message translates to:
  /// **'Puzzles solved'**
  String get statPuzzlesSolved;

  /// No description provided for @statCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statCurrentStreak;

  /// No description provided for @statBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statBestStreak;

  /// No description provided for @statFastestSolve.
  ///
  /// In en, this message translates to:
  /// **'Fastest solve'**
  String get statFastestSolve;

  /// No description provided for @statNoHintSolves.
  ///
  /// In en, this message translates to:
  /// **'No-hint solves'**
  String get statNoHintSolves;

  /// No description provided for @statDailiesSolved.
  ///
  /// In en, this message translates to:
  /// **'Dailies solved'**
  String get statDailiesSolved;

  /// No description provided for @statsDailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily activity'**
  String get statsDailyActivity;

  /// No description provided for @statsHeatmapCaption.
  ///
  /// In en, this message translates to:
  /// **'Last {weeks} weeks · {start} to {end}'**
  String statsHeatmapCaption(int weeks, String start, String end);

  /// No description provided for @puzzleAlreadySolved.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already cracked this one.'**
  String get puzzleAlreadySolved;

  /// No description provided for @showSolution.
  ///
  /// In en, this message translates to:
  /// **'Show solution'**
  String get showSolution;

  /// No description provided for @backToPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Back to my attempt'**
  String get backToPuzzle;

  /// No description provided for @actionPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous letter'**
  String get actionPrev;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next letter'**
  String get actionNext;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get actionRedo;

  /// No description provided for @dailyPuzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily puzzle'**
  String get dailyPuzzleTitle;

  /// No description provided for @achievementsCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements ({unlocked}/{total})'**
  String achievementsCountTitle(int unlocked, int total);

  /// No description provided for @onbStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Every letter is swapped'**
  String get onbStep1Title;

  /// No description provided for @onbStep1Body.
  ///
  /// In en, this message translates to:
  /// **'In a cryptogram, each letter of the alphabet stands for a different one. E might be K, T might be A, but the swap is consistent everywhere.'**
  String get onbStep1Body;

  /// No description provided for @onbStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Crack it with patterns'**
  String get onbStep2Title;

  /// No description provided for @onbStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Short words are footholds: a single letter is usually A or I, and THE is everywhere. Letter frequency is your friend.'**
  String get onbStep2Body;

  /// No description provided for @onbStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Tap, then type'**
  String get onbStep3Title;

  /// No description provided for @onbStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Tap any cell to select that cipher letter, then choose its real letter on the keyboard. Identical letters fill in together.'**
  String get onbStep3Body;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbTryOne.
  ///
  /// In en, this message translates to:
  /// **'Try one (30 seconds)'**
  String get onbTryOne;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onbDone;

  /// No description provided for @replayTutorial.
  ///
  /// In en, this message translates to:
  /// **'Replay tutorial'**
  String get replayTutorial;

  /// No description provided for @notificationDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your daily cryptogram is ready'**
  String get notificationDailyTitle;

  /// No description provided for @notificationDailyBody.
  ///
  /// In en, this message translates to:
  /// **'A fresh quote is waiting to be decoded. Keep your streak alive!'**
  String get notificationDailyBody;

  /// No description provided for @shareSolvedIn.
  ///
  /// In en, this message translates to:
  /// **'solved in {time}'**
  String shareSolvedIn(String time);

  /// No description provided for @packTitleBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get packTitleBeginner;

  /// No description provided for @packTaglineBeginner.
  ///
  /// In en, this message translates to:
  /// **'Long quotes, gentle ciphers'**
  String get packTaglineBeginner;

  /// No description provided for @packTitleCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get packTitleCasual;

  /// No description provided for @packTaglineCasual.
  ///
  /// In en, this message translates to:
  /// **'A comfortable challenge'**
  String get packTaglineCasual;

  /// No description provided for @packTitleSkilled.
  ///
  /// In en, this message translates to:
  /// **'Skilled'**
  String get packTitleSkilled;

  /// No description provided for @packTaglineSkilled.
  ///
  /// In en, this message translates to:
  /// **'For practiced decoders'**
  String get packTaglineSkilled;

  /// No description provided for @packTitleExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get packTitleExpert;

  /// No description provided for @packTaglineExpert.
  ///
  /// In en, this message translates to:
  /// **'Short, sharp, unforgiving'**
  String get packTaglineExpert;

  /// No description provided for @packTitleShortSweet.
  ///
  /// In en, this message translates to:
  /// **'Short & Sweet'**
  String get packTitleShortSweet;

  /// No description provided for @packTaglineShortSweet.
  ///
  /// In en, this message translates to:
  /// **'Bite-size quotes for a quick win'**
  String get packTaglineShortSweet;

  /// No description provided for @packTitleProverbs.
  ///
  /// In en, this message translates to:
  /// **'Proverbs'**
  String get packTitleProverbs;

  /// No description provided for @packTaglineProverbs.
  ///
  /// In en, this message translates to:
  /// **'Folk wisdom of the world'**
  String get packTaglineProverbs;

  /// No description provided for @packTitleWisdom.
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get packTitleWisdom;

  /// No description provided for @packTaglineWisdom.
  ///
  /// In en, this message translates to:
  /// **'Thinkers and statesmen'**
  String get packTaglineWisdom;

  /// No description provided for @packTitleLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get packTitleLiterature;

  /// No description provided for @packTaglineLiterature.
  ///
  /// In en, this message translates to:
  /// **'Lines from great books'**
  String get packTaglineLiterature;

  /// No description provided for @packTitleWit.
  ///
  /// In en, this message translates to:
  /// **'Wit'**
  String get packTitleWit;

  /// No description provided for @packTaglineWit.
  ///
  /// In en, this message translates to:
  /// **'Sharp tongues and clever quips'**
  String get packTaglineWit;

  /// No description provided for @packTitleClassics.
  ///
  /// In en, this message translates to:
  /// **'Classics'**
  String get packTitleClassics;

  /// No description provided for @packTaglineClassics.
  ///
  /// In en, this message translates to:
  /// **'Timeless voices, hand-picked'**
  String get packTaglineClassics;

  /// No description provided for @packTitleInspire.
  ///
  /// In en, this message translates to:
  /// **'Heart & Courage'**
  String get packTitleInspire;

  /// No description provided for @packTaglineInspire.
  ///
  /// In en, this message translates to:
  /// **'Proverbs of love, friendship and grit'**
  String get packTaglineInspire;

  /// No description provided for @achDescFirst.
  ///
  /// In en, this message translates to:
  /// **'Solve your first cryptogram'**
  String get achDescFirst;

  /// No description provided for @achDescSolve.
  ///
  /// In en, this message translates to:
  /// **'Solve {count} puzzles'**
  String achDescSolve(int count);

  /// No description provided for @achDescStreak.
  ///
  /// In en, this message translates to:
  /// **'Reach a {count}-day daily streak'**
  String achDescStreak(int count);

  /// No description provided for @achDescNoHints.
  ///
  /// In en, this message translates to:
  /// **'Solve {count} puzzles without hints'**
  String achDescNoHints(int count);

  /// No description provided for @achDescSpeed.
  ///
  /// In en, this message translates to:
  /// **'Solve a puzzle in under {count} seconds'**
  String achDescSpeed(int count);

  /// No description provided for @achDescDaily.
  ///
  /// In en, this message translates to:
  /// **'Solve {count} daily puzzles'**
  String achDescDaily(int count);

  /// No description provided for @achTitleFirstSolve.
  ///
  /// In en, this message translates to:
  /// **'First Crack'**
  String get achTitleFirstSolve;

  /// No description provided for @achTitleSolve10.
  ///
  /// In en, this message translates to:
  /// **'Apprentice Decoder'**
  String get achTitleSolve10;

  /// No description provided for @achTitleSolve25.
  ///
  /// In en, this message translates to:
  /// **'Code Breaker'**
  String get achTitleSolve25;

  /// No description provided for @achTitleSolve50.
  ///
  /// In en, this message translates to:
  /// **'Cipher Sleuth'**
  String get achTitleSolve50;

  /// No description provided for @achTitleSolve100.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achTitleSolve100;

  /// No description provided for @achTitleSolve250.
  ///
  /// In en, this message translates to:
  /// **'Master Cryptologist'**
  String get achTitleSolve250;

  /// No description provided for @achTitleSolve500.
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get achTitleSolve500;

  /// No description provided for @achTitleStreak3.
  ///
  /// In en, this message translates to:
  /// **'Warming Up'**
  String get achTitleStreak3;

  /// No description provided for @achTitleStreak7.
  ///
  /// In en, this message translates to:
  /// **'One Solid Week'**
  String get achTitleStreak7;

  /// No description provided for @achTitleStreak14.
  ///
  /// In en, this message translates to:
  /// **'Fortnight Focus'**
  String get achTitleStreak14;

  /// No description provided for @achTitleStreak30.
  ///
  /// In en, this message translates to:
  /// **'Monthly Devotion'**
  String get achTitleStreak30;

  /// No description provided for @achTitleStreak100.
  ///
  /// In en, this message translates to:
  /// **'Unbreakable'**
  String get achTitleStreak100;

  /// No description provided for @achTitleStreak365.
  ///
  /// In en, this message translates to:
  /// **'Year-Round Decoder'**
  String get achTitleStreak365;

  /// No description provided for @achTitleNoHints10.
  ///
  /// In en, this message translates to:
  /// **'Purist'**
  String get achTitleNoHints10;

  /// No description provided for @achTitleNoHints25.
  ///
  /// In en, this message translates to:
  /// **'Self-Reliant'**
  String get achTitleNoHints25;

  /// No description provided for @achTitleNoHints50.
  ///
  /// In en, this message translates to:
  /// **'Iron Will'**
  String get achTitleNoHints50;

  /// No description provided for @achTitleNoHints100.
  ///
  /// In en, this message translates to:
  /// **'Unaided Mind'**
  String get achTitleNoHints100;

  /// No description provided for @achTitleSpeed30.
  ///
  /// In en, this message translates to:
  /// **'Blink of an Eye'**
  String get achTitleSpeed30;

  /// No description provided for @achTitleSpeed60.
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get achTitleSpeed60;

  /// No description provided for @achTitleSpeed120.
  ///
  /// In en, this message translates to:
  /// **'Quick Thinker'**
  String get achTitleSpeed120;

  /// No description provided for @achTitleDaily10.
  ///
  /// In en, this message translates to:
  /// **'Daily Ritual'**
  String get achTitleDaily10;

  /// No description provided for @achTitleDaily25.
  ///
  /// In en, this message translates to:
  /// **'Faithful Solver'**
  String get achTitleDaily25;

  /// No description provided for @achTitleDaily50.
  ///
  /// In en, this message translates to:
  /// **'Morning Coffee'**
  String get achTitleDaily50;

  /// No description provided for @achTitleDaily100.
  ///
  /// In en, this message translates to:
  /// **'Hundred Mornings'**
  String get achTitleDaily100;

  /// No description provided for @hintRevealLetter.
  ///
  /// In en, this message translates to:
  /// **'Reveal letter'**
  String get hintRevealLetter;

  /// No description provided for @hintRevealLetterCount.
  ///
  /// In en, this message translates to:
  /// **'Reveal letter ({count})'**
  String hintRevealLetterCount(int count);

  /// No description provided for @hintTokensAdded.
  ///
  /// In en, this message translates to:
  /// **'+{count} hints added'**
  String hintTokensAdded(int count);

  /// No description provided for @adNoVideo.
  ///
  /// In en, this message translates to:
  /// **'No video is available right now. Please try again in a moment.'**
  String get adNoVideo;

  /// Tiny badge on freshly added content (e.g. a new achievement) the player hasn't seen yet. Keep it short.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// SnackBar shown when a flexible in-app update has been downloaded and is ready to install (installing restarts the app).
  ///
  /// In en, this message translates to:
  /// **'Update downloaded — restart Quotecrack to apply it.'**
  String get updateReadyBody;

  /// SnackBar action that installs the downloaded update and restarts the app.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get updateRestartAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
