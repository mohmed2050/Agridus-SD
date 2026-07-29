import 'package:flutter/material.dart';
import '../models/crop.dart';

class CropDetailScreen extends StatelessWidget {
  final Crop crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(crop.icon, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          Text(
            crop.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            crop.nameEn,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildSection('الآفات', crop.pests, Icons.bug_report),
          _buildSection('الأمراض', crop.diseases, Icons.medical_services),
          _buildSection('موسم الزراعة', crop.season, Icons.calendar_month),
          _buildSection('التربة الملائمة', crop.soil, Icons.landscape),
          _buildSection('فحوصات pH', crop.phLevel, Icons.science),
          _buildSection('تجهيز الأرض', crop.landPrep, Icons.construction),
          _buildSection('طريقة الزراعة', crop.plantingMethod, Icons.grass),
          _buildSection('فترات الري', crop.irrigation, Icons.water_drop),
          _buildSection('التسميد', crop.fertilization, Icons.eco),
          _buildSection('الحصاد', crop.harvest, Icons.content_cut),
          _buildSection(
              'الربحية', crop.profitability, Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
