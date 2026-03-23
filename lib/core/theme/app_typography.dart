import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system typography tokens
/// Uses Nunito — warm, rounded, and highly readable for a recovery app.
class AppTypography {
  AppTypography._();

  static String get fontFamily => GoogleFonts.nunito().fontFamily!;

  // Display styles
  static TextStyle get displayLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static TextStyle get displaySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  // Headline styles
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  // Title styles
  static TextStyle get titleLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static TextStyle get titleSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Body styles
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Label styles
  static TextStyle get labelLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );
}
