# Repository Guidelines

## Project Overview

**Steps to Recovery** is a privacy-first recovery companion for 12-step programs (AA, NA, etc.), built with Flutter 3.41.6 / Dart 3.11.4. All sensitive data is encrypted at rest with AES-256. The app is offline-first with optional Supabase sync.

The runnable Flutter project is the **repo root**. The nested `app/` folder is a preserved snapshot — do not edit it.

---

## 🧠 Persistent Memory System

This project uses a **file-based memory system** in `.remember/` that persists across all chat sessions.

### Auto-Load (Every Conversation)

At the start of **every conversation**, the following files are automatically read:

1. `.remember/SOUL.md` — Agent identity and role
2. `.remember/USER.md` — Your preferences and working style
3. `.remember/memory/project-state.md` — Current project state
4. `.remember/memory/YYYY-MM-DD.md` — Recent session notes
5. `.remember/logs/autonomous/memory.md` — HOT memory (always relevant)

### What Gets Remembered

| Type | Stored In | Example |
|------|-----------|---------|
| Corrections | `logs/autonomous/corrections.md` | "Use tabs not spaces" |
| Preferences | `logs/autonomous/memory.md` | "Always run tests before commit" |
| Project-specific | `logs/autonomous/projects/` | "This repo uses flutter_lints" |
| Domain-specific | `logs/autonomous/domains/` | "Flutter: prefer stateless widgets" |
| Reflections | `logs/autonomous/reflections.md` | "Spent 3x on spacing — check visuals first" |

### Manual Commands

```
"Show my patterns"        → List HOT memory
"What have you learned?"  → Show recent corrections
"Memory stats"            → Show counts per tier
"Forget X"                → Remove pattern (confirms first)
```

---

---

## Technology Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.41.6 / Dart 3.11.4 |
| Navigation | `go_router` v17.1.0 |
| Local Storage | `shared_preferences` v2.5.3 |
| Encryption | `encrypt` v5.0.3 (AES-256), `flutter_secure_storage` v10.0.0 |
| Biometric Auth | `local_auth` v3.0.1 |
| Notifications | `flutter_local_notifications` v21.0.0, `workmanager` v0.9.0+3 |
| Network | `http` v1.2.2, `supabase_flutter` v2.8.0 |
| AI/ML | `google_generative_ai` v0.4.6 |
| Monitoring | `sentry_flutter` v9.15.0 |
| UI Components | `flutter_animate`, `fl_chart`, `percent_indicator`, `smooth_page_indicator` |
| Forms | `flutter_form_builder`, `form_builder_validators` |

---

## Build & Development Commands

All commands use `tool/flutterw.ps1`, a PowerShell wrapper that resolves the Flutter SDK from `android/local.properties`, `$FLUTTER_ROOT`, or `PATH`. Do not call `flutter` directly if it's not on PATH.

```powershell
# Install dependencies
.\tool\flutterw.ps1 pub get

# Run the app
.\tool\flutterw.ps1 run -d chrome        # Web (Chrome)
.\tool\flutterw.ps1 run -d android       # Android
.\tool\flutterw.ps1 run -d windows       # Windows desktop

# Static analysis
.\tool\flutterw.ps1 analyze

# Run tests
.\tool\flutterw.ps1 test                 # All tests
.\tool\flutterw.ps1 test test/connectivity_service_test.dart  # Single test file

# Build
.\tool\flutterw.ps1 build apk --debug   # Android debug APK
.\tool\flutterw.ps1 build web           # Web build
.\tool\flutterw.ps1 build windows       # Windows desktop build
```

**Optional remote sync** (omit `API_BASE_URL` for fully offline mode):

```powershell
.\tool\flutterw.ps1 run `
  --dart-define=API_BASE_URL=https://your-api.example.com `
  --dart-define=API_AUTH_TOKEN=your_token_here
```

Available dart-defines:
- `API_BASE_URL` / `API_AUTH_TOKEN` - Custom API backend
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` - Supabase sync
- `GOOGLE_AI_API_KEY` / `GEMINI_API_KEY` - AI companion
- `SENTRY_DSN` - Crash reporting

Windows desktop builds require Visual Studio with "Desktop development with C++" workload.

---

## Architecture & Module Organization

### Directory Structure

