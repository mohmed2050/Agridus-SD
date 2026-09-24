import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_card.dart';
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

  void _openFilter(BuildContext context, CropProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDarkStart,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final categories = ['', 'حبوب', 'زيتية', 'علفية'];
        final labels = ['جميع المحاصيل', 'الحبوب', 'المحاصيل الزيتية', 'المحاصيل العلفية'];
        final icons = [Icons.eco, Icons.grass, Icons.oil_barrel, Icons.agriculture];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تصفية المحاصيل',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        provider.setFilterCategory(categories[i]);
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: provider.filterCategory == categories[i]
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.searchBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: provider.filterCategory == categories[i]
                                ? AppColors.accent
                                : AppColors.searchBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              icons[i],
                              color: provider.filterCategory == categories[i]
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              labels[i],
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            if (provider.filterCategory == categories[i])
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.accent,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CropProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.primaryDarkStart,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(provider),
                  Expanded(
                    child: provider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          )
                        : provider.filteredCrops.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا توجد محاصيل مطابقة',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                itemCount: provider.filteredCrops.length,
                                itemBuilder: (context, index) {
                                  final crop = provider.filteredCrops[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: CropCard(
                                      crop: crop,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CropProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.primaryDarkEnd],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryDarkStart,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المحاصيل',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'كل ما تحتاج معرفته عن محاصيلك',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.searchBackground,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.searchBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            onChanged: (v) => provider.search(v),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن محصول...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.searchBackground,
                ),
                child: IconButton(
                  onPressed: () => _openFilter(context, provider),
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  tooltip: 'تصفية',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}