/// Design system spacing tokens
/// Meta/Google-level whitespace for breathable, premium layouts
class AppSpacing {
  AppSpacing._();

  // Spacing scale (based on 4px grid)
  // Increased minimums for better breathing room
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0; // Standard padding (was 16)
  static const double xl = 28.0; // Section gap minimum (was 24)
  static const double xxl = 36.0; // Major section gap (was 32)
  static const double xxxl = 48.0; // Hero spacing (was 40)
  static const double quad = 64.0;
  static const double quint = 80.0;
  static const double sext = 96.0;

  // Section spacing (gap between major screen sections)
  static const double sectionGap = 32.0; // Increased from 28 for better breathing room
  static const double textGap = 24.0; // Gap between text blocks
  static const double cardPadding = 20.0; // Standard card internal padding
  static const double cardPaddingLg = 24.0;

  // Illustration / hero image sizes
  static const double illustrationSm = 120.0;
  static const double illustrationMd = 160.0;
  static const double illustrationLg = 200.0;

  // Border radius scale — standard 12dp for consistent Meta-like geometry
  static const double radiusNone = 0.0;
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusStandard = 12.0; // Meta/Google standard
  static const double radiusLg = 12.0; // Alias for consistency
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusFull = 9999.0;

  // Touch target minimum
  static const double touchTargetMin = 44.0;
  static const double touchTargetComfortable = 48.0;

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Divider thickness
  static const double dividerThickness = 1.0;
  static const double dividerThick = 2.0;

  // Elevation (shadow heights) — minimal for flat, modern look
  static const double elevationNone = 0.0;
  static const double elevationSm = 1.0; // Reduced from 2
  static const double elevationMd = 2.0; // Reduced from 4
  static const double elevationLg = 4.0; // Reduced from 8
  static const double elevationXl = 8.0; // Reduced from 16
}
