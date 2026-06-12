import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../models/app_settings.dart';
import '../../services/ads/ads_service.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/purchases/purchase_service.dart';
import '../../state/economy_controller.dart';
import '../../state/settings_controller.dart';
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
    final scheme = Theme.of(context).colorScheme;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: scheme.onSurface.withValues(alpha: .45),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ScaleSafe(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            section('Appearance'),
            // "Auto" follows the device's light/dark setting and is the
            // default — it gets its own segment so the selection never lies
            // about what is on screen. The selector sits on its own row
            // (full width) so it never squeezes against a title on narrow
            // phones.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Theme', style: TextStyle(fontSize: 16)),
                  if (settings.themeMode == AppThemeMode.system)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Auto — follows your device',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withValues(alpha: .55),
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
            ListTile(
              title: const Text('Text size'),
              subtitle: Slider(
                value: settings.textScale,
                min: 0.85,
                max: 1.4,
                divisions: 11,
                label: '${(settings.textScale * 100).round()}%',
                // Preview every tick in memory only; persist once on release
                // (writing prefs per tick made the slider stutter).
                onChanged: controller.previewTextScale,
                onChangeEnd: controller.setTextScale,
              ),
            ),
            SwitchListTile(
              title: const Text('Colorblind-friendly colors'),
              subtitle: const Text('Blue/orange highlights instead of red'),
              value: settings.colorblindMode,
              onChanged: controller.setColorblindMode,
            ),
            section('Gameplay'),
            SwitchListTile(
              title: const Text('Error checking'),
              subtitle: const Text('Mark wrong letters once the board is full'),
              value: settings.errorChecking,
              onChanged: controller.setErrorChecking,
            ),
            SwitchListTile(
              title: const Text('Show timer'),
              subtitle: const Text('Turn off for a fully zen experience'),
              value: settings.showTimer,
              onChanged: controller.setShowTimer,
            ),
            SwitchListTile(
              title: const Text('Haptic feedback'),
              value: settings.haptics,
              onChanged: controller.setHaptics,
            ),
            SwitchListTile(
              title: const Text('Sound effects'),
              subtitle: const Text('Soft key taps and gentle chimes'),
              value: settings.soundEffects,
              onChanged: controller.setSoundEffects,
            ),
            if (notificationsSupported) ...[
              section('Daily reminder'),
              SwitchListTile(
                title: const Text('Remind me daily'),
                subtitle: Text(
                  settings.reminderEnabled
                      ? 'At ${settings.reminderTime.format(context)}'
                      : 'Never miss your streak',
                ),
                value: settings.reminderEnabled,
                onChanged: (enabled) async {
                  final ok = await controller.setReminder(enabled: enabled);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Notification permission was denied in system settings.',
                        ),
                      ),
                    );
                  }
                },
              ),
              if (settings.reminderEnabled)
                ListTile(
                  title: const Text('Reminder time'),
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
                    );
                    if (picked != null) {
                      await controller.setReminder(enabled: true, time: picked);
                    }
                  },
                ),
            ],
            section('Premium'),
            if (economy.premium)
              const ListTile(
                leading: Icon(Icons.workspace_premium),
                title: Text('Premium active'),
                subtitle: Text('Thank you for supporting Quotecrack!'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: const Text('Go Premium'),
                subtitle: const Text(
                  'Remove ads, unlimited hints, bonus packs',
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore purchases'),
                onTap: () async {
                  await purchases.restore();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking previous purchases...'),
                      ),
                    );
                  }
                },
              ),
            ],
            section('Privacy & about'),
            if (_privacyOptionsRequired)
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy options'),
                subtitle: const Text('Manage your ad consent choices'),
                onTap: () =>
                    context.read<AdsService>().showPrivacyOptionsForm(),
              ),
            ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: const Text('Privacy policy'),
              onTap: () => launchUrl(
                Uri.parse(AppConfig.privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open-source licenses'),
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppConfig.appName,
              ),
            ),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Version'),
              subtitle: Text(AppConfig.appVersion),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.selected, required this.onSelect});

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelect;

  static const _options = [
    (AppThemeMode.system, Icons.brightness_auto_outlined, 'Auto'),
    (AppThemeMode.light, Icons.light_mode_outlined, 'Light'),
    (AppThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
    (AppThemeMode.sepia, Icons.menu_book_outlined, 'Sepia'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget card(int index) {
      final (mode, icon, label) = _options[index];
      return Expanded(
        child: _ThemeCard(
          icon: icon,
          label: label,
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
    return Semantics(
      button: true,
      selected: selected,
      label: '$label theme',
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
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: .6),
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
