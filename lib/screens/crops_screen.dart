import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_provider.dart';
import 'crop_detail_screen.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadCrops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CropProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('المحاصيل'),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.crops.isEmpty
                  ? const Center(child: Text('لا توجد محاصيل'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.crops.length,
                      itemBuilder: (context, index) {
                        final crop = provider.crops[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Text(
                              crop.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                            title: Text(
                              crop.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              crop.nameEn,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CropDetailScreen(crop: crop),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
