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

  /// No description provided for @reminderDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was denied in system settings.'**
  String get reminderDenied;

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
