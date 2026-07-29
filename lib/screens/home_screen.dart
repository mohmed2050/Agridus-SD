import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'crops_screen.dart';
import 'news_screen.dart';
import 'weather_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Widget> _screens = const [
    CropsScreen(),
    NewsScreen(),
    WeatherScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _screens[provider.currentTabIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: provider.currentTabIndex,
            onTap: (index) => provider.setTabIndex(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.eco),
                label: 'المحاصيل',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'الأخبار',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny),
                label: 'الطقس',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'المهام',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'الإعدادات',
              ),
            ],
          ),
        );
      },
    );
  }
}
