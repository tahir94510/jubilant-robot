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

  /// Asks for POST_NOTIFICATIONS (Android 13+) and the Play-allowed
  /// SCHEDULE_EXACT_ALARM (so the reminder fires on time on aggressive OEMs).
  /// Called from the settings toggle — in context — to maximize grant rate.
  Future<bool> requestPermission();

  /// Whether the OS currently allows this app to post notifications. Used to
  /// keep the in-app reminder toggle in sync when the user disables
  /// notifications from system settings.
  Future<bool> areEnabled();

  /// (Re)schedules the repeating daily reminder. Uses EXACT delivery
  /// (exact-allow-while-idle) when the OS grants SCHEDULE_EXACT_ALARM — the
  /// Play-allowed exact-alarm permission — so it arrives on time even on
  /// aggressive OEMs; falls back to inexact where exact isn't granted. The
  /// HIGH-importance channel makes it alert. [title]/[body] arrive already
  /// localized to the user's UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  Future<void> cancelAll();
}
