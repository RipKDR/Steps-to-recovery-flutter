# Project State — Steps to Recovery

**Last Updated:** 2026-03-27
**Status:** Beta polish / release hardening

## Current Phase

- **Flutter Version:** 3.41.x / Dart 3.11.x
- **Architecture:** Offline-first with optional Supabase sync
- **Theme:** Material 3 dark theme (true black #0A0A0A, amber #F59E0B)

## Recent Changes (2026-03-27)

### UI Polish
- `StatCard`/`ActionCard`: gray by default, amber only for primary actions (`isPrimary` param)
- Consistent 12dp radius (`AppSpacing.radiusStandard`)
- Subtle borders: `AppColors.borderSubtle` (12% opacity)
- Haptic feedback: `HapticFeedbackService().lightImpact()` (taps), `.selectionClick()` (sliders)
- List animations: `AnimatedListItem` with 50ms stagger, 300ms duration
- Typography: bigger jumps (36/30/26 display, 24/22/20 headline), 1.6 line height for body
- Whitespace: `lg=20dp`, `sectionGap=32dp`, `textGap=24dp`

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/app_config.dart` | Environment configuration |
| `lib/core/` | Core services and utilities |
| `lib/features/` | 19 feature modules |
| `lib/navigation/` | GoRouter configuration |
| `lib/widgets/` | Shared reusable widgets |

## Services (10 Singletons)

1. `PreferencesService` - SharedPreferences wrapper
2. `EncryptionService` - AES-256 encryption/decryption
3. `DatabaseService` - Local persistence (CRUD)
4. `AppStateService` - App-wide state (auth, onboarding)
5. `ConnectivityService` - Network status monitoring
6. `NotificationService` - Local notifications
7. `SyncService` - Supabase sync
8. `AiService` - Google Generative AI chat
9. `LoggerService` - Structured logging
10. `AnalyticsService` - Privacy-respecting analytics

## Build Commands

```powershell
.\tool\flutterw.ps1 pub get           # Install dependencies
.\tool\flutterw.ps1 analyze           # Static analysis
.\tool\flutterw.ps1 test              # All tests
.\tool\flutterw.ps1 run -d chrome     # Run on Chrome
.\tool\flutterw.ps1 build apk --debug # Android debug build
```

## Open Questions / TODO

(None currently tracked)
