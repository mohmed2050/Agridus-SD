import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/crop.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;

  const CropCard({super.key, required this.crop, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool gold = crop.iconTheme == 'gold';
    final Color themeColor = gold ? AppColors.iconGold : AppColors.iconGreen;
    final IconData themeIcon = gold ? Icons.grass : Icons.eco;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: crop.image.isNotEmpty
                      ? Image.asset(
                          crop.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 160,
                          errorBuilder: (context, error, stackTrace) =>
                              _imageFallback(themeColor, themeIcon),
                        )
                      : _imageFallback(themeColor, themeIcon),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 160,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.overlayTop],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(themeIcon, color: themeColor, size: 22),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.panelBackground,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    crop.nameEn,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          crop.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _badge(Icons.wb_sunny_outlined,
                                  'موسم الزراعة', crop.seasonMonths),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _badge(
                                  Icons.access_time, 'مدة النمو', crop.growthDays),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _badge(
                                  Icons.eco_outlined, 'متوسط الإنتاج', crop.averageYield),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 9),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'عرض المزيد',
                                    style: TextStyle(
                                      color: Color(0xFF0F3D2E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF0F3D2E),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pillBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.searchBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(Color themeColor, IconData themeIcon) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E42), Color(0xFF0F3D2E)],
        ),
      ),
      child: Center(
        child: Icon(themeIcon, color: themeColor.withValues(alpha: 0.7), size: 56),
      ),
    );
  }
}