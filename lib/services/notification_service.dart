import 'dart:typed_data';
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

  bool _globalEnabled = true;
  bool _prayerEnabled = true;
  bool _weatherEnabled = true;
  bool _taskEnabled = true;
  bool _calendarEnabled = true;
  int _vibration = 2;
  int _selectedSound = 0;

  static final List<AndroidNotificationChannel> _prayerChannels = [
    AndroidNotificationChannel('prayer_0', 'مواقيت الصلاة (افتراضي)',
        description: 'إشعارات مواقيت الصلاة',
        importance: Importance.high, playSound: true),
    AndroidNotificationChannel('prayer_1', 'مواقيت الصلاة (أذان الفجر)',
        description: 'إشعارات مواقيت الصلاة',
        importance: Importance.high, playSound: true,
        sound: RawResourceAndroidNotificationSound('azan_fajr')),
    AndroidNotificationChannel('prayer_2', 'مواقيت الصلاة (أذان عادي)',
        description: 'إشعارات مواقيت الصلاة',
        importance: Importance.high, playSound: true,
        sound: RawResourceAndroidNotificationSound('azan_normal')),
    AndroidNotificationChannel('prayer_3', 'مواقيت الصلاة (صوت إسلامي)',
        description: 'إشعارات مواقيت الصلاة',
        importance: Importance.high, playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_islamic')),
    AndroidNotificationChannel('prayer_4', 'مواقيت الصلاة (صامت)',
        description: 'إشعارات مواقيت الصلاة',
        importance: Importance.high, playSound: false),
  ];

  String get _prayerChannelId => 'prayer_$_selectedSound';

  void updateSettings({
    required bool globalEnabled,
    required bool prayerEnabled,
    required bool weatherEnabled,
    required bool taskEnabled,
    required bool calendarEnabled,
    required int vibrationIntensity,
  }) {
    _globalEnabled = globalEnabled;
    _prayerEnabled = prayerEnabled;
    _weatherEnabled = weatherEnabled;
    _taskEnabled = taskEnabled;
    _calendarEnabled = calendarEnabled;
    _vibration = vibrationIntensity;
  }

  void setSelectedSound(int index) {
    _selectedSound = index;
  }

  AndroidNotificationDetails _soundDetails(String channelId, String channelName) {
    final sound = switch (_selectedSound) {
      1 => const RawResourceAndroidNotificationSound('azan_fajr'),
      2 => const RawResourceAndroidNotificationSound('azan_normal'),
      3 => const RawResourceAndroidNotificationSound('notification_islamic'),
      4 => null,
      _ => null,
    };
    return AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: _getVibrationPattern(),
      playSound: _selectedSound != 4,
      sound: sound,
    );
  }

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
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (_) {}
      for (final ch in _prayerChannels) {
        try {
          await androidPlugin.deleteNotificationChannel(ch.id);
        } catch (_) {}
      }
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'weather_channel',
          'تنبيهات الطقس',
          description: 'إشعارات حالة الطقس وأحواله',
          importance: Importance.high,
          playSound: true,
        ),
      );
      for (final ch in _prayerChannels) {
        await androidPlugin.createNotificationChannel(ch);
      }
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_channel',
          'تنبيهات المهام',
          description: 'إشعارات تذكير المهام',
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'calendar_channel',
          'تنبيهات التقويم',
          description: 'إشعارات التقويم الزراعي',
          importance: Importance.high,
          playSound: true,
        ),
      );
    }

    _initialized = true;
  }

  Future<void> showWeatherAlert(String message) async {
    if (!_globalEnabled || !_weatherEnabled) return;
    await _show(1000, 'تنبيه زراعي - طقس غير مناسب اليوم', message,
        'weather_channel', 'تنبيهات الطقس');
  }

  Future<void> showPrayerNotification(String prayerName) async {
    if (!_globalEnabled || !_prayerEnabled) return;
    await _show(2000 + prayerName.hashCode, 'حان الآن وقت صلاة $prayerName',
        'حان وقت صلاة $prayerName - لا تنسَ ذكر الله',
        _prayerChannelId, 'مواقيت الصلاة');
  }

  Future<void> testPrayerNotification() async {
    if (!_globalEnabled) return;
    await _show(9999, 'اختبار صوت الإشعار',
        'إذا سمعت هذا الصوت فكل شيء يعمل بشكل صحيح',
        _prayerChannelId, 'مواقيت الصلاة');
  }

  Future<void> showTaskNotification(String title) async {
    if (!_globalEnabled || !_taskEnabled) return;
    await _show(title.hashCode.abs(), 'تذكير بالمهمة: $title',
        'حان وقت تنفيذ المهمة', 'task_channel', 'تنبيهات المهام');
  }

  Future<void> showCalendarAlert(String title) async {
    if (!_globalEnabled || !_calendarEnabled) return;
    await _show(title.hashCode.abs() + 5000, 'تنبيه التقويم الزراعي',
        title, 'calendar_channel', 'تنبيهات التقويم');
  }

  Future<void> _show(int id, String title, String body,
      String channelId, String channelName) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: _soundDetails(channelId, channelName),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Int64List? _getVibrationPattern() {
    switch (_vibration) {
      case 0: return null;
      case 1: return Int64List.fromList([0, 100]);
      case 2: return Int64List.fromList([0, 300]);
      case 3: return Int64List.fromList([0, 100, 50, 100, 50, 300]);
      default: return null;
    }
  }

  Future<void> schedulePrayerNotification(
      int id, String prayerName, DateTime time) async {
    if (!_globalEnabled || !_prayerEnabled) return;
    final now = DateTime.now();
    final scheduledDate = time.isBefore(now)
        ? time.add(const Duration(days: 1))
        : time;

    await _plugin.zonedSchedule(
      id,
      'حان الآن وقت صلاة $prayerName',
      'حان وقت صلاة $prayerName',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: _soundDetails(_prayerChannelId, 'مواقيت الصلاة'),
        iOS: const DarwinNotificationDetails(
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
    if (!_globalEnabled || !_taskEnabled) return;
    await _plugin.zonedSchedule(
      id,
      'تذكير بالمهمة: $title',
      'حان وقت تنفيذ المهمة',
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: _soundDetails('task_channel', 'تنبيهات المهام'),
        iOS: const DarwinNotificationDetails(
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
