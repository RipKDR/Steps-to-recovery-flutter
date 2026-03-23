# Repository Guidelines

## Project Overview

**Steps to Recovery** is a privacy-first recovery companion for 12-step programs (AA, NA, etc.), built with Flutter 3.41.x / Dart 3.11.x. The app is fully functional offline with client-side AES-256 encryption and optional Supabase sync.

**Key Characteristics:**
- **Offline-first**: App works 100% without network connectivity
- **Privacy-first**: Zero analytics on recovery data, PII scrubbing in crash reports
- **Client-side encryption**: All sensitive data encrypted with AES-256 before storage/transmission
- **Crisis-ready**: Emergency features (988, Before You Use, Craving Surf) must never fail

**Project Status**: Phase 5 (UX Polish) in progress. Phases 1-4 complete.

---

## Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.41.x |
| Language | Dart | 3.11.x |
| Navigation | go_router | ^17.1.0 |
| State Management | Singleton Services + ChangeNotifier | Built-in |
| Local Storage | shared_preferences | ^2.5.3 |
| Encryption | encrypt (AES-256) + flutter_secure_storage | ^5.0.3 / ^10.0.0 |
| Remote Sync | supabase_flutter | ^2.8.0 |
| Notifications | flutter_local_notifications | ^21.0.0 |
| Background Tasks | workmanager | ^0.9.0+3 |
| AI | google_generative_ai | ^0.4.6 |
| Crash Reporting | sentry_flutter | ^9.15.0 |

**Intentionally NOT used**: Riverpod, BLoC, GetX, Provider (avoided due to version conflicts and overengineering for app scope)

---

## Build & Development Commands

All commands use `tool/flutterw.ps1`, a PowerShell wrapper that resolves the Flutter SDK from `android/local.properties`, `$FLUTTER_ROOT`, or `PATH`. Do not call `flutter` directly if it's not on PATH.

```powershell
# Install dependencies
.\tool\flutterw.ps1 pub get

# Run on Chrome
.\tool\flutterw.ps1 run -d chrome

# Run on Android
.\tool\flutterw.ps1 run -d android

# Static analysis (must pass clean before committing)
.\tool\flutterw.ps1 analyze

# Run all tests
.\tool\flutterw.ps1 test

# Run single test file
.\tool\flutterw.ps1 test test/database_service_test.dart

# Run tests with coverage
.\tool\flutterw.ps1 test --coverage

# Build commands
.\tool\flutterw.ps1 build apk --debug     # Android debug
.\tool\flutterw.ps1 build apk --release   # Android release
.\tool\flutterw.ps1 build appbundle       # Android App Bundle
.\tool\flutterw.ps1 build web             # Web build
.\tool\flutterw.ps1 build windows         # Windows (requires Visual Studio C++ workload)
.\tool\flutterw.ps1 build ios             # iOS (requires Mac)
.\tool\flutterw.ps1 build macos           # macOS (requires Mac)
```

**Optional remote sync config** (omit `API_BASE_URL` for fully offline mode):

```powershell
.\tool\flutterw.ps1 run `
  --dart-define=API_BASE_URL=https://your-api.example.com `
  --dart-define=API_AUTH_TOKEN=your_token_here `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_key_here `
  --dart-define=SENTRY_DSN=your_sentry_dsn
```

---

## Architecture & Module Organization

### Service-Based Architecture (Singleton Pattern)

We intentionally avoid complex state management libraries. Instead, we use 10 core singleton services:

```
lib/
├── core/
│   ├── constants/     # App-wide constants, recovery prompts, readings
│   │   ├── app_constants.dart
│   │   ├── recovery_content.dart
│   │   └── step_prompts.dart
│   ├── models/        # Data models and enums
│   │   ├── database_models.dart
│   │   └── enums.dart
│   ├── services/      # 10 core singleton services
│   │   ├── preferences_service.dart    # SharedPreferences wrapper
│   │   ├── encryption_service.dart     # AES-256 encryption/decryption
│   │   ├── database_service.dart       # Local persistence (CRUD)
│   │   ├── app_state_service.dart      # App-wide state (auth, onboarding)
│   │   ├── connectivity_service.dart   # Network status monitoring
│   │   ├── notification_service.dart   # Local notifications + scheduling
│   │   ├── sync_service.dart           # Supabase sync with encryption
│   │   ├── ai_service.dart             # Google Generative AI chat
│   │   ├── logger_service.dart         # Structured logging
│   │   └── analytics_service.dart      # Privacy-respecting analytics
│   ├── theme/         # Design system
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   ├── utils/         # Utilities
│   │   ├── achievement_share_utils.dart
│   │   └── app_utils.dart
│   └── core.dart      # Barrel export
├── features/          # Feature modules (19 modules)
│   ├── ai_companion/
│   ├── auth/
│   ├── challenges/
│   ├── craving_surf/
│   ├── crisis/        # Emergency features (988, Before You Use)
│   ├── emergency/     # Danger zone
│   ├── gratitude/
│   ├── home/
│   ├── inventory/     # Step 10 inventory
│   ├── journal/
│   ├── meetings/
│   ├── onboarding/
│   ├── profile/
│   ├── progress/
│   ├── readings/
│   ├── safety_plan/
│   ├── sponsor/
│   └── steps/         # 12-step work
├── navigation/        # GoRouter configuration
│   ├── app_router.dart
│   └── shell_screen.dart
├── widgets/           # Reusable UI components
│   ├── action_card.dart
│   ├── confetti_overlay.dart
│   ├── craving_slider.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   ├── loading_state.dart
│   ├── mood_rating.dart
│   ├── responsive_layout.dart
│   ├── section_header.dart
│   ├── shimmer_loading.dart
│   └── stat_card.dart
└── main.dart
```

### Data Flow

```
UI Screen → Service Call → DatabaseService (SharedPreferences)
                ↓ (if syncing enabled)
           SyncService → EncryptionService (AES-256) → Supabase
