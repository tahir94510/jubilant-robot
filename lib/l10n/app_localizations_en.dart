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
}