```
lib/
├── core/                    # Core functionality (business logic & infrastructure)
│   ├── constants/          # App constants, step prompts, recovery content
│   │   ├── app_constants.dart
│   │   ├── step_prompts.dart
│   │   └── recovery_content.dart
│   ├── models/             # Data models and enums
│   │   ├── database_models.dart
│   │   └── enums.dart
│   ├── services/           # 10 singleton services
│   │   ├── ai_service.dart
│   │   ├── analytics_service.dart
│   │   ├── app_state_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── database_service.dart
│   │   ├── encryption_service.dart
│   │   ├── logger_service.dart
│   │   ├── notification_service.dart
│   │   ├── preferences_service.dart
│   │   └── sync_service.dart
│   ├── theme/              # Design system
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   ├── utils/              # Utility functions
│   │   ├── achievement_share_utils.dart
│   │   └── app_utils.dart
│   └── core.dart           # Barrel export
├── features/               # 19 feature modules
│   ├── ai_companion/
│   ├── auth/
│   ├── challenges/
│   ├── craving_surf/
│   ├── crisis/
│   ├── emergency/
│   ├── gratitude/
│   ├── home/
│   ├── inventory/
│   ├── journal/
│   ├── meetings/
│   ├── onboarding/
│   ├── profile/
│   ├── progress/
│   ├── readings/
│   ├── safety_plan/
│   ├── sponsor/
│   └── steps/
├── navigation/             # GoRouter configuration
│   ├── app_router.dart
│   └── shell_screen.dart
├── widgets/                # Shared reusable widgets
│   ├── action_card.dart
│   ├── craving_slider.dart
│   ├── empty_state.dart
│   ├── error_state.dart
│   ├── loading_state.dart
│   ├── mood_rating.dart
│   ├── section_header.dart
│   ├── stat_card.dart
│   └── widgets.dart
├── app_config.dart         # Environment configuration
├── background_sync.dart    # Background sync worker
└── main.dart               # App entry point
```

### Service Architecture

Services are singletons accessed via the service locator pattern. Each service owns its data domain — do not reach across services.

**Core Services (10 total):**

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `PreferencesService` | SharedPreferences wrapper | `initialize()`, `getString()`, `setString()` |
| `EncryptionService` | AES-256 encryption/decryption | `initialize()`, `encrypt()`, `decrypt()` |
| `DatabaseService` | Local persistence (CRUD) | Extensive CRUD for all entities |
| `AppStateService` | App-wide state (auth, onboarding) | `signIn()`, `signUp()`, `signOut()` |
| `ConnectivityService` | Network status monitoring | `isConnected`, `connectivityStream` |
| `NotificationService` | Local notifications | `initialize()`, `scheduleReminder()` |
| `SyncService` | Supabase sync | `initialize()`, `syncNow()` |
| `AiService` | Google Generative AI chat | `sendMessage()`, `streamMessage()` |
| `LoggerService` | Structured logging | `debug()`, `info()`, `error()` |
| `AnalyticsService` | Privacy-respecting analytics | `logEvent()` |

**Data Flow:**
```
UI Screen → Service Call → DatabaseService (SharedPreferences)
                ↓ (if syncing enabled)
           SyncService → EncryptionService (AES-256) → Supabase
```

### Navigation Structure

Uses `go_router` with nested shell routing:

- **Bootstrap** (`/bootstrap`) → Initial loading screen
- **Auth routes**: `/onboarding`, `/login`, `/signup`
- **Main shell** (4 tabs with bottom navigation):
  - Home (`/home`) → Morning intention, Evening pulse, Emergency, etc.
  - Journal (`/journal`) → Journal list, Editor
  - Steps (`/steps`) → Step overview, Detail, Review
  - Meetings (`/meetings`) → Finder, Detail, Favorites
  - Profile (`/profile`) → Sponsor, Settings, AI settings, Security

---

## Design System

The app uses Material 3 with a custom dark theme:

- **Background**: True black (`#0A0A0A`)
- **Primary Accent**: Amber (`#F59E0B`)
- **Surface**: Card and elevated surface colors defined in `app_colors.dart`
- **Typography**: Inter font family with defined scale
- **Spacing**: 4px grid-based scale (xs=4, sm=8, md=16, lg=24, xl=32)

Key theme files:
- `lib/core/theme/app_colors.dart` - Color tokens
- `lib/core/theme/app_typography.dart` - Text styles
- `lib/core/theme/app_spacing.dart` - Spacing constants
- `lib/core/theme/app_theme.dart` - Complete theme configuration

---

## Coding Style & Naming Conventions

Linting is enforced via `flutter_lints` (`package:flutter_lints/flutter.yaml`). Run `flutter analyze` before committing — it must pass clean.

