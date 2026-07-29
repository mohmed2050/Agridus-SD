import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'weather_channel',
          'تنبيهات الطقس',
          description: 'إشعارات حالة الطقس وأحواله',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_channel',
          'مواقيت الصلاة',
          description: 'إشعارات مواقيت الصلاة',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_channel',
          'تنبيهات المهام',
          description: 'إشعارات تذكير المهام',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    _initialized = true;
  }

  Future<void> showWeatherAlert(String message) async {
    await _plugin.show(
      1000,
      'تنبيه زراعي - طقس غير مناسب اليوم',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_channel',
          'تنبيهات الطقس',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showPrayerNotification(String prayerName) async {
    await _plugin.show(
      2000 + prayerName.hashCode,
      'حان الآن وقت صلاة $prayerName',
      'حان وقت صلاة $prayerName - لا تنسَ ذكر الله',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'مواقيت الصلاة',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> schedulePrayerNotification(
      int id, String prayerName, DateTime time) async {
    final now = DateTime.now();
    final scheduledDate = time.isBefore(now)
        ? time.add(const Duration(days: 1))
        : time;

    await _plugin.zonedSchedule(
      id,
      'حان الآن وقت صلاة $prayerName',
      'حان وقت صلاة $prayerName',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'مواقيت الصلاة',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTaskNotification(
      int id, String title, DateTime time) async {
    await _plugin.zonedSchedule(
      id,
      'تذكير بالمهمة: $title',
      'حان وقت تنفيذ المهمة',
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'تنبيهات المهام',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
