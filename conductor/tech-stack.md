# Tech Stack: Steps to Recovery

## Core

| Technology | Version | Purpose |
|---|---|---|
| Flutter | 3.41.5 | Cross-platform UI framework |
| Dart | 3.11.4 | Language (null safety, records, patterns) |

## Navigation

| Package | Version | Purpose |
|---|---|---|
| go_router | ^17.1.0 | Shell routing, tab navigation, deep links |

**Pattern:** GoRouter with nested shell routes (bottom tabs → sub-routing). No back navigation out of tabs. Redirect-based auth flow: onboarding → login → home → authenticated tabs.

## Storage & Persistence

| Package | Version | Purpose |
|---|---|---|
| shared_preferences | ^2.5.3 | Primary local persistence (all app data) |
| path_provider | ^2.1.5 | File system paths (audio, exports) |
| flutter_secure_storage | ^10.0.0 | Secure key storage (encryption keys, tokens) |

**Decision:** SharedPreferences as database — simple, encrypted, fast for this app's data scale. Not suitable for millions of records, but not needed here.

## Security & Encryption

| Package | Version | Purpose |
|---|---|---|
| encrypt | ^5.0.3 | AES-256 encrypt/decrypt |
| crypto | ^3.0.6 | Hashing utilities |
| local_auth | ^3.0.1 | Biometric auth (fingerprint/face) |

**Pattern:** All sensitive data encrypted client-side with AES-256 **before** any transmission. Supabase server never sees plaintext recovery data.

## Backend & Sync

| Package | Version | Purpose |
|---|---|---|
| supabase_flutter | ^2.8.0 | Optional cloud sync + auth |
| http | ^1.2.2 | HTTP client (lightweight calls) |
| dio | ^5.4.0 | HTTP client (interceptors, retry logic) |
| connectivity_plus | ^7.0.0 | Network status monitoring |

**Decision:** Supabase sync is opt-in. App functions 100% offline. Sync uses retry queue with 15-min initial delay + exponential backoff.

## AI

| Package | Version | Purpose |
|---|---|---|
| google_generative_ai | ^0.4.6 | Gemini AI (via Supabase Edge Function proxy) |

**Decision:** Gemini API key never shipped to device. All AI calls go through Supabase Edge Function. This adds latency but eliminates client-side key exposure.

## Notifications & Background

| Package | Version | Purpose |
|---|---|---|
| flutter_local_notifications | ^21.0.0 | Local push notifications |
| workmanager | ^0.9.0+3 | Background tasks (6-hour periodic sync) |
| timezone | ^0.11.0 | Timezone-aware notification scheduling |

## UI & Animation

| Package | Version | Purpose |
|---|---|---|
| flutter_animate | ^4.5.2 | Declarative animations |
| lottie | ^3.1.0 | Lottie JSON animations |
| flutter_staggered_animations | ^1.1.1 | List entry animations |
| shimmer | ^3.0.0 | Loading skeletons |
| fl_chart | ^1.2.0 | Charts (progress dashboard) |
| percent_indicator | ^4.2.4 | Circular/linear progress indicators |
| smooth_page_indicator | ^2.0.1 | Onboarding page dots |
| haptic_feedback | ^0.6.4+3 | Haptic patterns |
| google_fonts | ^8.0.2 | Typography (Inter / system fonts) |
| cupertino_icons | ^1.0.8 | iOS icon set |

## Audio

| Package | Version | Purpose |
|---|---|---|
| just_audio | ^0.10.5 | Audio playback (meditations) |
| audio_session | ^0.2.3 | Audio session management |
| speech_to_text | ^7.0.0 | Voice input for journal |
| record | ^6.2.0 | Audio recording |
| permission_handler | ^12.0.1 | Microphone/notification permissions |

## Forms

| Package | Version | Purpose |
|---|---|---|
| flutter_form_builder | ^10.3.0+2 | Form state management |
| form_builder_validators | ^11.1.0 | Form validation rules |

## Utilities

| Package | Version | Purpose |
|---|---|---|
| intl | ^0.20.2 | Date/number formatting, localization |
| uuid | ^4.5.1 | UUID generation (record IDs) |
| collection | ^1.19.0 | Extended collection utilities |
| equatable | ^2.0.7 | Value equality for models |
| logger | ^2.5.0 | Structured logging |
| url_launcher | ^6.3.1 | External links (crisis hotlines) |
| share_plus | ^12.0.1 | Native share sheet |
| package_info_plus | ^9.0.0 | App version/build info |
| battery_plus | ^7.0.0 | Battery state (UI optimizations) |
| device_info_plus | ^12.3.0 | Device info |

## Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_lints | ^6.0.0 | Flutter lint rules |
| very_good_analysis | ^10.2.0 | Strict analysis options |
| mockito | ^5.4.4 | Mocking for unit tests |
| mocktail | ^1.0.4 | Alternative mock library |
| golden_toolkit | ^0.15.0 | Golden/snapshot tests |
| freezed | ^3.2.5 | Code gen for immutable models |
| json_serializable | ^6.7.1 | JSON serialization code gen |
| build_runner | ^2.4.13 | Code generation runner |
| image | ^4.5.4 | Image manipulation (share cards) |

## Infrastructure

| Service | Purpose | Required? |
|---|---|---|
| Supabase | Auth + cloud sync + Edge Functions (AI proxy) | Optional |
| Firebase Core | Crash reporting plumbing | Configured, not active |
| Sentry | PII-scrubbed crash reporting | Temporarily disabled |

## Design System

- **Primary background:** `#0A0A0A` (true black — OLED battery savings)
- **Accent:** `#F59E0B` (amber — warm, accessible)
- **Design language:** Material 3 dark theme
- **Typography:** System fonts (Inter via Google Fonts)

## Platforms

| Platform | Status |
|---|---|
| Android | ✅ API 21+ |
| iOS | ✅ iOS 14+ |
| Web (Chrome) | ✅ PWA |
| Windows | ✅ CMake |
| macOS | ✅ Native |

## State Management

**No Riverpod, BLoC, GetX, or Provider.** Intentional decision — avoids version conflicts and overengineering for this app's scope.

**Pattern:** 10 singleton services using `ChangeNotifier`. `AppStateService` is the single source of truth for app-wide state. Services initialized at startup in `main.dart`.
