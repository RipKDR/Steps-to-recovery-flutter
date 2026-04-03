# Workflow: Steps to Recovery

## Development Philosophy

**Co-founder collaboration, not chatbot.** Claude is a technical co-pilot with opinions. H is product visionary. Short messages carry full intent — infer, don't ask for clarification on obvious things.

**Action over plans.** Do the thing. Don't document doing the thing.

## Git Conventions

**Branch:** `main` (always deployable)
**Commit style:** Conventional commits

```
feat:     New feature
fix:      Bug fix
chore:    Maintenance, dependency updates
docs:     Documentation only
test:     Test additions/changes
refactor: Code change without behavior change
```

**Before pushing:**
1. `flutter analyze` passes (zero warnings)
2. `flutter test` passes (all tests green)

## Code Quality Gates

### Pre-Commit (every commit)
- [ ] `flutter analyze` — zero errors, zero warnings
- [ ] `flutter test` — all tests pass
- [ ] No `print()` statements (use `LoggerService`)
- [ ] Sensitive data encrypted before storage
- [ ] Conventional commit message

### Pre-Merge (feature tracks)
- [ ] New feature has test coverage
- [ ] No broken imports or dead code
- [ ] Crisis features not regressed
- [ ] Privacy compliance verified (no PII logging)

## Testing Standards

**Framework:** `flutter_test` (built-in)
**Location:** `/test/`
**Mocks:** `mockito` v5.4.4 / `mocktail` v1.0.4
**Current:** 250+ tests · **Target:** 300+ by Phase 12

**Test categories:**
- Unit tests: Services, models, utilities
- Widget tests: Screen rendering, user interactions
- Integration tests: Full app flows (auth, check-in, crisis)
- Golden tests: Visual regression (share cards, charts)

**Coverage priorities** (in order):
1. Crisis features — must never regress
2. Encryption pipeline — data integrity is non-negotiable
3. Sync service — retry queue, backoff, encryption before send
4. Navigation — GoRouter shell routing, redirects
5. AI Sponsor — memory store, context assembler, relationship stages

**Run tests:**
```bash
flutter test                               # All tests
flutter test --coverage                    # With coverage
flutter test test/sponsor_service_test.dart  # Single file
```

## Architecture Rules

**10 Singleton Services** — initialized at startup, not lazy-loaded:
- Never instantiate services inside widgets
- Services use `ChangeNotifier` for state
- `AppStateService` is the single source of truth

**Feature modules** in `lib/features/<name>/`:
- `screens/` — UI screens (one screen per file)
- `widgets/` — Feature-specific widgets
- `services/` — Feature-specific services (if needed)

**No Riverpod, BLoC, GetX, or Provider** — ever.

## Privacy Rules (Non-Negotiable)

1. All recovery data encrypted with AES-256 **before** any storage or transmission
2. No PII in logs (Sentry PII scrubbing configured)
3. No analytics on recovery-specific behavior
4. AI calls proxied through Supabase Edge Function (API keys never on device)
5. Crash reports: scrub user data before sending

## Crisis Feature Rules (Non-Negotiable)

Crisis features (988, BeforeYouUse, CravingSurf, DangerZone, EmergencyScreen) must:
- Never crash or hang
- Never require network
- Never show a loading state that blocks action
- Have zero-friction access from any screen
- Be tested in every release

## Environment Variables

Set via `--dart-define` at build time. Never hardcode secrets.

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_AI_API_KEY=... \
  --dart-define=SENTRY_DSN=...
```

Reference: `lib/app_config.dart`

## MCP Tools

Use these **before** writing code or answering questions about libraries:

- **Context7** — Live Flutter/Dart/Supabase docs (never rely on training data for APIs)
- **Dart MCP** — Code analysis, hot reload, run tests, pub.dev search
- **Supabase MCP** — Schema changes, migrations, edge function deployment

## Verify Before Assert (VBR Rule)

Never say "done" without testing. Verify the outcome, not just the output.

- Text change ≠ behavior change: Check the mechanism changed, not just the words
- Use `mcp__dart__run_tests` to verify tests pass, not just that code compiles
- Use `mcp__dart__analyze_files` before calling a feature complete

## Platforms and Build Commands

```bash
flutter build apk --debug    # Android debug
flutter build ios            # iOS (requires Mac)
flutter build web            # Web
flutter build windows        # Windows
flutter build macos          # macOS
```