### Dart Naming Conventions
- `lowerCamelCase` for variables, methods, and parameters
- `UpperCamelCase` for types (classes, enums, typedefs)
- `snake_case` for file names
- `SCREAMING_SNAKE_CASE` for constants

### Code Patterns

**Screens are StatelessWidget or StatefulWidget** — keep business logic in services, not widgets.

```dart
// Good: Screen delegates to service
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AppStateService.instance.currentUser;
    // ...
  }
}
```

**Do not use `print()`** — use the `LoggerService`:

```dart
LoggerService().info('User signed in');
LoggerService().error('Failed to save', error: e, stackTrace: st);
```

**All user-generated sensitive data** (journal, inventory, sponsor info) must go through `DatabaseService` so encryption is applied.

---

## Testing Guidelines

Framework: `flutter_test` + `mockito`. Test files live in `test/`.

### Running Tests

```powershell
.\tool\flutterw.ps1 test                                      # All tests
.\tool\flutterw.ps1 test test/database_service_test.dart      # Single file
.\tool\flutterw.ps1 test --coverage                          # With coverage
```

### Test Setup

Use `test/test_helpers.dart` for setup:

```dart
await prepareTestState();          // Initializes mocked storage
await createSignedInUser();        // Seeds authenticated state
```

### Testing Patterns

For platform-channel dependencies, write a custom `_Fake*` class rather than relying on Mockito mocks of platform code — see `_FakeConnectivity` in `connectivity_service_test.dart` as the pattern to follow.

Services must be injectable (accept a parameter) to enable this pattern:

```dart
// Example pattern for testable services
class _TestableConnectivityService extends ConnectivityService {
  late _FakeConnectivity _fake;
  void injectFake(_FakeConnectivity fake) => _fake = fake;
  // ...
}
```

### Test Files Overview

| Test File | Coverage |
|-----------|----------|
| `connectivity_service_test.dart` | Connectivity monitoring with fake |
| `database_service_test.dart` | CRUD operations, encryption |
| `encryption_service_test.dart` | AES-256 encryption/decryption |
| `notification_service_test.dart` | Local notification scheduling |
| `preferences_service_test.dart` | SharedPreferences wrapper |
| `ai_service_test.dart` | Google AI integration |
| `crisis_screens_test.dart` | Emergency screen widgets |
| `router_feature_shell_test.dart` | Navigation routing |
| `app_flow_test.dart` | End-to-end app flows |

---

## Security Considerations

### Encryption

- **AES-256 encryption** for all sensitive data at rest
- Keys stored in `flutter_secure_storage` (Keychain/Keystore)
- Encryption happens transparently in `DatabaseService`
- Server never sees plaintext recovery data

### Privacy

- **Zero analytics**: Recovery status/progress never tracked
- **Biometric auth ready**: `local_auth` configured
- **Sentry with PII scrubbing**: Crash reports strip all user data
- No third-party tracking libraries

### Data Protection

```dart
// All sensitive data flows through EncryptionService
final encrypted = EncryptionService().encrypt(plainText);
final decrypted = EncryptionService().decrypt(encrypted);
```

---

## Key Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies, Flutter configuration, assets |
| `analysis_options.yaml` | Dart analyzer rules (uses `flutter_lints`) |
| `lib/app_config.dart` | Environment variables (dart-defines) |
| `android/app/build.gradle` | Android build configuration |
| `ios/Runner/Info.plist` | iOS app configuration |
| `tool/flutterw.ps1` | Flutter SDK resolver wrapper |

---

## Git Workflow

### Commit Guidelines

Recent history uses Conventional Commits for meaningful changes:

```
feat: add sponsor contact encryption
fix: harden tab navigation switch flow
docs: update setup guide
refactor: simplify database service initialization
test: add connectivity service tests
```

Use imperative mood and a scope prefix (`feat:`, `fix:`, `test:`, `docs:`, `refactor:`).

### Ignored Files

Key entries in `.gitignore`:
- `/build/` - Flutter build outputs
- `/.dart_tool/` - Dart tooling
- `/app/` - Preserved snapshot (not the runnable app)
- Platform-specific build artifacts

---

## Troubleshooting

### Common Issues

**No devices found:**
- Connect Android device with USB debugging enabled
- Or start Android emulator from Android Studio

**Gradle build failed:**
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Package conflicts:**
```powershell
flutter clean
flutter pub get
```

**Android licenses not accepted:**
```powershell
flutter doctor --android-licenses
```

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
