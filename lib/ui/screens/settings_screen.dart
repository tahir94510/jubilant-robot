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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          section('Appearance'),
          // "Auto" follows the device's light/dark setting and is the
          // default — it gets its own segment so the selection never lies
          // about what is on screen.
          ListTile(
            title: const Text('Theme'),
            subtitle: settings.themeMode == AppThemeMode.system
                ? const Text('Auto — follows your device')
                : null,
            trailing: SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(
                  value: AppThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined, size: 18),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined, size: 18),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined, size: 18),
                ),
                ButtonSegment(
                  value: AppThemeMode.sepia,
                  icon: Icon(Icons.menu_book_outlined, size: 18),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => controller.setThemeMode(s.first),
              showSelectedIcon: false,
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
              subtitle: const Text('Remove ads, unlimited hints, bonus packs'),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
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
              onTap: () => context.read<AdsService>().showPrivacyOptionsForm(),
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
    );
  }
}
