# Flutter Project Setup Guide

## Prerequisites

Before running this Flutter project, ensure you have the following installed:

### 1. Flutter SDK

**Windows:**
```powershell
# Download Flutter from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\src\flutter (or your preferred location)
# Add Flutter to PATH
setx PATH "%PATH%;C:\src\flutter\bin"
```

**Verify installation:**
```bash
flutter doctor
```

### 2. Android Studio (for Android development)

1. Download from https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio → Tools → SDK Manager
4. Install:
   - Android SDK Platform (API 33 or higher)
   - Android SDK Build-Tools
   - Android Emulator

4. Accept Android licenses:
```bash
flutter doctor --android-licenses
```

### 3. VS Code (Recommended IDE)

1. Download from https://code.visualstudio.com/
2. Install Flutter extension
3. Install Dart extension

## Project Setup

### 1. Navigate to project directory
```bash
cd C:\Users\H\Steps-to-recovery-flutter
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
# Run on connected device or emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode (for testing production build)
flutter run --release
```

## Building APK

### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs (smaller file size)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Running on Different Platforms

### Android
```bash
flutter run -d android
```

### iOS (requires Mac)
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

## Common Issues & Solutions

### Issue: No devices found
**Solution:** 
- Connect an Android device via USB with USB debugging enabled
- Or start an Android emulator from Android Studio

### Issue: Gradle build failed
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Package conflicts
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: Android licenses not accepted
**Solution:**
```bash
flutter doctor --android-licenses
```

## Development Tips

### Hot Reload
Press `r` in the terminal while the app is running to hot reload changes.

### Hot Restart
Press `R` in the terminal to hot restart the app.

### Debug Console
Press `p` to toggle the debug console overlay.

### Quit
Press `q` to quit the running app.

## Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and step prompts
│   ├── models/             # Data models
│   ├── services/           # Services (DB, encryption, etc.)
│   ├── theme/              # Design system
│   └── utils/              # Utility functions
├── features/                # Feature modules
│   ├── ai_companion/       # AI chat
│   ├── auth/               # Login/signup
│   ├── challenges/         # Recovery challenges
│   ├── craving_surf/       # Craving management
│   ├── crisis/             # Emergency features
│   ├── emergency/          # Danger zone
│   ├── gratitude/          # Gratitude journal
│   ├── home/               # Home dashboard
│   ├── inventory/          # Step 10 inventory
│   ├── journal/            # Journal feature
│   ├── meetings/           # Meeting finder
│   ├── onboarding/         # Onboarding flow
│   ├── profile/            # User profile
│   ├── progress/           # Progress tracking
│   ├── readings/           # Daily readings
│   ├── safety_plan/        # Safety plan
│   ├── sponsor/            # Sponsor management
│   └── steps/              # 12-step work
├── navigation/              # Routing
├── widgets/                 # Reusable widgets
└── main.dart               # App entry point
```

## Testing

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/my_test.dart
```

### Run with coverage
```bash
flutter test --coverage
```

## Code Generation

If using code generation (freezed, json_serializable, etc.):
```bash
flutter pub run build_runner build
flutter pub run build_runner watch
```

## Environment Configuration

Create a `.env` file for API keys (not committed to git):
```
GOOGLE_AI_API_KEY=your_key_here
SUPABASE_URL=your_url_here
SUPABASE_ANON_KEY=your_key_here
```

## Performance Tips

1. Use `const` constructors where possible
2. Use `Key` for list items that can be reordered
3. Avoid rebuilding widgets unnecessarily
4. Use `ListView.builder` for long lists
5. Profile with `flutter run --profile`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Pub.dev](https://pub.dev/) - Flutter packages
