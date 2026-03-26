# Steps to Recovery - App Icons

This directory contains the app icon assets for the Steps to Recovery Flutter app.

## 📁 Files

### Source Files (SVG)
- `app_icon.svg` - Main app icon design (1024x1024)
- `app_icon_foreground.svg` - Android adaptive icon foreground (transparent background)
- `splash_logo.svg` - Simplified logo for splash screen (512x512)

### Generated Files (PNG)
- `app_icon.png` - Main app icon (1024x1024)
- `app_icon_foreground.png` - Android adaptive icon foreground (1024x1024)
- `splash_logo.png` - Splash screen logo (512x512)

## 🎨 Design

### Symbol
The icon features **three ascending stairs** representing:
- **Step 1**: Acknowledgment
- **Step 2**: Action
- **Step 3**: Achievement

The **unity circle** at the top symbolizes wholeness and recovery completion.

### Colors
- **Primary Amber**: `#F59E0B` - Hope, strength, optimism
- **Light Amber**: `#FBBF24` - Progress, warmth
- **Background Black**: `#0A0A0A` - Depth, sophistication

### Design Principles
- ✅ Simple and recognizable at small sizes (16x16 favicon)
- ✅ Scalable to large sizes (1024x1024 app stores)
- ✅ High contrast for accessibility
- ✅ Material Design compliant
- ✅ Recovery-themed without being cliché

## 🔧 Generating PNG Files

### Option 1: Dart Script (Recommended)

This method uses Flutter's `dart:ui` to render icons programmatically.

```powershell
# Run the Dart icon generator
dart run scripts/generate_icons.dart
```

**Requirements:**
- Flutter SDK installed
- No additional dependencies needed

### Option 2: PowerShell Script with ImageMagick

This method converts SVG files to PNG using ImageMagick.

```powershell
# Run the PowerShell converter
.\scripts\generate_icons.ps1
```

**Requirements:**
- ImageMagick installed

**Install ImageMagick:**
```powershell
# Using Chocolatey
choco install imagemagick -y

# Or download from: https://imagemagick.org/script/download.php
```

### Option 3: Manual Export

If you have a vector graphics editor (Figma, Adobe Illustrator, Inkscape):

1. Open the SVG file
2. Export as PNG at required sizes:
   - 1024x1024 for app_icon.png
   - 1024x1024 for app_icon_foreground.png
   - 512x512 for splash_logo.png
3. Save to `assets/icons/`

## 🚀 Applying Icons to Your App

After generating the PNG files, apply them to your Flutter app:

### 1. App Launcher Icons

```powershell
flutter pub run flutter_launcher_icons
```

This will generate platform-specific icons for:
- ✅ Android (including adaptive icons)
- ✅ iOS
- ✅ Web (favicon)
- ✅ Windows
- ✅ macOS

### 2. Splash Screen

```powershell
flutter pub run flutter_native_splash:create
```

This will configure the native splash screen with:
- Black background (`#0A0A0A`)
- Centered splash logo
- Platform-specific optimizations

### 3. Verify Configuration

Check `pubspec.yaml` for correct icon paths:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#0A0A0A"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"

flutter_native_splash:
  color: "#0A0A0A"
  image: "assets/icons/splash_logo.png"
```

## 📱 Platform-Specific Notes

### Android
- Uses adaptive icon system (Android 8.0+)
- Foreground: `app_icon_foreground.png`
- Background: `#0A0A0A` (configured in pubspec.yaml)
- Legacy icons automatically generated

### iOS
- Icons generated for all required sizes
- Removes alpha channel automatically
- Includes App Store icon (1024x1024)

### Web
- Generates favicon.ico
- Generates PWA icons (192x192, 512x512)
- Updates manifest.json

### Windows
- Generates icon for taskbar and Start menu
- Multiple sizes for different DPI

### macOS
- Generates app icon for Finder and Dock
- Includes Retina variants

## 🎯 Icon Usage Map

| File | Size | Used For |
|------|------|----------|
| `app_icon.png` | 1024x1024 | iOS App Store, Google Play, Web PWA |
| `app_icon_foreground.png` | 1024x1024 | Android adaptive icon layer |
| `splash_logo.png` | 512x512 | Splash screen, loading states |

## 🧪 Testing

After applying icons, verify on each platform:

```powershell
# Run on different platforms
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
flutter run -d windows     # Windows
```

Check:
- ✅ Icon displays correctly on home screen
- ✅ Icon looks good in dark/light mode
- ✅ Splash screen shows centered logo
- ✅ Icon is recognizable at small sizes (notification bar)

## 📝 Modifying the Design

To modify the icon design:

1. **Edit SVG files** in a vector editor (Figma, Illustrator, Inkscape)
2. **Regenerate PNGs** using one of the methods above
3. **Re-run icon generators** (flutter_launcher_icons, flutter_native_splash)
4. **Rebuild app** to see changes

### SVG Design Tips
- Keep it simple - avoid fine details
- Use high contrast colors
- Test at 16x16 size for favicon
- Maintain aspect ratio
- Use rounded corners for modern look

## 🆘 Troubleshooting

### Icons not updating
```powershell
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### Android adaptive icon issues
- Ensure `app_icon_foreground.png` has transparent background
- Check `adaptive_icon_background` color in pubspec.yaml
- Rebuild Android app: `flutter build apk`

### iOS icon not showing
- Delete app from device
- Clean build: `flutter clean && flutter build ios`
- Reinstall app

### Web favicon not updating
- Hard refresh browser: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
- Clear browser cache
- Check `web/manifest.json` and `web/index.html`

## 📚 Resources

- [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)
- [Flutter Native Splash](https://pub.dev/packages/flutter_native_splash)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icons](https://material.io/design/iconography/)

---

**Last Updated:** 2026-03-27  
**Icon Version:** 1.0.0
