import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// The notification small-icon drawable (alpha-only status-bar mark). Passed
  /// EXPLICITLY on every post as well as at init, so a notification never falls
  /// back to a missing/launcher icon on stricter OEMs.
  static const String _smallIcon = 'ic_stat_quotecrack';

  /// Platform channel to the host Activity for opening the OS notification
  /// settings page (the recovery path for a permanently-denied permission).
  static const MethodChannel _platform = MethodChannel(
    'quotecrack/notifications',
  );
  // v2: an Android channel's importance is LOCKED at first creation. Installs
  // that created the original 'daily_reminder' channel at default importance
  // were stuck silent / no heads-up forever (reminders dropped invisibly into
  // the shade — "no sound, not visible"). A new channel id forces a fresh HIGH
  // channel for everyone; the old one is deleted in [initialize].
  static const String _channelId = 'daily_reminder_v2';
  static const String _legacyChannelId = 'daily_reminder';
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
    // Register BOTH response handlers. This is required setup for
    // flutter_local_notifications: when the user TAPS a scheduled reminder that
    // launched the app from a fully terminated state, the plugin invokes the
    // background handler in a short-lived isolate — and if that entry point was
    // never registered (and @pragma('vm:entry-point') kept it from being
    // tree-shaken in release), the native side calls into a missing Dart
    // function and the freshly-launched process crashes/closes immediately.
    // The handlers are intentionally no-ops: tapping the reminder only needs to
    // bring the app to the foreground, which the OS launcher intent already does.
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );
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
    // Drop the pre-v2 channel so a user who once had the silent/low-importance
    // version doesn't keep a stale, muted duplicate under app notification
    // settings (and never hears the reminder). No-op if it never existed.
    try {
      await _android?.deleteNotificationChannel(channelId: _legacyChannelId);
    } catch (_) {}
  }

  Future<void> _ensureTimezone() async {
    if (_tzReady) return;
    try {
      // initializeTimeZones must run before any tz lookup; keep it inside the
      // guard so a (rare) database init failure can never propagate.
      tzdata.initializeTimeZones();
      // flutter_timezone 5.x returns a TimezoneInfo whose .identifier is the
      // IANA name (e.g. "Europe/Istanbul"); the local tz follows the DEVICE,
      // not the app language (timezone is device-based by design).
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
      // Only latch ready on success, so a transient failure can retry next call.
      _tzReady = true;
    } catch (e) {
      // Fall back to the bundled default (UTC); reminder still fires daily.
      debugPrint('NotificationService: timezone init failed: $e');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> requestPermission() async {
    // Only POST_NOTIFICATIONS (Android 13+). We deliberately do NOT request
    // SCHEDULE_EXACT_ALARM: a daily "come play" reminder does not need exact
    // timing, the request pops a confusing "Alarms & reminders" system page
    // (users read it as a bug), and Play scrutinises exact-alarm as a
    // core-function-only permission. Both exact-alarm permissions are stripped
    // in the manifest; scheduling uses inexact-allow-while-idle.
    final granted = await _android?.requestNotificationsPermission();
    return granted ?? false;
  }

  AndroidNotificationDetails _androidDetails(
    String title,
    String body,
  ) => AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    // Set the small icon EXPLICITLY (not just at init): some OEMs drop a
    // notification whose details carry no icon, falling back to the launcher
    // icon (a gray blob) at best.
    icon: _smallIcon,
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

    // INEXACT delivery only (inexactAllowWhileIdle): a daily habit reminder
    // does not need exact timing, so we avoid SCHEDULE_EXACT_ALARM entirely —
    // no confusing system prompt, Play-safe, and scheduling can never throw.
    // The OS may batch delivery into its maintenance window (a few minutes of
    // drift, fine for "come play today"); the HIGH-importance channel still
    // makes it alert. Aggressive OEMs (Xiaomi/MIUI, Huawei) may still delay or
    // drop it under battery optimization — that is an OS/OEM setting, not an
    // app permission, and exact alarms would not reliably override it either.
    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: NotificationDetails(
        android: _androidDetails(title, body),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // An explicit (non-null) payload keeps the plugin off any null-payload
      // serialization path when the daily reminder is delivered.
      payload: 'daily_reminder',
    );
  }

  @override
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    // Fires immediately on the same HIGH channel as the daily reminder so the
    // user can confirm notifications actually arrive on THIS device (and clear
    // the OS prompt) without waiting for the scheduled time.
    await _plugin.show(
      id: _testNotificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: _androidDetails(title, body),
      ),
      payload: 'test_notification',
    );
  }

  @override
  Future<void> openSystemSettings() async {
    // The host Activity opens Settings.ACTION_APP_NOTIFICATION_SETTINGS (with a
    // fallback to the app details page). Best-effort: a missing handler or OEM
    // quirk must never throw into the settings screen.
    try {
      await _platform.invokeMethod('openNotificationSettings');
    } catch (_) {}
  }

  /// Foreground / launch tap handler. The OS already brings the app forward;
  /// a single daily reminder has nothing extra to route.
  void _onNotificationResponse(NotificationResponse response) {}

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

/// Background-isolate tap handler. MUST be a top-level function annotated with
/// @pragma('vm:entry-point') so release tree-shaking never strips it: when a
/// reminder is tapped after the app process was killed, flutter_local_
/// notifications invokes this natively in a background isolate. A no-op — the
/// reminder only needs to reopen the app.
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {}
