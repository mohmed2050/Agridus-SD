import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _productionController = TextEditingController();
  bool _showCalculator = false;
  Map<String, double>? _calcResults;

  static const _crops = {
    1: 'أبو سبعين',
    2: 'الفول السوداني',
    3: 'القمح',
    4: 'السمسم',
    5: 'البرسيم',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _productionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أسعار السوق'),
          actions: [
            IconButton(
              icon: Icon(_showCalculator ? Icons.table_chart : Icons.calculate),
              onPressed: () => setState(() => _showCalculator = !_showCalculator),
              tooltip: _showCalculator ? 'عرض الأسعار' : 'حاسبة التسويق',
            ),
          ],
        ),
        body: Consumer<MarketProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _showCalculator
                ? _buildCalculator(provider)
                : _buildPriceTable(provider);
          },
        ),
      ),
    );
  }

  Widget _buildPriceTable(MarketProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.green.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'آخر تحديث: ${_formatDate(DateTime.now())}',
              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'اختر المحصول',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: provider.selectedCropId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('جميع المحاصيل')),
                  ..._crops.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      )),
                ],
                onChanged: (v) => provider.selectCrop(v),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('السوق')),
                  DataColumn(label: Text('السعر (جنيه)'), numeric: true),
                  DataColumn(label: Text('التغير'), numeric: true),
                ],
                rows: _buildRows(provider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DataRow> _buildRows(MarketProvider provider) {
    final list = provider.filteredPrices;
    if (_crops.isEmpty) return [];
    if (list.isEmpty) {
      return [const DataRow(cells: [DataCell(Text('لا توجد بيانات'))])];
    }

    final Map<String, double> bestPerCrop = {};
    for (final cropId in _crops.keys) {
      final best = provider.bestPrice(cropId);
      if (best != null) {
        bestPerCrop[cropId.toString()] = best.price;
      }
    }

    return list.map((mp) {
      final isBest = bestPerCrop[mp.cropId.toString()] == mp.price;
      return DataRow(
        color: isBest ? WidgetStateProperty.all(Colors.green.shade100) : null,
        cells: [
          DataCell(Text(mp.marketName)),
          DataCell(Text('${mp.price.toStringAsFixed(0)} ج')),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${mp.changePercent.toStringAsFixed(1)}%'),
              const SizedBox(width: 4),
              Icon(
                mp.isUp
                    ? Icons.arrow_upward
                    : mp.isDown
                        ? Icons.arrow_downward
                        : Icons.remove,
                size: 16,
                color: mp.isUp
                    ? Colors.red
                    : mp.isDown
                        ? Colors.green
                        : Colors.grey,
              ),
            ],
          )),
        ],
      );
    }).toList();
  }

  Widget _buildCalculator(MarketProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حاسبة التسويق',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'المحصول',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: provider.selectedCropId ?? 1,
                        items: _crops.entries.map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            )).toList(),
                        onChanged: (v) => provider.selectCrop(v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _productionController,
                    decoration: const InputDecoration(
                      labelText: 'الإنتاج المتوقع (كجم)',
                      border: OutlineInputBorder(),
                      suffixText: 'كجم',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('احسب'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_calcResults != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نتائج الحساب',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._calcResults!.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key),
                              Text('${e.value.toStringAsFixed(0)} ج',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _calculate() {
    final provider = context.read<MarketProvider>();
    final cropId = provider.selectedCropId ?? 1;
    final production = double.tryParse(_productionController.text);
    if (production == null || production <= 0) return;

    final results = <String, double>{};
    double bestRevenue = 0;
    String bestMarket = '';

    for (final market in provider.markets) {
      final mp = provider.pricesForMarketAndCrop(market, cropId);
      if (mp != null) {
        final revenue = production * mp.price;
        results['$market: ربح'] = revenue;
        if (revenue > bestRevenue) {
          bestRevenue = revenue;
          bestMarket = market;
        }
      }
    }

    results['⭐ أفضل سوق'] = bestRevenue;
    results['السوق الأفضل'] = 0;

    setState(() {
      _calcResults = results;
      _showCalculator = true;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('أفضل سوق لك'),
        content: Text(
            'أفضل سوق لبيع محصولك هو $bestMarket بإجمالي أرباح ${bestRevenue.toStringAsFixed(0)} جنيه'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  }
}
