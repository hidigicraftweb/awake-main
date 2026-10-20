import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Awake Coffee text styles
/// Brand guideline: strong typography with Plus Jakarta Sans
class AppTextStyles {
  AppTextStyles._();

  // Headings - Bold and strong
  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get heading4 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyLargeSemibold => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySemibold => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Caption
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button text
  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  // Price text
  static TextStyle get price => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.3,
  );

  // Helper methods
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle secondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }

  static TextStyle white(TextStyle style) {
    return style.copyWith(color: AppColors.textWhite);
  }
}
