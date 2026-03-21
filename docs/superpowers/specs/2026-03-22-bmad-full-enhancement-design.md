# Steps to Recovery — Full Enhancement Design (BMAD Method)

**Date:** 2026-03-22
**Method:** BMAD (Business Analyst, Market Analyst, Architect, Developer)
**Scope:** All outstanding features — API migrations, backend, testing, production readiness, UX polish
**Target:** All platforms, no deadline pressure, build it right

---

## Phase 1: Land API Migrations (Developer)

**Scope:** Commit 13 pending files with breaking API changes.

- `flutter_local_notifications` — positional → named parameters for `show()`, `zonedSchedule()`, `cancel()`
- `share_plus` — `Share.share()` → `SharePlus.instance.share(ShareParams(...))`
- `encryption_service.dart` — minor API updates
- `pubspec.yaml` / `pubspec.lock` — dependency bumps
- Platform files — `GeneratedPluginRegistrant.swift`, `generated_plugins.cmake`
- Remove duplicate `lib/notification_service.dart` (legacy of `core/services/notification_service.dart`)

**Exit criteria:** `flutter analyze` clean, existing tests pass, single clean commit.

---

## Phase 2: Supabase Backend (BA → Architect → Developer)

### User Stories
- Sign up/login with email, data tied to account
- Cloud sync — no data loss on device switch
- E2E encryption preserved — server stores ciphertext only
- Offline-first unchanged — sync is additive
- AI via edge functions — no API key on device

### Schema (Postgres + RLS)
| Table | Content | Encrypted |
|-------|---------|-----------|
| `profiles` | user metadata, sobriety date, program | No |
| `check_ins` | morning/evening check-ins | Yes (blob) |
| `journal_entries` | content, mood, craving, tags | Yes |
| `step_work` | step answers, completion | Yes |
| `meetings` | saved meetings + notes | Yes |
| `gratitude_entries` | gratitude entries | Yes |
| `inventory_entries` | Step 10 inventories | Yes |
| `safety_plans` | safety plan data | Yes |
| `sponsor_info` | sponsor details | Yes |
| `emergency_contacts` | contacts list | Yes |
| `challenges` | challenge tracking | No |
| `ai_conversations` | chat history | Yes |

All tables have RLS — users see only their own rows. Each table has `updated_at` + `device_id` for sync.

### Sync Architecture
- Last-write-wins conflict resolution (single-user data)
- `SyncService` wraps Supabase client, extends `DatabaseService` pattern
- Sync triggers: app resume, connectivity change, manual pull-to-refresh
- Offline writes queued locally, flushed on reconnect

### Auth Architecture
- Supabase Auth (email/password)
- Encryption key derived from password (PBKDF2), never sent to server
- Biometric unlock stores derived key in `flutter_secure_storage`
- Auth state in existing `AppStateService`

### AI Edge Function
- Single `chat` Deno edge function
- Accepts conversation history, returns streamed response
- Google AI key as Supabase secret
- `AiService` swaps to edge function URL

### Deliverables
- SQL migrations + RLS policies
- `SyncService` class
- Auth integration in `AppStateService`
- Edge function for AI
- Local → cloud migration on first login
- Dart-defines for Supabase URL/anon key

---

## Phase 3: Testing (BA → Developer)

### Priority (by risk)
1. Encryption/decryption — data access depends on it
2. Sync service — data loss/duplication catastrophic
3. Auth flow — must be bulletproof
4. Notifications — missed reminders hurt engagement
5. Crisis features — must always work
6. AI service — graceful offline degradation
7. Navigation guards — no auth leaks
8. UI screens — all 29 screens

### Test Types
- **Unit tests:** All 8 services (encryption, sync, database, notifications, preferences, app state, AI, connectivity)
- **Widget tests:** All 29 screens, priority on crisis screens
- **Integration tests:** Auth flow, sync flow, check-in flow, crisis flow
- **E2E tests (Patrol):** Happy path install-to-progress, recovery from app kill during sync

### Coverage Target
- Services: 80%+
- Screens: 60%+
- Critical paths: 100%

---

## Phase 4: Production Readiness (BA → Architect → Developer)

### App Icon & Splash
- Adaptive icon (Android), full icon set (iOS), generated from 1024x1024 source
- `flutter_native_splash` — dark background (#0A0A0A) + amber logo
- Recovery-themed, anonymity-respecting (no 12-step specific branding)

### Crash Reporting (Sentry)
- `sentry_flutter` SDK, DSN via dart-define
- Wrap `runApp()` with `SentryFlutter.init()`
- `LoggerService` forwards errors to Sentry
- GoRouter observer for breadcrumbs
- PII scrubbing — no recovery content in reports

### Analytics (Privacy-Respecting)
- Custom events to Supabase Edge Function
- Track only: screen views, feature usage counts, session duration, crash-free rate
- Never track: content, mood, cravings, journal text, step answers
- Opt-out toggle in Settings
- No third-party analytics SDKs

### Signing & Deployment
- Android: keystore, `key.properties`, Gradle signing, ProGuard
- iOS: Xcode config, provisioning, `ExportOptions.plist`
- Secrets via environment variables (CI-ready)

---

## Phase 5: UX Polish (Market Analyst → Architect → Developer)

### Responsive Layouts
- Breakpoints: mobile (<600dp), tablet (600-900dp), desktop (>900dp)
- Home: single column → two-column grid
- Lists: full-width → master-detail split
- Navigation: bottom tabs → rail → sidebar

### Platform Refinements
- Android: predictive back, edge-to-edge
- iOS: swipe-back, safe area, dynamic island
- Web: deep linking, keyboard nav, hover states
- Desktop: window constraints, menu bar, keyboard shortcuts

### Animation Enhancements
- Shared element transitions (step overview → detail)
- Check-in progress animation
- Milestone confetti/particle effects
- Smoother craving surf breathing with haptics
- Shimmer loading everywhere

### Accessibility
- Semantic labels on all interactive elements
- Screen reader testing (TalkBack / VoiceOver)
- 44pt touch target audit
- WCAG AA contrast verification (amber on dark)
- Reduce motion support (`MediaQuery.disableAnimations`)
