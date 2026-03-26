# Flutter Patterns — Steps to Recovery

## Conventions

### Architecture
- **Offline-first** — All data in local SQLite via `DatabaseService`, Supabase is optional sync
- **Service locator pattern** — 10 singleton services, don't reach across services
- **No business logic in screens** — Keep logic in services, screens are StatelessWidget/StatefulWidget
- **Use `logger` package** — Never `print()`, use `LoggerService().info()`, `.error()`

### UI/UX
- **Material 3 dark theme** — True black background (`#0A0A0A`), amber accent (`#F59E0B`)
- **Card styling** — Gray by default, amber only for primary actions (`isPrimary` param)
- **Consistent radius** — 12dp (`AppSpacing.radiusStandard`)
- **Subtle borders** — `AppColors.borderSubtle` (12% opacity)
- **Haptic feedback** — `HapticFeedbackService().lightImpact()` (taps), `.selectionClick()` (sliders)
- **List animations** — `AnimatedListItem` with 50ms stagger, 300ms duration
- **Typography** — Bigger jumps (36/30/26 display, 24/22/20 headline), 1.6 line height for body
- **Whitespace** — `lg=20dp`, `sectionGap=32dp`, `textGap=24dp`

### State Management
- **Prefer StatelessWidget** — Use `ValueNotifier`, `ChangeNotifier` for state
- **Singleton services** — Access via `ServiceName.instance`
- **Avoid Riverpod/BLoC** — Use simpler patterns unless complexity demands it

### Navigation
- **GoRouter** — Nested shell routing with 4 tabs (Home, Journal, Steps, Meetings, Profile)
- **Route guards** — Check auth state before allowing navigation

## Common Pitfalls

### 1. Reaching Across Services
**Wrong:**
```dart
final prefs = PreferencesService().getString('key'); // Direct access
```

**Right:**
```dart
final value = await _preferencesService.getString('key'); // Injected dependency
```

### 2. Business Logic in Screens
**Wrong:**
```dart
class MyScreen extends StatelessWidget {
  void _saveData() {
    // Complex validation and transformation logic
  }
}
```

**Right:**
```dart
class MyScreen extends StatelessWidget {
  void _saveData() async {
    await MyService.instance.saveData(data); // Delegate to service
  }
}
```

### 3. Using print() for Logging
**Wrong:**
```dart
print('User signed in: $user');
```

**Right:**
```dart
LoggerService().info('User signed in', data: user);
```

### 4. Ignoring Encryption for Sensitive Data
**Wrong:**
```dart
await database.insert('journal', {'content': entry}); // Plain text
```

**Right:**
```dart
// DatabaseService handles encryption automatically for sensitive fields
await databaseService.createJournalEntry(entry);
```

## Build Commands

```powershell
.\tool\flutterw.ps1 pub get           # Install dependencies
.\tool\flutterw.ps1 analyze           # Static analysis
.\tool\flutterw.ps1 test              # All tests
.\tool\flutterw.ps1 run -d chrome     # Run on Chrome (web)
.\tool\flutterw.ps1 run -d android    # Run on Android
.\tool\flutterw.ps1 run -d windows    # Run on Windows desktop
.\tool\flutterw.ps1 build apk --debug # Android debug build
.\tool\flutterw.ps1 build web         # Web build
```

## Dart-Defines (Environment Variables)

```powershell
--dart-define=API_BASE_URL=https://your-api.example.com
--dart-define=API_AUTH_TOKEN=your_token_here
--dart-define=SUPABASE_URL=https://xyz.supabase.co
--dart-define=SUPABASE_ANON_KEY=your_key
--dart-define=GOOGLE_AI_API_KEY=your_key
--dart-define=SENTRY_DSN=your_dsn
```

## Performance Tips

1. **Use `const` constructors** — Always when possible
2. **Avoid `setState` in build** — Use callbacks to services
3. **Lazy load features** — Don't initialize what isn't needed
4. **Cache expensive computations** — Use `lazy` or memoization
5. **Profile with DevTools** — Check for rebuilds, jank, memory leaks

## Testing Patterns

- **Use `test_helpers.dart`** — `await prepareTestState()`, `await createSignedInUser()`
- **Custom `_Fake*` classes** — For platform-channel dependencies (not Mockito mocks)
- **Services must be injectable** — Accept parameters for testability

---

**Last Updated:** 2026-03-27  
**Source:** `.remember/logs/autonomous/domains/flutter.md`