```

Services use `ChangeNotifier` for state updates. `AppStateService` is the single source of truth for app-wide state.

### Navigation: GoRouter with Bottom Tabs

- Nested shell navigation (bottom tabs → feature-specific sub-routing)
- Modal routes for crisis screens (instant access from any tab)
- Redirect-based auth flow: onboarding → login → home → authenticated tabs
- No back navigation out of tabs; each tab maintains its own stack

---

## Coding Style & Naming Conventions

Linting is enforced via `flutter_lints` (`package:flutter_lints/flutter.yaml`). Run `flutter analyze` before committing — it must pass clean.

### Dart Naming Conventions

- `lowerCamelCase` for variables, methods, and parameters
- `UpperCamelCase` for types (classes, enums, typedefs)
- `snake_case` for files and directories
- `SCREAMING_SNAKE_CASE` for constants

### Code Patterns

```dart
// Screens are StatelessWidget or StatefulWidget — keep business logic in services
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access app state via AppStateService.instance
    final appState = AppStateService.instance;
    
    // Use ListenableBuilder for reactive UI updates
    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return Scaffold(...);
      },
    );
  }
}

// Do not use print() — use the logger package
import 'core/services/logger_service.dart';

final logger = LoggerService();
logger.info('User signed in');
logger.debug('Debug info');
logger.error('Error occurred', error: e, stackTrace: stackTrace);
```

### Screen Guidelines

- Screens live in `lib/features/<feature>/screens/`
- Keep business logic in services, not widgets
- Use `const` constructors where possible
- Use `Key` for list items that can be reordered
- Use `ListView.builder` for long lists

---

## Testing Guidelines

**Framework**: `flutter_test` (built-in) + `mockito` ^5.4.4
**Location**: `/test/` directory

### Current Test Coverage (~15 tests)

| Test File | Coverage |
|-----------|----------|
| `database_service_test.dart` | Persistence, encryption at rest |
| `encryption_service_test.dart` | AES-256 encrypt/decrypt |
| `connectivity_service_test.dart` | Network state monitoring |
| `ai_service_test.dart` | Chat integration |
| `notification_service_test.dart` | Notification scheduling |
| `preferences_service_test.dart` | Preferences operations |
| `companion_chat_screen_test.dart` | Chat UI |
| `home_milestone_share_test.dart` | Achievement sharing |
| `settings_screen_test.dart` | Settings UI |
| `crisis_screens_test.dart` | Emergency features |
| `app_flow_test.dart` | Full app flow |
| `router_feature_shell_test.dart` | Navigation routing |
| `app_state_notifications_test.dart` | App state + notifications |

### Test Helpers

Use `test/test_helpers.dart` for setup:

```dart
import 'test_helpers.dart';

void main() {
  setUp(() async {
    await prepareTestState();          // Initializes mocked storage
  });
  
  test('test with signed in user', () async {
    await createSignedInUser();        // Seeds authenticated state
    // Your test here
  });
}
```

### Platform-Channel Testing Pattern

For platform-channel dependencies, write a custom `_Fake*` class rather than relying on Mockito mocks:

```dart
// Example from connectivity_service_test.dart
class _FakeConnectivity {
  List<ConnectivityResult> _current = [ConnectivityResult.wifi];
  final StreamController<List<ConnectivityResult>> _controller = 
      StreamController<List<ConnectivityResult>>.broadcast();
  
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;
  
  void emit(List<ConnectivityResult> results) {
    _current = results;
    _controller.add(results);
  }
}
```

### Run Tests

```powershell
.\tool\flutterw.ps1 test                                      # All tests
.\tool\flutterw.ps1 test test/database_service_test.dart      # Single file
.\tool\flutterw.ps1 test --coverage                           # With coverage
```

---

## Security & Privacy Considerations

### Encryption

- All sensitive data (journal, inventory, sponsor info) encrypted with AES-256
- Encryption keys stored in secure storage (`flutter_secure_storage`)
- Server never sees plaintext recovery data

```dart
// Encryption happens transparently inside DatabaseService
await DatabaseService().saveJournalEntry(entry);  // Auto-encrypted

