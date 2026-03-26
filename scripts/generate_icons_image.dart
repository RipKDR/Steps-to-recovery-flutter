import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Generates PNG app icons for Steps to Recovery app
/// 
/// This script creates PNG files using the image package.
/// Run with: dart run scripts/generate_icons_image.dart
void main() async {
  print('🎨 Generating Steps to Recovery app icons...\n');
  
  // Ensure output directory exists
  final outputDir = Directory('assets/icons');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  // Generate main app icon (1024x1024)
  print('✨ Creating main app icon (1024x1024)...');
  await generateMainAppIcon();
  
  // Generate foreground icon for Android adaptive icon (1024x1024)
  print('✨ Creating Android adaptive icon foreground (1024x1024)...');
  await generateForegroundIcon();
  
  // Generate splash logo (512x512)
  print('✨ Creating splash screen logo (512x512)...');
  await generateSplashLogo();
  
  print('\n✅ All icons generated successfully!');
  print('\n📁 Output files:');
  print('   - assets/icons/app_icon.png (1024x1024)');
  print('   - assets/icons/app_icon_foreground.png (1024x1024)');
  print('   - assets/icons/splash_logo.png (512x512)');
  print('\n💡 Next steps:');
  print('   1. Run: flutter pub run flutter_launcher_icons');
  print('   2. Run: flutter pub run flutter_native_splash:create');
}

/// Generates the main app icon with black background
Future<void> generateMainAppIcon() async {
  final image = img.Image(width: 1024, height: 1024);
  
  // Fill background with true black (#0A0A0A)
  img.fill(image, color: img.getColor(10, 10, 10));
  
  // Draw recovery stairs
  drawRecoveryStairs(image, 512.0, 512.0, 409.6);
  
  // Save to file
  final pngBytes = img.encodePng(image);
  final file = File('assets/icons/app_icon.png');
  await file.writeAsBytes(pngBytes!);
}

/// Generates the foreground icon with transparent background
Future<void> generateForegroundIcon() async {
  final image = img.Image(width: 1024, height: 1024);
  
  // Transparent background (already transparent by default)
  
  // Draw recovery stairs
  drawRecoveryStairs(image, 512.0, 512.0, 409.6);
  
  // Save to file
  final pngBytes = img.encodePng(image);
  final file = File('assets/icons/app_icon_foreground.png');
  await file.writeAsBytes(pngBytes!);
}

/// Generates the splash screen logo
Future<void> generateSplashLogo() async {
  final image = img.Image(width: 512, height: 512);
  
  // Transparent background
  
  // Draw simplified recovery stairs
  drawRecoveryStairs(image, 256.0, 256.0, 204.8, isSplash: true);
  
  // Save to file
  final pngBytes = img.encodePng(image);
  final file = File('assets/icons/splash_logo.png');
  await file.writeAsBytes(pngBytes!);
}

/// Draws the recovery stairs symbol
void drawRecoveryStairs(img.Image image, double centerX, double centerY, double scale, {bool isSplash = false}) {
  final scaleFactor = isSplash ? 0.5 : 1.0;
  
  // Stair dimensions
  final stairWidth = 120.0 * scaleFactor;
  final stairHeight = 40.0 * scaleFactor;
  final cornerRadius = 8.0 * scaleFactor;
  final circleRadius = 24.0 * scaleFactor;
  
  // Colors
  final amberPrimary = img.getColor(245, 158, 11);  // #F59E0B
  final amberLight = img.getColor(251, 191, 36);    // #FBBF24
  final amberDimmed = img.getColorRgba(245, 158, 11, 230); // 90% opacity
  
  // Step 1 (Bottom) - Amber Primary
  drawRoundedRect(
    image,
    centerX - 180 * scaleFactor,
    centerY + 120 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberPrimary,
  );
  
  // Step 2 (Middle) - Amber Light
  drawRoundedRect(
    image,
    centerX - 60 * scaleFactor,
    centerY + 40 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberLight,
  );
  
  // Step 3 (Top) - Amber Primary
  drawRoundedRect(
    image,
    centerX + 60 * scaleFactor,
    centerY - 40 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberPrimary,
  );
  
  // Unity circle at top
  drawCircle(
    image,
    centerX,
    centerY - 160 * scaleFactor,
    circleRadius,
    amberDimmed,
  );
}

/// Draws a rounded rectangle
void drawRoundedRect(
  img.Image image,
  double x,
  double y,
  double width,
  double height,
  double radius,
  int color,
) {
  final left = (x - width / 2).round();
  final top = (y - height / 2).round();
  final right = (x + width / 2).round();
  final bottom = (y + height / 2).round();
  final r = radius.round();
  
  // Draw filled rounded rectangle
  final rect = img.Rectangle(left, top, right - left, bottom - top);
  
  // Fill the rectangle first
  img.fillRect(image, rect, color: color);
  
  // Draw corner circles for smooth rounding
  drawCircle(image, left + r, top + r, r, color);
  drawCircle(image, right - r, top + r, r, color);
  drawCircle(image, right - r, bottom - r, r, color);
  drawCircle(image, left + r, bottom - r, r, color);
}

/// Draws a filled circle
void drawCircle(
  img.Image image,
  double centerX,
  double centerY,
  double radius,
  int color,
) {
  final cx = centerX.round();
  final cy = centerY.round();
  final r = radius.round();
  
  // Use the image package's circle drawing
  img.fillCircle(image, cx, cy, r, color: color);
}
