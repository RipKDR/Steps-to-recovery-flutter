# HOT Memory — Steps to Recovery

> Keep it ≤100 lines. Most-used patterns live here.

## Preferences

- **Code style:** Follow existing patterns, explicit over implicit
- **Communication:** Direct, no fluff
- **Time zone:** Australia/Sydney (GMT+11)

## Project: Steps to Recovery

### Stack
- Flutter 3.41.x / Dart 3.11.x
- Offline-first: SQLite local, Supabase optional sync
- AES-256 encryption for sensitive data
- Material 3 dark theme (true black #0A0A0A, amber #F59E0B)

### Key Patterns
- Use `flutterw.ps1` wrapper, not direct `flutter` command
- Services own their data domain — don't reach across services
- `DatabaseService` is single source of truth for local persistence
- No business logic in screens — keep in services
- Use `logger` package, never `print()`
- All user-generated sensitive data goes through `DatabaseService` for encryption

### Testing
- `flutter_test` + `mockito`
- Use `test_helpers.dart` for setup
- Custom `_Fake*` classes for platform-channel dependencies

### Big Tech Polish (2026-03-27)
- `StatCard`/`ActionCard`: gray by default, amber only for primary actions (`isPrimary` param)
- Consistent 12dp radius (`AppSpacing.radiusStandard`)
- Subtle borders: `AppColors.borderSubtle` (12% opacity)
- Haptic feedback: `HapticFeedbackService().lightImpact()` (taps), `.selectionClick()` (sliders)
- List animations: `AnimatedListItem` with 50ms stagger, 300ms duration
- Typography: bigger jumps (36/30/26 display, 24/22/20 headline), 1.6 line height for body
- Whitespace: `lg=20dp`, `sectionGap=32dp`, `textGap=24dp`
