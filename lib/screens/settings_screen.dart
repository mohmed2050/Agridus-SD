import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../providers/app_provider.dart';
import 'profit_calculator_screen.dart';
import 'guide_screen.dart';
import 'market_screen.dart';
import 'extension_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: CircleAvatar(
                    backgroundColor: Colors.grey.withAlpha(30),
                    child: Icon(
                        provider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.grey),
                  ),
                  title: const Text('الوضع الليلي',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('تبديل بين الوضع النهاري والليلي'),
                  value: provider.isDarkMode,
                  onChanged: (_) => provider.toggleDarkMode(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.calculate,
            title: 'حاسبة الأرباح',
            subtitle: 'احسب تكاليف وأرباح المحاصيل',
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfitCalculatorScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.science,
            title: 'دليل المبيدات والأسمدة',
            subtitle: 'مبيدات وأسمدة مسجلة في السودان',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GuideScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.trending_up,
            title: 'أسعار السوق والتسويق',
            subtitle: 'أسعار المحاصيل في أسواق السودان + حاسبة التسويق',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.menu_book,
            title: 'الإرشاد الزراعي والطوارئ',
            subtitle: 'دليل زراعي + أرقام طوارئ + تقويم موسمي',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExtensionScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.backup,
            title: 'النسخ الاحتياطي',
            subtitle: 'إنشاء نسخة احتياطية أو استعادة البيانات',
            color: Colors.blue,
            onTap: () => _showBackupDialog(context),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'حول التطبيق',
            subtitle: 'Agridus-SD v2.0.0',
            color: Colors.grey,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Agridus-SD',
                applicationVersion: 'v2.0.0',
                applicationIcon: const Icon(
                  Icons.eco,
                  color: Color(0xFF2E7D32),
                  size: 48,
                ),
                children: [
                  const Text(
                    'تطبيق زراعي سوداني متكامل\n'
                    'يعمل بدون إنترنت\n'
                    'للمزارعين السودانيين',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('النسخ الاحتياطي'),
        content: const Text('اختر نسخ احتياطي أو استعادة البيانات'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _backupData(context);
            },
            icon: const Icon(Icons.backup),
            label: const Text('نسخ احتياطي'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _restoreData(context);
            },
            icon: const Icon(Icons.restore),
            label: const Text('استعادة'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/agridus.db');
      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد قاعدة بيانات للنسخ')),
          );
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final backup = File('${dir.path}/agridus_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      await dbFile.copy(backup.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم النسخ الاحتياطي بنجاح:\n${backup.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل النسخ: $e')),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backups = await dir.list().where((e) =>
          e.path.endsWith('.db') && e.path.contains('agridus_backup')).toList();
      if (backups.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد نسخ احتياطية')),
          );
        }
        return;
      }
      backups.sort((a, b) => b.path.compareTo(a.path));
      final dbPath = await getDatabasesPath();
      final src = File(backups.first.path);
      final dst = File('$dbPath/agridus.db');
      await src.copy(dst.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت استعادة آخر نسخة احتياطية')),

        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الاستعادة: $e')),
        );
      }
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
