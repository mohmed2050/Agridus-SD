import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/crop_cost_data.dart';
import '../services/database_service.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  CropCostData? _selectedCrop;
  double _feddans = 5;
  List<Map<String, dynamic>> _history = [];
  bool _showResult = false;

  final _formatter = NumberFormat('#,###', 'ar');

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = DatabaseService();
    final rows = await db.query('profit_calculations',
        orderBy: 'created_at DESC', where: null);
    setState(() => _history = rows);
  }

  Future<void> _saveCalculation() async {
    if (_selectedCrop == null) return;
    final c = _selectedCrop!;
    final totalCost = c.totalCostPerFeddan * _feddans;
    final totalProduction = c.expectedProductionKg * _feddans;
    final totalRevenue = c.revenuePerFeddan * _feddans;
    final netProfit = c.netProfitPerFeddan * _feddans;

    final db = DatabaseService();
    await db.insert('profit_calculations', {
      'crop_id': c.id,
      'crop_name': c.name,
      'feddans': _feddans,
      'seed_cost': c.seedCost * _feddans,
      'fertilizer_cost': c.fertilizerCost * _feddans,
      'irrigation_cost': c.irrigationCost * _feddans,
      'labor_cost': c.laborCost * _feddans,
      'pesticide_cost': c.pesticideCost * _feddans,
      'total_cost': totalCost,
      'expected_production': totalProduction,
      'price_per_kg': c.pricePerKg,
      'total_revenue': totalRevenue,
      'net_profit': netProfit,
      'created_at': DateTime.now().toIso8601String(),
    });

    _loadHistory();
  }

  String _fmt(double v) => _formatter.format(v);

  CropCostData get _mostProfitableCrop {
    final sorted = [...CropCostData.all]
      ..sort((a, b) => b.netProfitPerFeddan.compareTo(a.netProfitPerFeddan));
    return sorted.first;
  }

  Future<void> _shareResult(CropCostData c) async {
    final totalCost = c.totalCostPerFeddan * _feddans;
    final totalProduction = c.expectedProductionKg * _feddans;
    final totalRevenue = c.revenuePerFeddan * _feddans;
    final netProfit = c.netProfitPerFeddan * _feddans;

    final text = '''
🌾 حاسبة الأرباح - Agridus-SD
المحصول: ${c.icon} ${c.name}
المساحة: ${_feddans.toStringAsFixed(0)} فدان

التكاليف:
- البذور: ${_fmt(c.seedCost * _feddans)} ج.س
- التسميد: ${_fmt(c.fertilizerCost * _feddans)} ج.س
- الري: ${_fmt(c.irrigationCost * _feddans)} ج.س
- العمالة: ${_fmt(c.laborCost * _feddans)} ج.س
- المبيدات: ${_fmt(c.pesticideCost * _feddans)} ج.س
- إجمالي التكاليف: ${_fmt(totalCost)} ج.س

الإنتاج المتوقع: ${_fmt(totalProduction)} كجم
الإيراد المتوقع: ${_fmt(totalRevenue)} ج.س
صافي الربح المتوقع: ${_fmt(netProfit)} ج.س
''';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر المشاركة: $e')));
    }
  }

  Widget _buildCostRow(String label, double amount,
      {bool isTotal = false, String unit = 'ج.س'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14))),
          Text('${_fmt(amount)} $unit',
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                  color: isTotal
                      ? const Color(0xFF2E7D32)
                      : Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الأرباح'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مقارنة الربحية (لكل فدان)',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...CropCostData.all.map((c) {
                    final isBest = c.id == _mostProfitableCrop.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('${c.icon} ${c.name}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isBest
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          const Spacer(),
                          Text('${_fmt(c.netProfitPerFeddan)} ج.س',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isBest
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: c.netProfitPerFeddan > 0
                                      ? Colors.green.shade700
                                      : Colors.red)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'أعلى ربحية حالياً: ${_mostProfitableCrop.name}',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختر المحصول',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: Key('crop_${_selectedCrop?.id}'),
                    initialValue: _selectedCrop?.id,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'اختر المحصول',
                    ),
                    items: CropCostData.all.map((c) {
                      return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.icon} ${c.name}'));
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCrop =
                            CropCostData.all.firstWhere((c) => c.id == v);
                        _showResult = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('عدد الفدادين',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('1'),
                      Expanded(
                        child: Slider(
                          value: _feddans,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          label: _feddans.toStringAsFixed(0),
                          activeColor: const Color(0xFF2E7D32),
                          onChanged: (v) {
                            setState(() {
                              _feddans = v.roundToDouble();
                              _showResult = false;
                            });
                          },
                        ),
                      ),
                      const Text('100'),
                    ],
                  ),
                  Center(
                    child: Text('${_feddans.toStringAsFixed(0)} فدان',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate),
                      label: const Text('احسب',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _selectedCrop == null
                          ? null
                          : () {
                              setState(() => _showResult = true);
                              _saveCalculation();
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showResult && _selectedCrop != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(_selectedCrop!),
          ],
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('آخر الحسابات',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const SizedBox(height: 8),
            ..._history.take(5).map((h) => _buildHistoryItem(h)),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(CropCostData c) {
    final totalCost = c.totalCostPerFeddan * _feddans;
    final totalProduction = c.expectedProductionKg * _feddans;
    final totalRevenue = c.revenuePerFeddan * _feddans;
    final netProfit = c.netProfitPerFeddan * _feddans;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: netProfit > 0 ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(c.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(c.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_feddans.toStringAsFixed(0)} فدان',
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const Divider(),
            const Text('تفاصيل التكاليف:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            _buildCostRow('تكلفة البذور', c.seedCost * _feddans),
            _buildCostRow('التسميد', c.fertilizerCost * _feddans),
            _buildCostRow('الري', c.irrigationCost * _feddans),
            _buildCostRow('العمالة', c.laborCost * _feddans),
            _buildCostRow('المبيدات', c.pesticideCost * _feddans),
            const Divider(),
            _buildCostRow('إجمالي التكاليف', totalCost, isTotal: true),
            const SizedBox(height: 8),
            _buildCostRow(
                'الإنتاج المتوقع', totalProduction.toDouble(),
                isTotal: true, unit: 'كجم'),
            _buildCostRow('الإيراد المتوقع', totalRevenue, isTotal: true),
            const Divider(thickness: 2),
            _buildCostRow('صافي الربح', netProfit, isTotal: true),
            if (netProfit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text('مشروع مربح 👍',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('المشروع غير مربح حالياً',
                        style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: const Text('مشاركة النتيجة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: BorderSide(color: Colors.green.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _shareResult(c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> h) {
    final profit = (h['net_profit'] as num?)?.toDouble() ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Text(
          _cropIcon(h['crop_id'] as int? ?? 0),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(h['crop_name'] ?? '',
            style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          '${_fmt(h['feddans']?.toDouble() ?? 0)} فدان',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${profit >= 0 ? '+' : ''}${_fmt(profit)} ج.س',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: profit >= 0 ? Colors.green : Colors.red,
          ),
        ),
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
}
