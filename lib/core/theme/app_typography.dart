import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'GoogleSans';
  static const List<String> fallbackFontFamilies = [
    'Segoe UI',
    'Roboto',
    'Arial',
  ];

  static TextTheme textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final themed = base.apply(
      fontFamily: fontFamily,
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    return themed.copyWith(
      headlineLarge: themed.headlineLarge?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        height: 1.35,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        height: 1.4,
      ),
      bodySmall: themed.bodySmall?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        color: secondaryText,
        height: 1.4,
      ),
      labelLarge: themed.labelLarge?.copyWith(
        fontFamilyFallback: fallbackFontFamilies,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
