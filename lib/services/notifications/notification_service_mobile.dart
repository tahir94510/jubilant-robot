import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';

NotificationService createNotificationService() => MobileNotificationService();

/// flutter_local_notifications implementation (Android).
class MobileNotificationService extends NotificationService {
  MobileNotificationService() : super.base();

  static const int _dailyReminderId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _tzReady = false;

  @override
  bool get supported => true;

  @override
  Future<void> initialize() async {
    const settings = InitializationSettings(
      // A dedicated white-on-transparent glyph: status bars render launcher
      // icons as a flat gray blob, the alpha-only mark stays crisp.
      android: AndroidInitializationSettings('@drawable/ic_stat_quotecrack'),
    );
    await _plugin.initialize(settings: settings);
  }

  Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (_) {
      // Fall back to the bundled default (UTC); reminder still fires daily.
    }
    _tzReady = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    final granted = await _android?.requestNotificationsPermission();
    // Also ask for exact-alarm permission so the reminder fires on time. If the
    // user declines, scheduleDaily falls back to an inexact alarm (no crash).
    try {
      await _android?.requestExactAlarmsPermission();
    } catch (_) {}
    return granted ?? false;
  }

  @override
  Future<bool> areEnabled() async {
    try {
      return (await _android?.areNotificationsEnabled()) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    await _ensureTimezone();
    await _plugin.cancel(id: _dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily puzzle reminder',
        channelDescription: 'One reminder per day for the daily cryptogram.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        // Brand accent tints the small icon + app name in the shade.
        color: const Color(0xFF936F1F),
        // Expands the longer body cleanly when the shade is pulled down.
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      ),
    );

    // Prefer an EXACT alarm so the reminder lands on time (an inexact alarm can
    // be batched and delayed by many minutes — which made a "remind me in 1
    // minute" test look broken). If the exact-alarm permission isn't granted,
    // zonedSchedule throws; fall back to inexact so it still fires (approximately)
    // and never crashes.
    try {
      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        title: title,
        body: body,
        scheduledDate: next,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        title: title,
        body: body,
        scheduledDate: next,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
