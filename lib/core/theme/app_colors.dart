import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE94E91); // Pink from design
  static const Color secondary = Colors.deepPurple;
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF1E1E1E);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;

  static const Color error = Colors.redAccent;
  static const Color success = Colors.greenAccent;

  static Color fromHex(String? hexString, {Color defaultColor = Colors.white}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    // Ensure 8-digit hex (ARGB)
    // If input is 6 hex chars (#FFFFFF) or 7 chars with #, add full opacity (ff)
    if (hexString.replaceFirst('#', '').length == 6) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }
}
