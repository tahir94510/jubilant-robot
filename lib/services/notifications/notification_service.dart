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
  /// toggle — in context — not at app start, to maximize grant rate.
  Future<bool> requestPermission();

  /// (Re)schedules the repeating daily reminder. Inexact by design: no
  /// SCHEDULE_EXACT_ALARM permission, and a few minutes of drift is fine
  /// for a puzzle reminder. [title]/[body] arrive already localized to the
  /// user's chosen UI language.
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  });

  Future<void> cancelAll();
}
