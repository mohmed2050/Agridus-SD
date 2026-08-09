import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'crops_screen.dart';
import 'news_screen.dart';
import 'weather_screen.dart';
import 'calendar_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = const [
    CropsScreen(),
    NewsScreen(),
    WeatherScreen(),
    CalendarScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  final Set<int> _visitedTabs = {0};

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!_visitedTabs.contains(provider.currentTabIndex)) {
          _visitedTabs.add(provider.currentTabIndex);
        }
        return Scaffold(
          body: IndexedStack(
            index: provider.currentTabIndex,
            children: [
              for (var i = 0; i < _screens.length; i++)
                _visitedTabs.contains(i) ? _screens[i] : const SizedBox.shrink(),
            ],
          ),
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
                icon: Icon(Icons.calendar_month),
                label: 'التقويم',
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
