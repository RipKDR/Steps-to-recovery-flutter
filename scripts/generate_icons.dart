import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

/// Generates PNG app icons for Steps to Recovery app
/// 
/// This script creates PNG files programmatically without external dependencies.
/// Run with: dart run scripts/generate_icons.dart
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
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 1024.0;
  
  // Background - True black
  final paint = Paint()..color = const Color(0xFF0A0A0A);
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);
  
  // Draw recovery stairs
  drawRecoveryStairs(canvas, size / 2, size / 2, size * 0.4);
  
  // Convert to PNG
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  // Save to file
  final file = File('assets/icons/app_icon.png');
  await file.writeAsBytes(pngBytes);
}

/// Generates the foreground icon with transparent background
Future<void> generateForegroundIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 1024.0;
  
  // Draw recovery stairs (no background - transparent)
  drawRecoveryStairs(canvas, size / 2, size / 2, size * 0.4);
  
  // Convert to PNG
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  // Save to file
  final file = File('assets/icons/app_icon_foreground.png');
  await file.writeAsBytes(pngBytes);
}

/// Generates the splash screen logo
Future<void> generateSplashLogo() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 512.0;
  
  // Draw simplified recovery stairs
  drawRecoveryStairs(canvas, size / 2, size / 2, size * 0.4, isSplash: true);
  
  // Convert to PNG
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  // Save to file
  final file = File('assets/icons/splash_logo.png');
  await file.writeAsBytes(pngBytes);
}

/// Draws the recovery stairs symbol
void drawRecoveryStairs(Canvas canvas, double centerX, double centerY, double scale, {bool isSplash = false}) {
  final stairWidth = isSplash ? 60.0 : 120.0;
  final stairHeight = isSplash ? 20.0 : 40.0;
  final cornerRadius = isSplash ? 4.0 : 8.0;
  final circleRadius = isSplash ? 12.0 : 24.0;
  
  // Scale factor for splash vs main icon
  final scaleFactor = isSplash ? 0.5 : 1.0;
  
  // Amber color with gradient effect
  final amberPrimary = const Color(0xFFF59E0B);
  final amberLight = const Color(0xFFFBBF24);
  
  // Step 1 (Bottom)
  _drawRoundedRect(
    canvas,
    centerX - 180 * scaleFactor,
    centerY + 120 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberPrimary,
  );
  
  // Step 2 (Middle)
  _drawRoundedRect(
    canvas,
    centerX - 60 * scaleFactor,
    centerY + 40 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberLight,
  );
  
  // Step 3 (Top)
  _drawRoundedRect(
    canvas,
    centerX + 60 * scaleFactor,
    centerY - 40 * scaleFactor,
    stairWidth,
    stairHeight,
    cornerRadius,
    amberPrimary,
  );
  
  // Unity circle at top
  final circlePaint = Paint()..color = amberPrimary.withOpacity(0.9);
  canvas.drawCircle(
    Offset(centerX, centerY - 160 * scaleFactor),
    circleRadius,
    circlePaint,
  );
}

/// Helper to draw rounded rectangle
void _drawRoundedRect(
  Canvas canvas,
  double x,
  double y,
  double width,
  double height,
  double radius,
  Color color,
) {
  final paint = Paint()..color = color;
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(x - width / 2, y - height / 2, width, height),
    Radius.circular(radius),
  );
  canvas.drawRRect(rect, paint);
}
