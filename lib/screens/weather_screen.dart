import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('الطقس والمواقيت'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.loadData(),
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                      onRefresh: () => provider.loadData(),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildWeatherCard(provider),
                          const SizedBox(height: 16),
                          _buildPrayerTimesCard(provider),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildWeatherCard(WeatherProvider provider) {
    final weather = provider.weather;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      provider.locationName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (weather != null) ...[
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°م',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weather.description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWeatherInfo(
                        Icons.water_drop, 'الرطوبة', '${weather.humidity.toStringAsFixed(0)}%'),
                    _buildWeatherInfo(
                        Icons.air, 'الرياح', '${weather.windSpeed.toStringAsFixed(0)} كم/س'),
                  ],
                ),
              ] else ...[
                const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'تعذر تحميل بيانات الطقس',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('إعادة المحاولة', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: () => provider.loadData(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPrayerTimesCard(WeatherProvider provider) {
    final prayers = provider.prayerTimes;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mosque, color: Color(0xFF2E7D32), size: 24),
                SizedBox(width: 8),
                Text(
                  'مواقيت الصلاة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (prayers != null) ...[
              _buildPrayerRow('الفجر', prayers.fajr, Icons.wb_twilight),
              _buildPrayerRow('الشروق', prayers.sunrise, Icons.sunny),
              _buildPrayerRow('الظهر', prayers.dhuhr, Icons.wb_sunny),
              _buildPrayerRow('العصر', prayers.asr, Icons.wb_cloudy),
              _buildPrayerRow('المغرب', prayers.maghrib, Icons.bedtime),
              _buildPrayerRow('العشاء', prayers.isha, Icons.nightlight),
            ] else
              const Center(child: Text('تعذر حساب مواقيت الصلاة')),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRow(String name, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
