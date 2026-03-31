import 'package:flutter/material.dart';

class AppColors {
  // Primary Academic Colors (Classic Blue / Clear Ivory)
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1E40AF); // Deep Blue
  static const Color primaryLight = Color(0xFF60A5FA); // Light Blue
  static const Color accent = Color(0xFF3B82F6); // Soft Blue Accent

  // Clean Professional Gradients
  static const List<Color> gradient = [Color(0xFF2563EB), Color(0xFF60A5FA)];
  static const List<Color> premiumDarkGradient = [
    Color(0xFF1E293B),
    Color(0xFF0F172A)
  ];
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFC)
  ];
  static const List<Color> lightGradient = [
    Color(0xFFEFF6FF),
    Color(0xFFDBEAFE),
  ];

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF0EA5E9); // Sky

  // Modern Light Mode Neutral Colors
  static const Color bgDark = Color(0xFFF1F5F9); // Light grayish blue background
  static const Color bgLight = Color(0xFFF8FAFC); // Very light background
  static const Color bgWhite = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  static const Color textDark = Color(0xFF0F172A); // Almost black
  static const Color textMedium = Color(0xFF475569); // Slate gray
  static const Color textLight = Color(0xFF94A3B8); // Light gray
  static const Color border = Color(0xFFE2E8F0); // Subtle borders
  static const Color borderColor = Color(0xFFE2E8F0);

  // Glassmorphism effects (Light Mode)
  static const Color glassDefault = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  // Shadow Colors
  static const Color shadowColor = Color(0x0F0F172A); // Very soft dark shadow for depth
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
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;
}
