import 'package:flutter/material.dart';

import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

/// Facade for the daily reminder notification.
abstract class NotificationService {
  factory NotificationService() => createNotificationService();

  NotificationService.base();

  /// False on web/stub.
  bool get supported;

  Future<void> initialize();

  /// Asks for POST_NOTIFICATIONS (Android 13+) only. Called from the settings
  /// toggle, in context, to maximize grant rate. No exact-alarm prompt: the
  /// daily reminder uses inexact scheduling (Play-safe, no confusing system
  /// "Alarms & reminders" page).
  Future<bool> requestPermission();

  /// Whether the OS currently allows this app to post notifications. Used to
  /// keep the in-app reminder toggle in sync when the user disables
  /// notifications from system settings.
  Future<bool> areEnabled();

  /// (Re)schedules the repeating daily reminder with EXACT allow-while-idle
  /// delivery (`USE_EXACT_ALARM`), so aggressive OEM battery managers
  /// (Xiaomi/MIUI, Huawei) can't silently batch it away the way inexact alarms
  /// were being dropped. The HIGH-importance channel makes it alert.
  /// [title]/[body] arrive already localized to the user's UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  /// Posts a one-off reminder IMMEDIATELY (not scheduled), so the user can
  /// confirm delivery actually works on their device the moment they enable the
  /// reminder — decoupled from the daily time. No-op on web/stub.
  Future<void> showTestNotification({
    required String title,
    required String body,
  });

  /// Opens the OS's notification settings for this app. The recovery path when
  /// POST_NOTIFICATIONS was denied: on Android 13+ a permanent denial makes
  /// [requestPermission] return false WITHOUT a prompt, so the only way back is
  /// the system settings page. No-op on web/stub.
  Future<void> openSystemSettings();

  /// Opens the OS battery-optimization settings so the user can exempt the app
  /// — the real fix for OEMs (MIUI/Huawei) that kill background alarms. Uses the
  /// general settings list (no Play-restricted permission). No-op on web/stub.
  Future<void> openBatterySettings();

  Future<void> cancelAll();
}
