import 'package:flutter/material.dart';

class AppColors {
  // Surface Colors
  static const Color background = Color(0xFFF8F9FA); // New Auth Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF2D3748); // Slate 800

  // Brand Colors
  static const Color primary = Color(0xFFE53E3E); // Auth Red
  static const Color primarySoft = Color(0xFFFFF5F5); // Red 50
  static const Color primaryDark = Color(0xFFC53030); // Red 700

  static const Color secondary = Color(0xFF718096); // Slate 500
  static const Color secondarySoft = Color(0xFFEDF2F7); // Slate 100

  // Status Colors
  static const Color successGreen = Color(0xFF38A169); // Green 600
  static const Color warningOrange = Color(0xFFDD6B20); // Orange 600
  static const Color destructive = Color(0xFFE53E3E); // Auth Red

  // Neutral Colors
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color inputBackground = Color(0xFFFFFFFF); // White for inputs
  static const Color mutedForeground = Color(0xFFA0AEC0); // Slate 400

  // Dark Mode
  static const Color darkBackground = Color(0xFF1A202C); // Gray 900
  static const Color darkSurface = Color(0xFF2D3748); // Gray 800
  static const Color darkForeground = Color(0xFFF7FAFC); // Gray 50
  static const Color darkBorder = Color(0xFF4A5568); // Gray 700
  static const Color darkInputBackground = Color(0xFF2D3748); 

  // App Specific
  static const Color sangVieRed = Color(0xFFE53E3E);

  // Admin Theme
  static const Color adminPrimary = Color(0xFF0F172A); // Slate 900
  static const Color adminAccent = Color(0xFF4F46E5); // Indigo 600
  static const Color adminSurface = Color(0xFF1E293B); // Slate 800

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
  );

  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFF0F2F5),
    ],
  );
}
