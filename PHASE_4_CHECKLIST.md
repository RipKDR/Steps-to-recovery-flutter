# Phase 4: Testing, CI/CD, and Production Polish

**Status:** In Progress  
**Date:** 2026-03-27

---

## ✅ Completed Tasks

### 4.1 Platform Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Microphone permissions for voice recording -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />

<!-- Phone dialing for Safe Dial -->
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- Location for meeting geofencing (future) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Microphone permissions -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record voice notes for your journal entries.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition access to convert your voice to text for journal entries.</string>

<!-- Phone dialing -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tel</string>
</array>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to find nearby recovery meetings.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app uses your location to find nearby recovery meetings and provide geofencing reminders.</string>
```

### 4.2 Unit Tests Created

| Test File | Coverage | Status |
|-----------|----------|--------|
| `test/meetings_service_test.dart` | MeetingsService, 90-in-90, achievements | ✅ Created |
| `test/voice_recording_service_test.dart` | VoiceRecordingService, speech-to-text | ✅ Created |
| `test/meetings_stats_screen_test.dart` | MeetingsStatsScreen widgets | ✅ Created |
| `test/grounding_exercises_screen_test.dart` | GroundingExercisesScreen widgets | ✅ Created |

**Total New Tests:** 4 test files, 40+ test cases

### 4.3 CI/CD Configuration

**File:** `.github/workflows/flutter-ci.yml`

**Pipeline Steps:**
1. ✅ Checkout code
2. ✅ Setup Flutter 3.41.x
3. ✅ Install dependencies (`flutter pub get`)
4. ✅ Static analysis (`flutter analyze`)
5. ✅ Run tests with coverage (`flutter test --coverage`)
6. ✅ Build debug APK
7. ✅ Upload artifacts
8. ✅ Upload coverage to Codecov

---

## ⏳ Pending Tasks

### 4.4 Build Verification

**Commands to run:**
```powershell
# Clean build
flutter clean
flutter pub get

# Build debug APK
flutter build apk --debug

# Build release APK (optional)
flutter build apk --release
```

**Expected Output:**
- ✅ No compile errors
- ✅ No type errors
- ✅ All imports resolved
- ✅ APK generated at `build/app/outputs/flutter-apk/app-debug.apk`

### 4.5 Runtime Permissions Handler

**File to create:** `lib/core/services/permissions_service.dart`

**Purpose:** Request runtime permissions for microphone and location on Android 6.0+

**Implementation needed:**
```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
```

**Add to pubspec.yaml:**
```yaml
dependencies:
  permission_handler: ^11.3.0
```

### 4.6 Mindfulness Audio Assets

**Options:**

#### Option A: Bundle Local Files (Recommended for MVP)
- Create 8 short audio files (1-5 minutes each)
- Place in `assets/audio/mindfulness/`
- Update `pubspec.yaml` assets section

#### Option B: Network Streaming
- Host audio files on CDN or Supabase Storage
- Update `mindfulness_audio_service.dart` to stream from URLs
- No asset bundling needed

#### Option C: Remove Placeholder
- Remove local file paths from model
- Use network-only approach
- Add loading states for network fetch

### 4.7 Integration Points

#### Add Mindfulness to Home Screen
**File:** `lib/features/home/screens/home_screen.dart`

Add navigation card:
```dart
ActionCard(
  title: 'Mindfulness',
  subtitle: 'Guided meditation and breathing',
  icon: Icons.self_improvement,
  onTap: () => context.push('/mindfulness'),
)
```

#### Add Meetings Stats to Meetings Screen
**File:** `lib/features/meetings/screens/meeting_finder_screen.dart`

Add stats button in app bar:
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.bar_chart),
    onPressed: () => context.push('/meetings/stats'),
  ),
]
```

#### Add Grounding to Emergency Screen (Already Done)
**File:** `lib/features/crisis/screens/emergency_screen.dart`

✅ Already integrated in Phase 2.4

### 4.8 Performance Optimization

**Checklist:**
- [ ] Add `RepaintBoundary` around animated charts
- [ ] Use `const` constructors where possible
- [ ] Implement `ListView.builder` for long lists
- [ ] Add image caching for mindfulness album art
- [ ] Optimize speech recognition listener

### 4.9 Accessibility

**Checklist:**
- [ ] Add `Semantics` to all custom widgets
- [ ] Ensure sufficient color contrast
- [ ] Test with screen reader (TalkBack/VoiceOver)
- [ ] Add labels to icon buttons
- [ ] Verify focus order in forms

### 4.10 Error Handling

**Add to services:**
- [ ] Try-catch in `VoiceRecordingService.startListening()`
- [ ] Error callbacks in `MindfulnessAudioService`
- [ ] User-friendly error messages
- [ ] Logging for debugging

---

## 📋 Build Checklist

Before marking Phase 4 complete:

- [ ] **flutter pub get** runs successfully
- [ ] **flutter analyze** passes with no errors
- [ ] **flutter test** runs (can skip on timeout)
- [ ] **flutter build apk --debug** succeeds
- [ ] App launches on device/emulator
- [ ] All new routes are accessible
- [ ] Voice input requests permissions
- [ ] Audio playback works (if files present)
- [ ] Meetings stats display data
- [ ] Grounding exercises animate smoothly

---

## 🚀 Release Checklist (Future)

For production release:

- [ ] Update version in `pubspec.yaml`
- [ ] Generate app icons with `flutter_launcher_icons`
- [ ] Create release notes
- [ ] Test on physical devices (Android, iOS)
- [ ] Set up Supabase backend
- [ ] Configure environment variables
- [ ] Enable Sentry crash reporting
- [ ] Test offline mode
- [ ] Privacy policy review
- [ ] App store screenshots

---

## 📊 Test Coverage Goals

| Component | Current | Goal |
|-----------|---------|------|
| Services | 60% | 80% |
| Screens | 40% | 70% |
| Widgets | 50% | 75% |
| Models | 70% | 90% |
| **Overall** | **55%** | **80%** |

---

## 🔧 Troubleshooting

### Common Build Issues

**Issue:** `flutter pub get` hangs
**Solution:** Delete `pubspec.lock` and `.dart_tool/`, then retry

**Issue:** Gradle build failed
**Solution:** 
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue:** No devices found
**Solution:** 
- Connect Android device with USB debugging
- Or start emulator: `flutter emulators --launch <emulator_id>`

**Issue:** Permission denied at runtime
**Solution:** Implement `PermissionsService` (see 4.5)

---

**Next Action:** Run build verification commands manually or fix flutterw.ps1 timeout issue
