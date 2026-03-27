// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

/// Generates PNG app icons for Steps to Recovery app
/// 
/// This script creates PNG files using pure Dart with no external dependencies.
/// Run with: dart run scripts/generate_icons_pure.dart
void main() async {
  print('🎨 Generating Steps to Recovery app icons (Pure Dart)...\n');
  
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

/// PNG encoder using dart:io's zlib
class PngEncoder {
  static Uint8List encode(Uint8List rgba, int width, int height) {
    final result = BytesBuilder(copy: false);
    
    // PNG signature
    result.add(Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]));
    
    // IHDR chunk
    final ihdrData = BytesBuilder(copy: false);
    ihdrData.add(_int32BE(width));
    ihdrData.add(_int32BE(height));
    ihdrData.add(Uint8List.fromList([8, 6, 0, 0, 0])); // 8-bit RGBA
    result.add(_makeChunk('IHDR', ihdrData.toBytes()));
    
    // IDAT chunk (image data)
    // Compress scanlines (each row starts with filter byte 0)
    final uncompressed = BytesBuilder(copy: false);
    for (int y = 0; y < height; y++) {
      uncompressed.addByte(0); // Filter type: None
      for (int x = 0; x < width; x++) {
        final idx = (y * width + x) * 4;
        uncompressed.addByte(rgba[idx]);     // R
        uncompressed.addByte(rgba[idx + 1]); // G
        uncompressed.addByte(rgba[idx + 2]); // B
        uncompressed.addByte(rgba[idx + 3]); // A
      }
    }
    
    final compressed = zlib.encode(uncompressed.toBytes());
    result.add(_makeChunk('IDAT', Uint8List.fromList(compressed)));
    
    // IEND chunk
    result.add(_makeChunk('IEND', Uint8List(0)));
    
    return result.toBytes();
  }
  
  static Uint8List _int32BE(int value) {
    final data = ByteData(4);
    data.setUint32(0, value, Endian.big);
    return data.buffer.asUint8List();
  }
  
  static Uint8List _makeChunk(String type, Uint8List data) {
    final result = BytesBuilder(copy: false);
    result.add(_int32BE(data.length));
    result.add(type.codeUnits);
    result.add(data);
    
    // CRC - calculate over type + data
    final typeAndData = Uint8List(type.length + data.length);
    for (int i = 0; i < type.length; i++) {
      typeAndData[i] = type.codeUnitAt(i);
    }
    typeAndData.setRange(type.length, type.length + data.length, data);
    
    final crc = _crc32(typeAndData);
    result.add(_int32BE(crc));
    
    return result.toBytes();
  }
  
  static int _crc32(Uint8List data) {
    int crc = 0xFFFFFFFF;
    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }
}

/// Generates the main app icon with black background
Future<void> generateMainAppIcon() async {
  const size = 1024;
  final pixels = Uint8List(size * size * 4);
  
  // Fill background with true black (#0A0A0A)
  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = 10;     // R
    pixels[i + 1] = 10; // G
    pixels[i + 2] = 10; // B
    pixels[i + 3] = 255; // A
  }
  
  // Draw recovery stairs
  drawRecoveryStairs(pixels, size, 512.0, 512.0, 409.6);
  
  // Encode and save
  final pngBytes = PngEncoder.encode(pixels, size, size);
  final file = File('assets/icons/app_icon.png');
  await file.writeAsBytes(pngBytes);
}

/// Generates the foreground icon with transparent background
Future<void> generateForegroundIcon() async {
  const size = 1024;
  final pixels = Uint8List(size * size * 4);
  
  // Transparent background (already 0)
  
  // Draw recovery stairs
  drawRecoveryStairs(pixels, size, 512.0, 512.0, 409.6);
  
  // Encode and save
  final pngBytes = PngEncoder.encode(pixels, size, size);
  final file = File('assets/icons/app_icon_foreground.png');
  await file.writeAsBytes(pngBytes);
}

