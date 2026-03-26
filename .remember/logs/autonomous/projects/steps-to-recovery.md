# Steps to Recovery — Project-Specific Patterns

## Project Overview

**Privacy-first 12-step recovery companion** for AA, NA, and other recovery programs.

**Key Constraints:**
- All sensitive data encrypted at rest (AES-256)
- Offline-first with optional Supabase sync
- Material 3 dark theme (true black, amber accent)
- 10 singleton services, no reaching across services

## Overrides (vs Global/Domain Patterns)

### 1. Encryption Required for All Sensitive Data
**Overrides:** Global Dart pattern for plain data storage

```dart
// This project: All user-generated recovery data goes through DatabaseService
// Encryption happens transparently
await databaseService.createJournalEntry(entry); // Encrypted automatically

// NOT: Direct database insertion
await database.insert('journal', data); // WRONG - bypasses encryption
```

### 2. Service Locator Pattern (No Riverpod/BLoC)
**Overrides:** Common Flutter state management patterns

```dart
// This project: Singleton services via .instance
final user = AppStateService.instance.currentUser;
final db = DatabaseService.instance;

// NOT: Provider/Riverpod/BLoC (unless complexity demands it)
```

### 3. Logger Service Over print()
**Overrides:** General Dart debugging patterns

```dart
// This project: Always use LoggerService
LoggerService().info('User signed in');
LoggerService().error('Failed to save', error: e, stackTrace: st);

// NEVER: print()
print('User signed in'); // WRONG
```

### 4. flutterw.ps1 Wrapper for Flutter Commands
**Overrides:** Standard Flutter CLI usage

```powershell
# This project: Always use wrapper
.\tool\flutterw.ps1 pub get
.\tool\flutterw.ps1 run -d chrome

# NOT: Direct flutter command (may not be on PATH)
flutter pub get # May fail if Flutter not on PATH
```

### 5. True Black Dark Theme
**Overrides:** Material 3 default colors

```dart
// This project: Custom dark theme
// Background: #0A0A0A (true black)
// Accent: #F59E0B (amber)
// Surface: AppColors.surface

// NOT: Default Material 3 dark theme
```

## 10 Core Services

| Service | Purpose | Key Methods |
|---------|---------|-------------|
| `PreferencesService` | SharedPreferences wrapper | `initialize()`, `getString()`, `setString()` |
| `EncryptionService` | AES-256 encryption | `initialize()`, `encrypt()`, `decrypt()` |
| `DatabaseService` | Local persistence (CRUD) | All entity CRUD operations |
| `AppStateService` | Auth & onboarding state | `signIn()`, `signUp()`, `signOut()` |
| `ConnectivityService` | Network monitoring | `isConnected`, `connectivityStream` |
| `NotificationService` | Local notifications | `initialize()`, `scheduleReminder()` |
| `SyncService` | Supabase sync | `initialize()`, `syncNow()` |
| `AiService` | Google AI chat | `sendMessage()`, `streamMessage()` |
| `LoggerService` | Structured logging | `debug()`, `info()`, `error()` |
| `AnalyticsService` | Privacy-respecting analytics | `logEvent()` |

## Data Flow

```
UI Screen → Service Call → DatabaseService (encrypted SharedPreferences)
                ↓ (if syncing enabled)
           SyncService → EncryptionService (AES-256) → Supabase
```

## Feature Modules (19 Total)

```
lib/features/
├── ai_companion/      # AI chat for recovery support
├── auth/              # Sign up, login, onboarding
├── challenges/        # Recovery challenges
├── craving_surf/      # Craving surfing exercises
├── crisis/            # Crisis intervention
├── emergency/         # Emergency contacts
├── gratitude/         # Gratitude journal
├── home/              # Dashboard
├── inventory/         # Moral inventory (Step 4/5/10)
├── journal/           # Daily journal
├── meetings/          # Meeting finder & tracker
├── onboarding/        # First-time user flow
├── profile/           # User profile & settings
├── progress/          # Sobriety tracker
├── readings/          # Recovery readings
├── safety_plan/       # Safety planning
├── sponsor/           # Sponsor connection
└── steps/             # 12-step work
```

## Navigation Structure

**GoRouter** with nested shell routing:

- `/bootstrap` → Initial loading
- `/onboarding`, `/login`, `/signup` → Auth routes
- **Main Shell** (4 tabs + profile):
  - `/home` → Dashboard
  - `/journal` → Journal list/editor
  - `/steps` → Step overview/detail
  - `/meetings` → Meeting finder
  - `/profile` → Settings, sponsor, AI config

## Security Requirements

### Encryption
- **AES-256** for all sensitive data at rest
- Keys in `flutter_secure_storage` (Keychain/Keystore)
- Server never sees plaintext recovery data

### Privacy
- **Zero analytics** — Recovery status/progress never tracked
- **Biometric auth ready** — `local_auth` configured
- **Sentry with PII scrubbing** — Crash reports strip all user data
- No third-party tracking libraries

## Build Configuration

### Dart-Defines (Environment Variables)

```powershell
# Optional: Custom API backend
--dart-define=API_BASE_URL=https://your-api.example.com
--dart-define=API_AUTH_TOKEN=your_token_here

# Optional: Supabase sync
--dart-define=SUPABASE_URL=https://xyz.supabase.co
--dart-define=SUPABASE_ANON_KEY=your_key

# Optional: AI companion
--dart-define=GOOGLE_AI_API_KEY=your_key
--dart-define=GEMINI_API_KEY=your_key

# Optional: Crash reporting
--dart-define=SENTRY_DSN=your_dsn
```

**Note:** Omit all defines for fully offline mode.

## Testing Requirements

- **Unit tests** for all services (90%+ coverage)
- **Widget tests** for screens and reusable widgets
- **Integration tests** for critical user flows
- **Golden tests** for key UI components (sparingly)

### Test Setup
```dart
import 'test_helpers.dart';

setUp(() async {
  await prepareTestState();
  await createSignedInUser();
});
```

### Fake Pattern for Platform Services
```dart
// Use custom _Fake* classes for platform-channel dependencies
class _FakeConnectivityService extends ConnectivityService {
  late _FakeConnectivity _fake;
  void injectFake(_FakeConnectivity fake) => _fake = fake;
}
```

## Git Workflow

### Commit Messages (Conventional Commits)
```
feat: add sponsor contact encryption
fix: harden tab navigation switch flow
docs: update setup guide
refactor: simplify database service initialization
test: add connectivity service tests
```

### Pre-Commit Checklist
- [ ] `flutter analyze` passes clean
- [ ] Tests pass (`flutter test`)
- [ ] No `print()` statements
- [ ] Sensitive data encrypted
- [ ] Commit message follows convention

---

**Last Updated:** 2026-03-27  
**Source:** `.remember/logs/autonomous/projects/steps-to-recovery.md`
