import 'package:flutter/material.dart';
import '../models/pesticide.dart';

class PesticideDetailScreen extends StatelessWidget {
  final Pesticide pesticide;

  const PesticideDetailScreen({super.key, required this.pesticide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pesticide.tradeName),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.science,
                          color: Color(0xFF2E7D32), size: 24),
                      SizedBox(width: 8),
                      Text('معلومات المبيد',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  _buildRow('الاسم التجاري', pesticide.tradeName),
                  _buildRow('المادة الفعالة', pesticide.activeIngredient),
                  _buildRow('الآفة/المرض المستهدف', pesticide.targets),
                  _buildRow('المحاصيل المسموح بها', pesticide.crops),
                  _buildRow('الجرعة', pesticide.dosage),
                  _buildRow('طريقة الاستخدام', pesticide.usageMethod),
                  _buildRow('فترة الأمان', pesticide.safetyPeriod),
                  _buildWarning(pesticide.warnings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF2E7D32))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildWarning(String warning) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(warning,
                style: const TextStyle(
                    color: Colors.red, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
