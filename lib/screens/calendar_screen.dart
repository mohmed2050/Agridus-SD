import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_entry.dart';
import '../models/crop.dart';
import 'crop_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Crop>? _crops;

  @override
  void initState() {
    super.initState();
    _loadCrops();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().loadData();
    });
  }

  Future<void> _loadCrops() async {
    final json = await rootBundle.loadString('assets/data/crops.json');
    final data = jsonDecode(json)['crops'] as List;
    _crops = data.map((e) => Crop.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('التقويم الزراعي'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilters(provider),
                    Expanded(child: _buildContent(provider)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilters(CalendarProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(bottom: BorderSide(color: Colors.green.shade200)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: Key('state_${provider.selectedState}'),
            initialValue: provider.selectedState,
            decoration: const InputDecoration(
              labelText: 'اختر الولاية',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            items: provider.states.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (v) {
              if (v != null) provider.setState(v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            key: Key('crop_${provider.selectedCropId}'),
            initialValue: provider.selectedCropId,
            decoration: const InputDecoration(
              labelText: 'اختر المحصول (اختياري)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.eco),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('الكل')),
              DropdownMenuItem(value: 1, child: Text('🌾 أبو سبعين')),
              DropdownMenuItem(value: 2, child: Text('🥜 الفول السوداني')),
              DropdownMenuItem(value: 3, child: Text('🌾 القمح')),
              DropdownMenuItem(value: 4, child: Text('🌱 السمسم')),
              DropdownMenuItem(value: 5, child: Text('🌿 البرسيم')),
            ],
            onChanged: (v) => provider.setCrop(v),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CalendarProvider provider) {
    final entries = provider.filteredEntries;
    if (entries.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات تقويم لهذا الاختيار',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final cropAlerts = provider.getAlertsForCrop(entry.cropId);
          return _buildCropCard(provider, entry, cropAlerts);
        },
      ),
    );
  }

  Widget _buildCropCard(
      CalendarProvider provider, CalendarEntry entry, List<CalendarAlert> alerts) {
    final hasAlerts = alerts.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_cropIcon(entry.cropId),
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _cropName(entry.cropId),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (hasAlerts)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('مفعل',
                        style: TextStyle(
                            fontSize: 12, color: Colors.green)),
                  ),
              ],
            ),
            const Divider(),
            _buildInfoRow('موسم الزراعة', '${entry.plantingStart} - ${entry.plantingEnd}'),
            const Divider(height: 8),
            const Text('الري',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF2E7D32))),
            const SizedBox(height: 4),
            _buildInfoRow('أول ري', 'بعد ${entry.firstIrrigationDays} أيام'),
            if (_crops != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () {
                    final crop = _crops!.firstWhere((c) => c.id == entry.cropId,
                        orElse: () => _crops!.first);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CropDetailScreen(crop: crop),
                      ),
                    );
                  },
                  child: Text(
                    'عرض جدول الري الكامل ←',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            const Divider(height: 8),
            _buildInfoRow('التسميد الأول', 'بعد ${entry.firstFertilizerDays} يوماً'),
            _buildInfoRow('التسميد الثاني', 'بعد ${entry.secondFertilizerDays} يوماً'),
            const Divider(height: 8),
            _buildInfoRow('الحصاد', 'بعد ${entry.harvestDays} يوماً'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                        hasAlerts ? Icons.notifications_off : Icons.notifications,
                        size: 18),
                    label: Text(hasAlerts ? 'إلغاء التنبيهات' : 'تفعيل التنبيهات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasAlerts ? Colors.red.shade400 : const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (hasAlerts) {
                        provider.deleteAlertsForCrop(entry.cropId);
                      } else {
                        provider.generateAlertsForCrop(entry.cropId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تفعيل التنبيهات لـ ${_cropName(entry.cropId)}'),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            if (hasAlerts) ...[
              const SizedBox(height: 8),
              const Text('التنبيهات النشطة:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              ...alerts.map((a) => _buildAlertItem(provider, a)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(CalendarProvider provider, CalendarAlert alert) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: alert.enabled,
            onChanged: (_) {
              if (alert.id != null) provider.toggleAlert(alert.id!);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _alertLabel(alert.alertType),
            style: TextStyle(
              fontSize: 13,
              color: alert.enabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _cropIcon(int id) {
    switch (id) {
      case 1: return '🌾';
      case 2: return '🥜';
      case 3: return '🌾';
      case 4: return '🌱';
      case 5: return '🌿';
      default: return '🌱';
    }
  }

  String _cropName(int id) {
    switch (id) {
      case 1: return 'أبو سبعين (الذرة)';
      case 2: return 'الفول السوداني';
      case 3: return 'القمح';
      case 4: return 'السمسم';
      case 5: return 'البرسيم';
      default: return '';
    }
  }

  String _alertLabel(String type) {
    switch (type) {
      case 'planting': return 'تذكير بزراعة المحصول';
      case 'irrigation1': return 'تذكير بأول ري';
      case 'fertilizer1': return 'تذكير بالتسميد الأول';
      case 'fertilizer2': return 'تذكير بالتسميد الثاني';
      case 'harvest': return 'تذكير بالحصاد';
      default: return type;
    }
  }
}
