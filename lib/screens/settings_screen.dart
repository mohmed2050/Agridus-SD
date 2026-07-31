import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import '../providers/app_provider.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import 'profit_calculator_screen.dart';
import 'guide_screen.dart';
import 'market_screen.dart';
import 'extension_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNotificationSettings();
    });
  }

  void _syncNotificationSettings() {
    final p = context.read<AppProvider>();
    NotificationService().updateSettings(
      globalEnabled: p.notificationsEnabled,
      prayerEnabled: p.prayerAlertsEnabled,
      weatherEnabled: p.weatherAlertsEnabled,
      taskEnabled: p.taskAlertsEnabled,
      calendarEnabled: p.calendarAlertsEnabled,
      vibrationIntensity: p.vibrationIntensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSystemStatus(provider),
              const SizedBox(height: 12),
              _buildNotificationsSection(provider),
              const SizedBox(height: 12),
              _buildSoundSection(provider),
              const SizedBox(height: 12),
              _buildGeneralSection(provider),
              const SizedBox(height: 12),
              _buildMenuSection(provider, context),
              const SizedBox(height: 12),
              _buildDataSection(provider, context),
              const SizedBox(height: 12),
              _buildAboutSection(provider, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSystemStatus(AppProvider p) {
    final allOk = p.notificationsEnabled;
    return Card(
      color: allOk ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(allOk ? Icons.check_circle : Icons.warning,
                  color: allOk ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              const Text('حالة النظام',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 8),
            _statusRow('الإشعارات',
                p.notificationsEnabled ? 'مفعلة' : 'معطلة',
                p.notificationsEnabled),
            _statusRow('الصوت', p.selectedSoundName, true),
            _statusRow('الاهتزاز', p.vibrationLabel, true),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ok ? Colors.green[700] : Colors.red)),
      ]),
    );
  }

  Widget _buildNotificationsSection(AppProvider p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('إعدادات الإشعارات', Icons.notifications),
          _buildSwitch('الإشعارات العامة',
              'تعطيل جميع الإشعارات', p.notificationsEnabled, (v) {
            p.setNotificationsEnabled(v);
            _syncNotificationSettings();
          }),
          if (p.notificationsEnabled) ...[
            _buildSwitch('تنبيه الصلاة',
                'إشعارات مواقيت الصلاة', p.prayerAlertsEnabled, (v) {
              p.setPrayerAlertsEnabled(v);
              _syncNotificationSettings();
            }),
            _buildSwitch('تنبيه الطقس',
                'إشعارات حالة الطقس', p.weatherAlertsEnabled, (v) {
              p.setWeatherAlertsEnabled(v);
              _syncNotificationSettings();
            }),
            _buildSwitch('تنبيه المهام',
                'إشعارات تذكير المهام', p.taskAlertsEnabled, (v) {
              p.setTaskAlertsEnabled(v);
              _syncNotificationSettings();
            }),
            _buildSwitch('تنبيه التقويم الزراعي',
                'إشعارات مواعيد الزراعة والحصاد', p.calendarAlertsEnabled, (v) {
              p.setCalendarAlertsEnabled(v);
              _syncNotificationSettings();
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSoundSection(AppProvider p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('إعدادات الصوت', Icons.music_note),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'بعد اختيار الصوت، اضغط "اختبار الإشعار" للتأكد من عمله',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.volume_up),
                label: const Text('اختبار صوت الإشعار'),
                onPressed: () async {
                  _syncNotificationSettings();
                  try {
                    await NotificationService().testPrayerNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إرسال إشعار اختبار - هل سمعت الصوت؟')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل الإشعار: $e')));
                    }
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'صوت التنبيه',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: p.selectedSoundIndex,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('صوت افتراضي')),
                    DropdownMenuItem(value: 1, child: Text('أذان الفجر')),
                    DropdownMenuItem(value: 2, child: Text('أذان عادي')),
                    DropdownMenuItem(value: 3, child: Text('صوت إسلامي')),
                    DropdownMenuItem(value: 4, child: Text('صامت')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    p.setSelectedSound(v);
                    if (v >= 1 && v <= 3) {
                      AudioService().previewSound(v);
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شدة الاهتزاز',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(p.vibrationLabel,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                Slider(
                  value: p.vibrationIntensity.toDouble(),
                  min: 0, max: 3, divisions: 3,
                  label: p.vibrationLabel,
                  onChanged: (v) {
                    p.setVibrationIntensity(v.toInt());
                    _syncNotificationSettings();
                    HapticFeedback.heavyImpact();
                  },
                ),
                Row(children: [
                  Text('بدون', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const Spacer(),
                  Text('قوي', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(AppProvider p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('إعدادات عامة', Icons.tune),
          _buildSwitch('الوضع الليلي',
              'تبديل بين الوضع النهاري والليلي', p.isDarkMode, (_) {
            p.toggleDarkMode();
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('حجم الخط',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Slider(
                  value: p.fontScale,
                  min: 0.8, max: 1.4, divisions: 3,
                  label: '${p.fontScale.toStringAsFixed(1)}x',
                  onChanged: (v) => p.setFontScale(v),
                ),
                Row(children: [
                  Text('صغير', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const Spacer(),
                  Text('كبير', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AppProvider p, BuildContext context) {
    return Column(children: [
      _menuItem(context,
          icon: Icons.calculate,
          title: 'حاسبة الأرباح',
          subtitle: 'احسب تكاليف وأرباح المحاصيل',
          color: const Color(0xFF2E7D32),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProfitCalculatorScreen()))),
      _menuItem(context,
          icon: Icons.science,
          title: 'دليل المبيدات والأسمدة',
          subtitle: 'مبيدات وأسمدة مسجلة في السودان',
          color: Colors.red,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GuideScreen()))),
      _menuItem(context,
          icon: Icons.trending_up,
          title: 'أسعار السوق والتسويق',
          subtitle: 'أسعار المحاصيل في أسواق السودان',
          color: Colors.orange,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MarketScreen()))),
      _menuItem(context,
          icon: Icons.menu_book,
          title: 'الإرشاد الزراعي والطوارئ',
          subtitle: 'دليل زراعي + أرقام طوارئ + تقويم موسمي',
          color: Colors.teal,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ExtensionScreen()))),
    ]);
  }

  Widget _buildDataSection(AppProvider p, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _sectionHeader('البيانات', Icons.storage),
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.backup)),
          title: const Text('نسخ احتياطي',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('تصدير قاعدة البيانات'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _backupData(context),
        ),
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.restore)),
          title: const Text('استعادة بيانات',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('استيراد آخر نسخة احتياطية'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _restoreData(context),
        ),
        ListTile(
          leading: const CircleAvatar(
              backgroundColor: Colors.red, child: Icon(Icons.delete_forever, color: Colors.white)),
          title: const Text('مسح كل البيانات',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          subtitle: const Text('حذف قاعدة البيانات بالكامل'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _clearAllData(context),
        ),
      ]),
    );
  }

  Widget _buildAboutSection(AppProvider p, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _sectionHeader('حول التطبيق', Icons.info_outline),
        ListTile(
          title: const Text('Agridus-SD',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('الإصدار v3.0.0'),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[700])),
      ]),
    );
  }

  Widget _buildSwitch(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value, onChanged: onChanged,
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icon, required String title,
      required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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
              const SnackBar(content: Text('لا توجد قاعدة بيانات للنسخ')));
        }
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final backup = File('${dir.path}/agridus_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      await dbFile.copy(backup.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم النسخ الاحتياطي: ${backup.path}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل النسخ: $e')));
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
              const SnackBar(content: Text('لا توجد نسخ احتياطية')));
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
            const SnackBar(content: Text('تمت استعادة آخر نسخة')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل الاستعادة: $e')));
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد مسح البيانات'),
        content: const Text('سيتم حذف جميع البيانات. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد المسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final confirmed2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد نهائي'),
        content: const Text('هل أنت متأكد تماماً؟ لا يمكن استعادة البيانات بعد الحذف.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح الكل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed2 != true || !context.mounted) return;

    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/agridus.db');
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم مسح جميع البيانات')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل المسح: $e')));
      }
    }
  }
}
