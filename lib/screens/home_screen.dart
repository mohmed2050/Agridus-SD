import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
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
    SettingsScreen(),
    CropsScreen(),
    CalendarScreen(),
    WeatherScreen(),
    NewsScreen(),
    TasksScreen(),
  ];

  final Set<int> _visitedTabs = {1};

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
          bottomNavigationBar: _BottomNavBar(
            currentIndex: provider.currentTabIndex,
            onTap: (index) => provider.setTabIndex(index),
          ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const List<IconData> _icons = [
    Icons.settings_outlined,
    Icons.eco,
    Icons.calendar_month_outlined,
    Icons.wb_sunny_outlined,
    Icons.description_outlined,
    Icons.spa_outlined,
  ];

  static const List<IconData> _activeIcons = [
    Icons.settings,
    Icons.eco,
    Icons.calendar_month,
    Icons.wb_sunny,
    Icons.description,
    Icons.spa,
  ];

  static const List<String> _labels = [
    'الإعدادات',
    'المحاصيل',
    'التقويم',
    'الطقس',
    'الأخبار',
    'الرئيسية',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDarkEnd, AppColors.primaryDarkStart],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: currentIndex == i ? 46 : 34,
                          height: currentIndex == i ? 46 : 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == i
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                          child: Icon(
                            currentIndex == i ? _activeIcons[i] : _icons[i],
                            color: currentIndex == i
                                ? AppColors.primaryDarkStart
                                : AppColors.textSecondary,
                            size: currentIndex == i ? 24 : 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            color: currentIndex == i
                                ? AppColors.accent
                                : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: currentIndex == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}