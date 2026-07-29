import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guide_provider.dart';
import 'pesticide_detail_screen.dart';
import 'fertilizer_detail_screen.dart';

class GuideScreen extends StatefulWidget {
  final int? initialCropId;
  final int? initialTab;

  const GuideScreen({super.key, this.initialCropId, this.initialTab});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab ?? 0);
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GuideProvider>();
      provider.loadData();
      if (widget.initialCropId != null) {
        provider.filterByCrop(widget.initialCropId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل المبيدات والأسمدة'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'المبيدات', icon: Icon(Icons.science, size: 18)),
            Tab(text: 'الأسمدة', icon: Icon(Icons.eco, size: 18)),
          ],
        ),
      ),
      body: Consumer<GuideProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchBar(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPesticidesList(provider),
                    _buildFertilizersList(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(GuideProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(bottom: BorderSide(color: Colors.green.shade200)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث بالاسم أو الآفة...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.search('');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => provider.search(v),
          ),
          if (provider.filterCropId != null) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(
                'الفلترة: ${_cropName(provider.filterCropId!)}',
                style: const TextStyle(fontSize: 13),
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              backgroundColor: Colors.green.shade100,
              onDeleted: () => provider.filterByCrop(null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPesticidesList(GuideProvider provider) {
    final list = provider.filteredPesticides;
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return const Center(
        child: Text('لا توجد مبيدات مطابقة',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final p = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                child:
                    const Icon(Icons.science, color: Colors.red),
              ),
              title: Text(p.tradeName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('المادة الفعالة: ${p.activeIngredient}',
                      style: const TextStyle(fontSize: 12)),
                  Text(p.targets,
                      style: const TextStyle(fontSize: 12, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PesticideDetailScreen(pesticide: p)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFertilizersList(GuideProvider provider) {
    final list = provider.filteredFertilizers;
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (list.isEmpty) {
      return const Center(
        child: Text('لا توجد أسمدة مطابقة',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final f = list[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
              ),
              title: Text(f.tradeName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${f.fertilizerType} | ${f.npk}',
                      style: const TextStyle(fontSize: 12)),
                  Text(f.targetCrops,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FertilizerDetailScreen(fertilizer: f)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _cropName(int id) {
    switch (id) {
      case 1: return 'أبو سبعين';
      case 2: return 'الفول السوداني';
      case 3: return 'القمح';
      case 4: return 'السمسم';
      case 5: return 'البرسيم';
      default: return '';
    }
  }
}
