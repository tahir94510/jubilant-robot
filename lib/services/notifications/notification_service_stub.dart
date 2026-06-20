import 'package:flutter/material.dart';

import 'notification_service.dart';

NotificationService createNotificationService() => StubNotificationService();

/// Web/no-op implementation.
class StubNotificationService extends NotificationService {
  StubNotificationService() : super.base();

  @override
  bool get supported => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> areEnabled() async => false;

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}
