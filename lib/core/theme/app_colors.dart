import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7C6EFF);
  static const Color secondary = Color(0xFF5B4FCC);

  // Legacy dark tokens (backward compat)
  static const Color background = Color(0xFF08090F);
  static const Color surface = Color(0xFF10131E);
  static const Color textPrimary = Color(0xFFF0F1F8);
  static const Color textSecondary = Color(0xFF9A9EC8);
  static const Color textTertiary = Color(0xFF5A5F85);

  static const Color error = Color(0xFFFF5E7D);
  static const Color success = Color(0xFF3DD68C);

  // Light tokens
  static const Color lightBackground = Color(0xFFF3F1FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE8E5FF);
  static const Color lightTextPrimary = Color(0xFF0E0F1F);
  static const Color lightTextSecondary = Color(0xFF4A4E7A);
  static const Color lightOutline = Color(0xFFC4C1E8);

  // Dark tokens
  static const Color darkBackground = Color(0xFF08090F);
  static const Color darkSurface = Color(0xFF10131E);
  static const Color darkSurfaceVariant = Color(0xFF191E2E);
  static const Color darkTextPrimary = Color(0xFFF0F1F8);
  static const Color darkTextSecondary = Color(0xFF9A9EC8);
  static const Color darkOutline = Color(0xFF2E3450);

  static final ColorScheme lightColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightTextSecondary,
        outline: lightOutline,
        error: error,
      );

  static final ColorScheme darkColorScheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
        outline: darkOutline,
        error: error,
      );

  static Color fromHex(String? hexString, {Color defaultColor = Colors.white}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    if (hexString.replaceFirst('#', '').length == 6) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }
}
