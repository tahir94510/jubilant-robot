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

  /// Asks for POST_NOTIFICATIONS (Android 13+). Called from the settings
  /// toggle — in context — not at app start, to maximize grant rate. No
  /// exact-alarm permission is requested (the daily reminder is inexact).
  Future<bool> requestPermission();

  /// Whether the OS currently allows this app to post notifications. Used to
  /// keep the in-app reminder toggle in sync when the user disables
  /// notifications from system settings.
  Future<bool> areEnabled();

  /// (Re)schedules the repeating daily reminder. Inexact-allow-while-idle: no
  /// SCHEDULE_EXACT_ALARM permission (Play-safe) and no settings redirect; the
  /// OS still delivers daily within its maintenance window (a few minutes of
  /// drift is fine for a puzzle reminder) and the HIGH-importance channel makes
  /// it alert. [title]/[body] arrive already localized to the user's UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  Future<void> cancelAll();
}
