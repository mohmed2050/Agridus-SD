import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDarkStart = Color(0xFF0F3D2E);
  static const Color primaryDarkEnd = Color(0xFF1B5E42);
  static const Color accent = Color(0xFF5FBF7F);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8D8C8);
  static const Color overlayTop = Color(0x9905190F);
  static const Color panelBackground = Color(0xEA0F3D2E);
  static const Color pillBackground = Color(0x660F3D2E);
  static const Color searchBackground = Color(0x660F281E);
  static const Color searchBorder = Color(0x40FFFFFF);
  static const Color iconGold = Color(0xFFF2D77C);
  static const Color iconGreen = Color(0xFF7FC87F);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDarkStart, primaryDarkEnd],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDarkStart, primaryDarkEnd],
  );
}