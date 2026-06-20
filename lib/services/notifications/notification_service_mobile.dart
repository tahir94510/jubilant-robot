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
  static const int _testNotificationId = 1002;
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily puzzle reminder';
  static const String _channelDescription =
      'One reminder per day for the daily cryptogram.';

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
    // Create the channel explicitly at startup so it exists with the right
    // importance the moment a reminder is scheduled (and so the OS shows it
    // under app notification settings even before the first fire). Creating an
    // existing channel again is a no-op, so this is safe on every launch.
    try {
      await _android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          // HIGH so the reminder makes a sound and a heads-up banner — a
          // default-importance channel queued silently into the shade, which
          // read as "nothing arrived". (Channel importance is locked at first
          // creation, so this applies to fresh installs.)
          importance: Importance.high,
        ),
      );
    } catch (_) {
      // Older platforms / no-op contexts: scheduling still creates the channel.
    }
  }

  Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      // flutter_timezone 5.x returns a TimezoneInfo whose .identifier is the
      // IANA name (e.g. "Europe/Istanbul"); the local tz follows the DEVICE,
      // not the app language (timezone is device-based by design).
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (e) {
      // Fall back to the bundled default (UTC); reminder still fires daily.
      debugPrint('NotificationService: timezone init failed: $e');
    }
    _tzReady = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    // We request ONLY POST_NOTIFICATIONS here. We never call
    // requestExactAlarmsPermission(), which is what opens the intrusive
    // "Alarms & reminders" special-access page. Exact timing is still used when
    // the OS already allows it (see scheduleDaily) — a read-only check, no
    // prompt — so enabling notifications stays the only step the user takes.
    final granted = await _android?.requestNotificationsPermission();
    return granted ?? false;
  }

  AndroidNotificationDetails _androidDetails(String title, String body) =>
      AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        // Match the HIGH channel so it actually alerts (sound + heads-up).
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        // Brand accent tints the small icon + app name in the shade.
        color: const Color(0xFF936F1F),
        // Expands the longer body cleanly when the shade is pulled down.
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      );

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

    // Fire at the chosen minute when the OS already permits exact alarms
    // (Android 12 grants SCHEDULE_EXACT_ALARM by default; the manifest declares
    // it). canScheduleExactNotifications() is a READ-ONLY check — it never opens
    // a settings page. When it's not allowed (e.g. Android 13+ until the user
    // grants it), we fall back to inexact-allow-while-idle, which still delivers
    // within the OS maintenance window. Either way: no intrusive redirect.
    var exact = false;
    try {
      exact = await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      exact = false;
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: NotificationDetails(
        android: _androidDetails(title, body),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    // An immediate notification so the player can confirm reminders work right
    // now, without waiting for the scheduled time or the OS maintenance window.
    await _plugin.show(
      id: _testNotificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: _androidDetails(title, body),
      ),
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
