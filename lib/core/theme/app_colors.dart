import 'package:flutter/material.dart';

/// Design system colors - amber and true black theme
/// Based on the reference app's design tokens
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primaryAmber = Color(0xFFF59E0B);
  static const Color primaryAmberLight = Color(0xFFFBBF24);
  static const Color primaryAmberDark = Color(0xFFD97706);

  // Background colors
  static const Color background = Color(0xFF0A0A0A); // True black background
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceCard = Color(0xFF1E1E1E);
  static const Color surfaceInteractive = Color(0xFF2A2A2A);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textOnDark = Color(0xFF0A0A0A);

  // Intent colors (semantic)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF141414),
  ];

  // Border colors
  static const Color border = Color(0xFF27272A);
  static const Color borderLight = Color(0xFF3F3F46);

  // Overlay colors
  static const Color overlay = Color(0xFF000000);
  static const Color scrim = Color(0x99000000);

  // Special colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
