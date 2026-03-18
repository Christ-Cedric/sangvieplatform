import 'package:flutter/material.dart';

class AppColors {
  // Surface Colors
  static const Color background = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF0F172A); // Slate 900

  // Brand Colors
  static const Color primary = Color(0xFFE11D48); // Rose 600 - Dynamic Red
  static const Color primarySoft = Color(0xFFFFF1F2); // Rose 50
  static const Color primaryDark = Color(0xFF9F1239); // Rose 800

  static const Color secondary = Color(0xFF64748B); // Slate 500
  static const Color secondarySoft = Color(0xFFF8FAFC); // Slate 50

  // Status Colors
  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color warningOrange = Color(0xFFF59E0B); // Amber 500
  static const Color destructive = Color(0xFFEF4444); // Red 500

  // Neutral Colors
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color inputBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color mutedForeground = Color(0xFF94A3B8); // Slate 400

  // Dark Mode
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkForeground = Color(0xFFF8FAFC); // Slate 50
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkInputBackground = Color(0xFF1E293B); 

  // App Specific
  static const Color sangVieRed = Color(0xFFE11D48);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
  );
}
