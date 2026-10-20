import 'package:flutter/material.dart';

/// Awake Coffee brand colors
/// Brand guideline: combination red with black, clean background
class AppColors {
  AppColors._();

  // Primary Colors - Red accent
  static const Color primary = Color(0xFFE81514); // Awake red
  static const Color primaryDark = Color(0xFFC41210); // Darker red

  // Text Colors
  static const Color textPrimary = Color(0xFF0C151A); // Awake black
  static const Color textSecondary = Color(0xFFAEAEAE); // Soft gray
  static const Color textWhite = Colors.white;

  // Background Colors - Clean
  static const Color background = Color(0xFFF3F4EF); // Awake cream
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF7AC56A); // Green
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE81514); // Red
  static const Color info = Color(0xFF7FC4EB); // Blue

  // Brand Colors
  static const Color blue = Color(0xFF7FC4EB);
  static const Color green = Color(0xFF7AC56A);
  static const Color red = Color(0xFFE81514);
  static const Color brown = Color(0xFF92431B);

  // Other Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color overlay = Colors.black54;

  // Coffee themed
  static const Color coffeeBrown = Color(0xFF92431B);
  static const Color coffeeLight = Color(0xFF8D6E63);
}