// Manual encryption when needed
final encrypted = EncryptionService().encrypt(plainText);
final decrypted = EncryptionService().decrypt(encrypted);
```

### Privacy Requirements

- **Zero analytics**: Recovery status/progress never tracked
- **Biometric auth ready**: `local_auth` v3 configured (fingerprint/face unlock)
- **Sentry with PII scrubbing**: Crash reports strip all user data
- **No third-party tracking**: No Firebase Analytics, Mixpanel, etc.

### Crisis Features (Zero Compromise)

Crisis features must never crash, hang, or be unreliable:
- `EmergencyScreen` — crisis hotlines (988, SAMHSA)
- `BeforeYouUseScreen` — 5-minute intervention timer
- `CravingSurfScreen` — breathing exercise
- `DangerZoneScreen` — risky contacts management

---

## Environment Configuration

App accepts dart-defines via command line (no `.env` file for secrets):

```powershell
.\tool\flutterw.ps1 run `
  --dart-define=API_BASE_URL=https://... `
  --dart-define=API_AUTH_TOKEN=... `
  --dart-define=GOOGLE_AI_API_KEY=... `
  --dart-define=SUPABASE_URL=... `
  --dart-define=SUPABASE_ANON_KEY=... `
  --dart-define=SENTRY_DSN=...
```

Or see `lib/app_config.dart` for how these are consumed:

```dart
// Access config values
if (AppConfig.hasRemoteSync) { ... }
final apiUrl = AppConfig.apiBaseUrl;
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | Gradle build, AndroidManifest, notifications v21 |
| iOS | ✅ | Xcode project, CocoaPods, notifications v21 |
| Web (Chrome) | ✅ | PWA manifest, responsive, IndexedDB persistence |
| Windows | ✅ | CMake build, requires Visual Studio C++ workload |
| macOS | ✅ | Xcode project, native build |

---

## Commit Guidelines

- **Branch**: `main` (always deployable)
- **Commit style**: Conventional commits (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`)
- **Before pushing**: Run `flutter analyze` + `flutter test`

```
feat: add sponsor contact encryption
fix: harden tab navigation switch flow
test: add connectivity service tests
docs: update setup guide
refactor: simplify achievement calculation
```

---

## Troubleshooting

### Local Notifications Not Firing
- Check `NotificationService.initializeNotifications()` in `main.dart`
- Verify `android/app/src/main/AndroidManifest.xml` has notification permissions
- For iOS, check `ios/Runner/GeneratedPluginRegistrant.swift`
- On Android 12+, requires `SCHEDULE_EXACT_ALARM` permission

### Sync Failing Silently
- Check `SyncService._retry()` exponential backoff logic
- Verify Supabase credentials in dart-defines
- Check `EncryptionService` is initialized before sync attempts
- Look at `logger_service` output (if debug logging enabled)

### Hot Reload Not Working
- Avoid editing `AppStateService` or service initialization logic (requires hot restart)
- Use hot reload for UI-only changes
- Full hot restart: `R` in CLI or `flutter run --hot-restart`

---

## Design System

### Colors (Material 3 Dark Theme)

```dart
// Primary palette
AppColors.primaryAmber        // #F59E0B - Primary accent
AppColors.background          // #0A0A0A - True black background
AppColors.surface             // #141414 - Card/surface backgrounds
AppColors.surfaceVariant      // #1E1E1E - Elevated surfaces

// Semantic colors
AppColors.success             // #10B981 - Success states
AppColors.warning             // #F59E0B - Warning states
AppColors.error               // #EF4444 - Error states
AppColors.info                // #3B82F6 - Info states

// Text colors
AppColors.onBackground        // #F9FAFB - Primary text
AppColors.onSurface           // #F9FAFB - Text on surfaces
AppColors.onSurfaceVariant    // #9CA3AF - Secondary text
```

### Typography

```dart
AppTypography.displayLarge    // Hero text
AppTypography.headlineLarge   // Screen titles
AppTypography.headlineMedium  // Section headers
AppTypography.headlineSmall   // Card titles
AppTypography.bodyLarge       // Primary body text
AppTypography.bodyMedium      // Secondary body text
AppTypography.labelLarge      // Button text
AppTypography.labelMedium     // Caption text
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, service initialization |
| `lib/app_config.dart` | Environment configuration (dart-defines) |
| `lib/navigation/app_router.dart` | GoRouter configuration |
| `lib/core/services/app_state_service.dart` | Global app state, auth |
| `lib/core/services/database_service.dart` | Local persistence |
| `lib/core/services/encryption_service.dart` | AES-256 encryption |
| `lib/core/constants/recovery_content.dart` | Milestones, readings |
| `lib/core/constants/step_prompts.dart` | All 12-step questions |
| `test/test_helpers.dart` | Test setup utilities |
| `tool/flutterw.ps1` | Flutter SDK wrapper |
