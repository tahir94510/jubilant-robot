import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_settings.dart';
import '../../services/ads/ads_service.dart';
import '../../services/music_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/purchases/purchase_service.dart';
import '../../services/sound_service.dart';
import '../../state/economy_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/page_body.dart';
import '../widgets/scale_safe.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _privacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    context.read<AdsService>().privacyOptionsRequired.then((required) {
      if (mounted) setState(() => _privacyOptionsRequired = required);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    final economy = context.watch<EconomyController>();
    final purchases = context.read<PurchaseService>();
    final notificationsSupported = context
        .read<NotificationService>()
        .supported;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: palette.textSecondary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: PageBody(
        child: ScaleSafe(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              section(l10n.sectionLanguage),
              _LanguageTile(
                selectedCode: settings.languageCode,
                onSelect: controller.setLanguage,
              ),
              section(l10n.sectionAppearance),
              // "Auto" follows the device's light/dark setting and is the
              // default — it gets its own segment so the selection never lies
              // about what is on screen. The selector sits on its own row
              // (full width) so it never squeezes against a title on narrow
              // phones.
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.theme, style: const TextStyle(fontSize: 16)),
                    if (settings.themeMode == AppThemeMode.system)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.themeAutoSubtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // A 2x2 grid of labelled cards instead of a SegmentedButton:
                    // four segments squeezed labels off narrow phones, and
                    // icon-only segments read poorly. Every option keeps its
                    // text label at any width/text scale (ellipsis as the
                    // absolute last resort).
                    _ThemeGrid(
                      selected: settings.themeMode,
                      onSelect: controller.setThemeMode,
                    ),
                  ],
                ),
              ),
              // Same icon · slider · value layout as the volume controls, for a
              // consistent settings surface.
              _SliderTile(
                icon: Icons.format_size_rounded,
                label: l10n.textSize,
                value: settings.textScale,
                displayPercent: (settings.textScale * 100).round(),
                min: 0.85,
                max: 1.4,
                divisions: 11,
                // Preview every tick in memory only; persist once on release
                // (writing prefs per tick made the slider stutter).
                onPreview: controller.previewTextScale,
                onCommit: controller.setTextScale,
              ),
              SwitchListTile(
                title: Text(l10n.colorblindTitle),
                subtitle: Text(l10n.colorblindSubtitle),
                value: settings.colorblindMode,
                onChanged: controller.setColorblindMode,
              ),
              section(l10n.sectionGameplay),
              SwitchListTile(
                title: Text(l10n.errorCheckingTitle),
                subtitle: Text(l10n.errorCheckingSubtitle),
                value: settings.errorChecking,
                onChanged: controller.setErrorChecking,
              ),
              SwitchListTile(
                title: Text(l10n.showTimerTitle),
                subtitle: Text(l10n.showTimerSubtitle),
                value: settings.showTimer,
                onChanged: controller.setShowTimer,
              ),
              SwitchListTile(
                title: Text(l10n.hapticsTitle),
                value: settings.haptics,
                onChanged: controller.setHaptics,
              ),
              SwitchListTile(
                title: Text(l10n.soundEffectsTitle),
                subtitle: Text(l10n.soundEffectsSubtitle),
                value: settings.soundEffects,
                onChanged: controller.setSoundEffects,
              ),
              if (settings.soundEffects)
                _SliderTile(
                  icon: Icons.volume_up_rounded,
                  label: l10n.effectsVolume,
                  value: settings.soundVolume,
                  displayPercent: (settings.soundVolume * 100).round(),
                  onPreview: (v) => controller.previewSoundVolume(
                    v,
                    context.read<SoundService>(),
                  ),
                  onCommit: (v) => controller.setSoundVolume(
                    v,
                    context.read<SoundService>(),
                  ),
                ),
              SwitchListTile(
                title: Text(l10n.musicTitle),
                subtitle: Text(l10n.musicSubtitle),
                value: settings.music,
                onChanged: (value) => controller.setMusicAndApply(
                  value,
                  context.read<MusicService>(),
                ),
              ),
              if (settings.music)
                _SliderTile(
                  icon: Icons.music_note_rounded,
                  label: l10n.musicVolume,
                  value: settings.musicVolume,
                  displayPercent: (settings.musicVolume * 100).round(),
                  onPreview: (v) => controller.previewMusicVolume(
                    v,
                    context.read<MusicService>(),
                  ),
                  onCommit: (v) => controller.setMusicVolume(
                    v,
                    context.read<MusicService>(),
                  ),
                ),
              if (notificationsSupported) ...[
                section(l10n.sectionDailyReminder),
                SwitchListTile(
                  title: Text(l10n.remindMeDaily),
                  subtitle: Text(
                    settings.reminderEnabled
                        ? l10n.reminderAt(settings.reminderTime.format(context))
                        : l10n.neverMissStreak,
                  ),
                  value: settings.reminderEnabled,
                  onChanged: (enabled) async {
                    final ok = await controller.setReminder(enabled: enabled);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.reminderDenied)),
                      );
                    }
                  },
                ),
                if (settings.reminderEnabled)
                  ListTile(
                    title: Text(l10n.reminderTime),
                    trailing: Text(
                      settings.reminderTime.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settings.reminderTime,
                        // Keyboard entry only: faster for the audience, and
                        // it sidesteps the M3 dial's overlapping-dot visuals.
                        initialEntryMode: TimePickerEntryMode.inputOnly,
                      );
                      if (picked != null) {
                        await controller.setReminder(
                          enabled: true,
                          time: picked,
                        );
                      }
                    },
                  ),
                if (settings.reminderEnabled)
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.sendTestNotification),
                    onTap: () async {
                      final ok = await controller.sendTestNotification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? l10n.testNotificationSent
                                  : l10n.reminderDenied,
                            ),
                          ),
                        );
                    },
                  ),
              ],
              section(l10n.sectionPremium),
              if (economy.premium)
                ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: Text(l10n.premiumActive),
                  subtitle: Text(l10n.premiumActiveSubtitle),
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(l10n.goPremium),
                  subtitle: Text(l10n.goPremiumSubtitle),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text(l10n.restorePurchases),
                  onTap: () async {
                    await purchases.restore();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.checkingPurchases)),
                      );
                    }
                  },
                ),
              ],
              section(l10n.sectionPrivacyAbout),
              if (_privacyOptionsRequired)
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyOptions),
                  subtitle: Text(l10n.privacyOptionsSubtitle),
                  onTap: () =>
                      context.read<AdsService>().showPrivacyOptionsForm(),
                ),
              ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: Text(l10n.privacyPolicy),
                onTap: () => launchUrl(
                  Uri.parse(AppConfig.privacyPolicyUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.openSourceLicenses),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConfig.appName,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: Text(l10n.restoreDefaults),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final sounds = context.read<SoundService>();
                  final music = context.read<MusicService>();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.restoreDefaults),
                      content: Text(l10n.restoreDefaultsMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            MaterialLocalizations.of(ctx).cancelButtonLabel,
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.restoreDefaults),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await controller.resetToDefaults(
                    sounds: sounds,
                    music: music,
                  );
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.restoreDefaultsDone)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.version),
                subtitle: const Text(AppConfig.appVersion),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app-language picker. Languages are shown by their native name
