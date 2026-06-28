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

  /// (Re)schedules the repeating daily reminder with inexact-allow-while-idle
  /// delivery (Play-safe; no exact-alarm permission). The HIGH-importance
  /// channel makes it alert. [title]/[body] arrive already localized to the
  /// user's UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  /// Opens the OS's notification settings for this app. The recovery path when
  /// POST_NOTIFICATIONS was denied: on Android 13+ a permanent denial makes
  /// [requestPermission] return false WITHOUT a prompt, so the only way back is
  /// the system settings page. No-op on web/stub.
  Future<void> openSystemSettings();

  Future<void> cancelAll();
}
