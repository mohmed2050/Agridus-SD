import 'package:flutter/material.dart';
import '../models/pesticide.dart';

class FertilizerDetailScreen extends StatelessWidget {
  final Fertilizer fertilizer;

  const FertilizerDetailScreen({super.key, required this.fertilizer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fertilizer.tradeName),
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
                      Icon(Icons.eco,
                          color: Color(0xFF2E7D32), size: 24),
                      SizedBox(width: 8),
                      Text('معلومات السماد',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  _buildRow('الاسم التجاري', fertilizer.tradeName),
                  _buildRow('النوع', fertilizer.fertilizerType),
                  _buildRow('العناصر (NPK)', fertilizer.npk),
                  _buildRow('المحاصيل المستهدفة', fertilizer.targetCrops),
                  _buildRow('الجرعة', fertilizer.dosage),
                  _buildRow('موعد الاستخدام', fertilizer.applicationTime),
                  _buildRow('طريقة التطبيق', fertilizer.applicationMethod),
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
}
