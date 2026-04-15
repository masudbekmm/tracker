import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Stable IDs — never change these or existing schedules break
const kIdMorningDsa = 1;
const kIdEveningChecklist = 2;
const kIdSundayJournal = 3;
const _kIdTest = 99;

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(iOS: iosSettings),
    );
  }

  /// Returns true if the user granted permission.
  Future<bool> requestPermission() async {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    return granted ?? false;
  }

  // ─── Public schedule methods (times are dynamic) ─────────────────────────

  Future<void> scheduleMorningDsa({required int hour, required int minute}) =>
      _scheduleDaily(
        id: kIdMorningDsa,
        title: 'DSA session',
        body: '45 min. Open the app, mark it done.',
        hour: hour,
        minute: minute,
      );

  Future<void> scheduleEveningChecklist({
    required int hour,
    required int minute,
  }) =>
      _scheduleDaily(
        id: kIdEveningChecklist,
        title: "Did you finish today's checklist?",
        body: 'Tap to check off what you completed.',
        hour: hour,
        minute: minute,
      );

  Future<void> scheduleSundayJournal({
    required int hour,
    required int minute,
  }) =>
      _scheduleWeekly(
        id: kIdSundayJournal,
        title: 'Weekly journal time',
        body: "Reflect on the week. What clicked? What didn't?",
        weekday: DateTime.sunday,
        hour: hour,
        minute: minute,
      );

  Future<void> cancelMorningDsa() => _plugin.cancel(kIdMorningDsa);
  Future<void> cancelEveningChecklist() => _plugin.cancel(kIdEveningChecklist);
  Future<void> cancelSundayJournal() => _plugin.cancel(kIdSundayJournal);

  /// Fires a one-shot notification in [delaySeconds] seconds — for testing only.
  Future<void> sendTest({
    required String title,
    required String body,
    int delaySeconds = 5,
  }) async {
    final when = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));
    await _plugin.zonedSchedule(
      _kIdTest,
      title,
      body,
      when,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Core scheduling ─────────────────────────────────────────────────────

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextWeekdayInstanceOf(weekday, hour, minute),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekdayInstanceOf(int weekday, int hour, int minute) {
    tz.TZDateTime candidate = _nextInstanceOf(hour, minute);
    while (candidate.weekday != weekday) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