/// Generates the splash screen logo
Future<void> generateSplashLogo() async {
  const size = 512;
  final pixels = Uint8List(size * size * 4);
  
  // Transparent background
  
  // Draw simplified recovery stairs
  drawRecoveryStairs(pixels, size, 256.0, 256.0, 204.8, isSplash: true);
  
  // Encode and save
  final pngBytes = PngEncoder.encode(pixels, size, size);
  final file = File('assets/icons/splash_logo.png');
  await file.writeAsBytes(pngBytes);
}

/// Draws the recovery stairs symbol
void drawRecoveryStairs(Uint8List pixels, int imageSize, double centerX, double centerY, double scale, {bool isSplash = false}) {
  final scaleFactor = isSplash ? 0.5 : 1.0;
  
  // Stair dimensions
  final stairWidth = 120.0 * scaleFactor;
  final stairHeight = 40.0 * scaleFactor;
  final circleRadius = 24.0 * scaleFactor;
  
  // Step 1 (Bottom) - Amber Primary #F59E0B
  drawRoundedRect(
    pixels, imageSize,
    centerX - 180 * scaleFactor,
    centerY + 120 * scaleFactor,
    stairWidth, stairHeight, 8.0 * scaleFactor,
    245, 158, 11, 255,
  );
  
  // Step 2 (Middle) - Amber Light #FBBF24
  drawRoundedRect(
    pixels, imageSize,
    centerX - 60 * scaleFactor,
    centerY + 40 * scaleFactor,
    stairWidth, stairHeight, 8.0 * scaleFactor,
    251, 191, 36, 255,
  );
  
  // Step 3 (Top) - Amber Primary #F59E0B
  drawRoundedRect(
    pixels, imageSize,
    centerX + 60 * scaleFactor,
    centerY - 40 * scaleFactor,
    stairWidth, stairHeight, 8.0 * scaleFactor,
    245, 158, 11, 255,
  );
  
  // Unity circle at top
  drawCircle(
    pixels, imageSize,
    centerX,
    centerY - 160 * scaleFactor,
    circleRadius,
    245, 158, 11, 230,
  );
}

/// Draws a rounded rectangle
void drawRoundedRect(
  Uint8List pixels, int imageSize,
  double x, double y,
  double width, double height, double radius,
  int r, int g, int b, int a,
) {
  final left = (x - width / 2).round();
  final top = (y - height / 2).round();
  final right = (x + width / 2).round();
  final bottom = (y + height / 2).round();
  final rad = radius.round();
  
  for (int py = top; py < bottom; py++) {
    for (int px = left; px < right; px++) {
      if (px < 0 || px >= imageSize || py < 0 || py >= imageSize) continue;
      
      // Check if pixel is inside rounded rect
      double dx = 0, dy = 0;
      
      if (px < left + rad) {
        dx = (px - (left + rad)).toDouble();
      } else if (px > right - rad) {
        dx = (px - (right - rad)).toDouble();
      }
      
      if (py < top + rad) {
        dy = (py - (top + rad)).toDouble();
      } else if (py > bottom - rad) {
        dy = (py - (bottom - rad)).toDouble();
      }
      
      final distSq = dx * dx + dy * dy;
      if (distSq <= rad * rad) {
        final idx = (py * imageSize + px) * 4;
        pixels[idx] = r;
        pixels[idx + 1] = g;
        pixels[idx + 2] = b;
        pixels[idx + 3] = a;
      }
    }
  }
}

/// Draws a filled circle
void drawCircle(
  Uint8List pixels, int imageSize,
  double centerX, double centerY,
  double radius,
  int r, int g, int b, int a,
) {
  final cx = centerX.round();
  final cy = centerY.round();
  final rad = radius.round();
  final radSq = rad * rad;
  
  for (int py = cy - rad; py <= cy + rad; py++) {
    for (int px = cx - rad; px <= cx + rad; px++) {
      if (px < 0 || px >= imageSize || py < 0 || py >= imageSize) continue;
      
      final dx = px - cx;
      final dy = py - cy;
      if (dx * dx + dy * dy <= radSq) {
        final idx = (py * imageSize + px) * 4;
        pixels[idx] = r;
        pixels[idx + 1] = g;
        pixels[idx + 2] = b;
        pixels[idx + 3] = a;
      }
    }
  }
}
