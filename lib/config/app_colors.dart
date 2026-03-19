import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFFDEF2F9);

  // Gradients
  static const List<Color> gradient = [Color(0xFF2563EB), Color(0xFF1E40AF)];
  static const List<Color> lightGradient = [
    Color(0xFFE0F2FE),
    Color(0xFFDEF2F9),
  ];

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFFF3F4F6);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;
}