/// (endonym), which reads correctly whatever the current UI language is.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.selectedCode, required this.onSelect});

  final String? selectedCode;
  final ValueChanged<String?> onSelect;

  /// Native names for the supported languages.
  static const _names = {
    'en': 'English',
    'tr': 'Türkçe',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = selectedCode == null
        ? l10n.languageSystem
        : (_names[selectedCode] ?? selectedCode!);
    return ListTile(
      leading: const Icon(Icons.translate_outlined),
      title: Text(l10n.appLanguage),
      subtitle: Text(current),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) {
            final entries = <MapEntry<String?, String>>[
              MapEntry(null, l10n.languageSystem),
              ..._names.entries.map(
                (e) => MapEntry<String?, String>(e.key, e.value),
              ),
            ];
            // Act on tap (then close) so dismissing the sheet — which would
            // also "return null" — can never be mistaken for picking System
            // default. A trailing check marks the current choice.
            final scheme = Theme.of(sheetContext).colorScheme;
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final e in entries)
                    ListTile(
                      title: Text(e.value),
                      trailing: e.key == selectedCode
                          ? Icon(Icons.check, color: scheme.primary)
                          : null,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onSelect(e.key);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A compact volume row: an icon, a label, and a percentage slider that
/// previews live (audible while dragging) and commits to disk on release.
/// One row in the consistent "icon · slider · value" family shared by the
/// effects, music and text-size controls — same chrome everywhere, with the
/// live percentage shown ONCE on the right (no redundant drag bubble).
class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.displayPercent,
    required this.onPreview,
    required this.onCommit,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
  });

  final IconData icon;
  final String label;
  final double value;

  /// The number shown in the right-hand readout (and announced for a11y).
  final int displayPercent;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onPreview;
  final ValueChanged<double> onCommit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pct = displayPercent;
    return Padding(
      // A consistent, balanced top+bottom rhythm so the text-size / volume
      // sliders never look glued to the switch or grid above them.
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          // A tinted, evenly-padded chip so the glyph reads as a deliberate
          // control affordance, not a stray icon floating with dead space.
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: scheme.primary,
                inactiveTrackColor: scheme.primary.withValues(alpha: .18),
                thumbColor: scheme.primary,
                overlayColor: scheme.primary.withValues(alpha: .14),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  pressedElevation: 4,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                trackShape: const RoundedRectSliderTrackShape(),
                tickMarkShape: SliderTickMarkShape.noTickMark,
                valueIndicatorShape:
                    const RectangularSliderValueIndicatorShape(),
                valueIndicatorColor: scheme.primary,
                valueIndicatorTextStyle: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                // No floating value bubble: the right-hand readout already
                // shows the live percentage, so a drag label would just repeat
                // it. The semantic label keeps the control fully accessible.
                semanticFormatterCallback: (v) =>
                    '$label ${(v * 100).round()} percent',
                onChanged: onPreview,
                onChangeEnd: onCommit,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // A fixed, tabular-width readout in the slider's own accent so the
          // value reads as part of the control. Fixed width keeps the slider
          // edge from jittering as the digits change (8% to 100%). The
          // FittedBox guarantees the three-digit "100%" never wraps or clips —
          // it shrinks to fit at large text scales instead of breaking.
          SizedBox(
            width: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$pct%',
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.selected, required this.onSelect});

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelect;

  static const _options = [
    (AppThemeMode.system, Icons.brightness_auto_outlined),
    (AppThemeMode.light, Icons.light_mode_outlined),
    (AppThemeMode.dark, Icons.dark_mode_outlined),
    (AppThemeMode.sepia, Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String labelFor(AppThemeMode mode) => switch (mode) {
      AppThemeMode.system => l10n.themeAuto,
      AppThemeMode.light => l10n.themeLight,
      AppThemeMode.dark => l10n.themeDark,
      AppThemeMode.sepia => l10n.themeSepia,
    };
    Widget card(int index) {
      final (mode, icon) = _options[index];
      return Expanded(
        child: _ThemeCard(
          icon: icon,
          label: labelFor(mode),
          selected: mode == selected,
          onTap: () => onSelect(mode),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [card(0), const SizedBox(width: 10), card(1)]),
        const SizedBox(height: 10),
        Row(children: [card(2), const SizedBox(width: 10), card(3)]),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    return Semantics(
      button: true,
      selected: selected,
      // The localized theme name already reads clearly to a screen reader;
      // an English "theme" suffix would be inconsistent under other locales.
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: .12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: .12),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? scheme.primary : palette.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
