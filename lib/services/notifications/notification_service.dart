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

  /// Asks for POST_NOTIFICATIONS (Android 13+) and exact-alarm permission.
  /// Called from the settings toggle — in context — not at app start, to
  /// maximize grant rate.
  Future<bool> requestPermission();

  /// Whether the OS currently allows this app to post notifications. Used to
  /// keep the in-app reminder toggle in sync when the user disables
  /// notifications from system settings.
  Future<bool> areEnabled();

  /// (Re)schedules the repeating daily reminder. Uses exact timing when the OS
  /// already permits it (no prompt) and falls back to inexact otherwise — a few
  /// minutes of drift is fine for a puzzle reminder. [title]/[body] arrive
  /// already localized to the user's chosen UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  /// Posts a notification immediately, so the player can verify reminders work
  /// without waiting for the scheduled time. No-op on web/stub.
  Future<void> showNow({required String title, required String body});

  Future<void> cancelAll();
}
