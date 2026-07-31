import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:adhan_dart/adhan_dart.dart';
import '../services/notification_service.dart';

class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int weatherCode;
  final String description;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.description,
  });
}

class PrayerTimeData {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimeData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class WeatherService {
  static const double _defaultLat = 15.5007;
  static const double _defaultLon = 32.5599;

  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'سماء صافية';
      case 1:
      case 2:
      case 3:
        return 'غائم جزئياً';
      case 45:
      case 48:
        return 'ضباب';
      case 51:
      case 53:
      case 55:
        return 'رذاذ';
      case 61:
      case 63:
      case 65:
        return 'أمطار';
      case 71:
      case 73:
      case 75:
        return 'ثلوج';
      case 80:
      case 81:
      case 82:
        return 'زخات مطر';
      case 95:
        return 'عواصف رعدية';
      case 96:
      case 99:
        return 'عواصف رعدية وبرد';
      default:
        return 'طقس متغير';
    }
  }

  static Future<WeatherData?> fetchWeather(
      {double? lat, double? lon}) async {
    final latitude = lat ?? _defaultLat;
    final longitude = lon ?? _defaultLon;
    String? lastError;

    for (int attempt = 0; attempt < 3; attempt++) {
      for (final protocol in ['https', 'http']) {
        try {
          final response = await http.get(
            Uri.parse(
                '$protocol://api.open-meteo.com/v1/forecast'
                '?latitude=$latitude&longitude=$longitude'
                '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code'
                '&timezone=Africa/Khartoum'),
          ).timeout(const Duration(seconds: 12));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final current = data['current'];
            final code = current['weather_code'] ?? 0;

            return WeatherData(
              temperature: (current['temperature_2m'] ?? 0).toDouble(),
              humidity: (current['relative_humidity_2m'] ?? 0).toDouble(),
              windSpeed: (current['wind_speed_10m'] ?? 0).toDouble(),
              weatherCode: code,
              description: _getWeatherDescription(code),
            );
          }
          lastError = 'الخادم أعاد رمز ${response.statusCode}';
        } catch (e) {
          lastError = e is TimeoutException
              ? 'انتهت مهلة الاتصال'
              : e.toString();
        }
      }

      if (attempt < 2) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    debugPrint('WeatherService: جميع المحاولات فشلت - $lastError');
    return null;
  }

  static Future<void> checkWeatherAlert(WeatherData weather) async {
    String? alert;

    if (weather.weatherCode >= 95) {
      alert = 'أمطار غزيرة وعواصف رعدية متوقعة اليوم';
    } else if (weather.weatherCode >= 80) {
      alert = 'أمطار متوقعة اليوم - تجنب العمل في الحقول المفتوحة';
    } else if (weather.temperature > 42) {
      alert = 'حرارة شديدة اليوم (${weather.temperature.toStringAsFixed(0)}°م)';
    } else if (weather.windSpeed > 50) {
      alert =
          'رياح شديدة السرعة (${weather.windSpeed.toStringAsFixed(0)} كم/س)';
    }

    if (alert != null) {
      await NotificationService().showWeatherAlert(alert);
    }
  }

  static PrayerTimeData calculatePrayerTimes({
    double? lat,
    double? lon,
  }) {
    final latitude = lat ?? _defaultLat;
    final longitude = lon ?? _defaultLon;
    final now = DateTime.now();

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethodParameters.egyptian();

    final prayerTimes = PrayerTimes(
      date: DateTime(now.year, now.month, now.day),
      coordinates: coordinates,
      calculationParameters: params,
    );

    String format(DateTime dt) {
      final khartoum = dt.add(const Duration(hours: 2));
      return '${khartoum.hour.toString().padLeft(2, '0')}:${khartoum.minute.toString().padLeft(2, '0')}';
    }

    return PrayerTimeData(
      fajr: format(prayerTimes.fajr),
      sunrise: format(prayerTimes.sunrise),
      dhuhr: format(prayerTimes.dhuhr),
      asr: format(prayerTimes.asr),
      maghrib: format(prayerTimes.maghrib),
      isha: format(prayerTimes.isha),
    );
  }

  static Future<void> schedulePrayerNotifications({
    double? lat,
    double? lon,
  }) async {
    final latitude = lat ?? _defaultLat;
    final longitude = lon ?? _defaultLon;
    final now = DateTime.now();

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethodParameters.egyptian();

    final prayerTimes = PrayerTimes(
      date: DateTime(now.year, now.month, now.day),
      coordinates: coordinates,
      calculationParameters: params,
    );

    final prayers = {
      'الفجر': prayerTimes.fajr,
      'الظهر': prayerTimes.dhuhr,
      'العصر': prayerTimes.asr,
      'المغرب': prayerTimes.maghrib,
      'العشاء': prayerTimes.isha,
    };

    int id = 3000;
    for (final entry in prayers.entries) {
      final notificationTime =
          entry.value.subtract(const Duration(minutes: 10));
      await NotificationService()
          .schedulePrayerNotification(id++, entry.key, notificationTime);
    }
  }
}
