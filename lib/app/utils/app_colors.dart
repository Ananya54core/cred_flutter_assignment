import 'package:flutter/material.dart';

/// Centralized color constants matching the CRED design language.
class AppColors {
  AppColors._();

  // Primary backgrounds
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6E6E7A);
  static const Color textOnDark = Colors.white;

  // Accent / CTA
  static const Color ctaBackground = Color(0xFF1A1A2E);
  static const Color ctaText = Colors.white;

  // Status tags
  static const Color tagOverdue = Color(0xFFD94B4B);
  static const Color tagDueToday = Color(0xFFE8913A);
  static const Color tagUpcoming = Color(0xFF4BA0D9);

  // Dividers & borders
  static const Color divider = Color(0xFFE8E8E8);
  static const Color border = Color(0xFFECECEC);

  // Section header
  static const Color sectionTitle = Color(0xFF6E6E7A);
  static const Color viewAllText = Color(0xFF6E6E7A);
}
