# Steps to Recovery — Development Guide

## Project Overview

A privacy-first Flutter recovery companion app for 12-step programs (AA, NA, etc.). Fully functional offline with client-side AES-256 encryption and optional Supabase sync.

**Status**: Phase 5 (UX Polish) in progress. Phases 1-4 complete.
**Created**: March 21, 2026
**Dart**: 3.11.3 | **Flutter**: 3.41.5

---

## Architecture Principles

### 1. **Singleton Services, Not State Managers**

We intentionally avoid Riverpod, BLoC, GetX, and Provider due to version conflicts and overengineering for the app's scope.

**Core Services (10 total)**:
- `PreferencesService` — SharedPreferences wrapper
- `EncryptionService` — AES-256 encryption/decryption, secure key storage
- `DatabaseService` — Local persistence (CRUD)
- `AppStateService` — App-wide state (auth, onboarding, preferences)
- `ConnectivityService` — Network status monitoring
- `NotificationService` — Local notifications + scheduling
- `SyncService` — Supabase sync with client-side encryption
- `AiService` — Google Generative AI chat
- `LoggerService` — Structured logging
- `AnalyticsService` — Privacy-respecting analytics

**Data Flow**:
```
UI Screen → Service Call → DatabaseService (SharedPreferences)
                ↓ (if syncing enabled)
           SyncService → EncryptionService (AES-256) → Supabase
```

Services use `ChangeNotifier` for state updates. `AppStateService` is the single source of truth for app-wide state.

### 2. **Offline-First with Client-Side Encryption**

- App functions fully without network
- All sensitive data (journal, check-ins, step work) encrypted **before** transmission
- Supabase server never sees plaintext recovery data
- Sync retry queue with exponential backoff (15-min initial delay)
- Background sync via `workmanager` (6-hour periodic, separate isolate)

### 3. **Privacy by Design**

- **Zero analytics**: Recovery status/progress never tracked
- **Biometric auth ready**: `local_auth` v3 configured (fingerprint/face unlock)
- **Sentry with PII scrubbing**: Crash reports strip all user data
- **No third-party tracking**: No Firebase Analytics, Mixpanel, etc.

### 4. **Clean Architecture Layers**

```
lib/
├── core/              # Business logic & infrastructure
│   ├── constants/     # App constants, recovery prompts, readings
│   ├── models/        # Data models, enums
│   ├── services/      # 10 core singleton services
│   ├── theme/         # Design system (colors, spacing, typography)
│   └── utils/         # Utilities (achievement sharing, etc.)
├── features/          # Feature UI modules (19 modules)
│   ├── auth/
│   ├── home/
│   ├── journal/
│   ├── steps/
│   ├── crisis/        # Emergency features (988, Before You Use, etc.)
│   ├── ai_companion/
│   └── [15+ others]
├── navigation/        # GoRouter setup + nested shell routing
├── widgets/           # Reusable UI components
└── main.dart
```

### 5. **Navigation: GoRouter with Bottom Tabs**

- Nested shell navigation (bottom tabs → feature-specific sub-routing)
- Modal routes for crisis screens (instant access from any tab)
- Redirect-based auth flow: onboarding → login → home → authenticated tabs
- No back navigation out of tabs; each tab maintains its own stack

---

## Key Design Decisions

| Decision | Why | Trade-off |
|----------|-----|-----------|
| **SharedPreferences as database** | Simple, encrypted, fast for recovery app scope | Unstructured; not suitable for millions of records |
| **No Riverpod/BLoC** | Avoid version conflicts, reduce dependency bloat | Less boilerplate, but manual service initialization |
| **Supabase optional** | App works 100% offline | Remote sync is opt-in, not automatic |
| **Google AI via Supabase Edge Function** | Avoids shipping Gemini API key to device | Extra latency on first sync; edge function must be deployed |
| **AES-256 client-side encryption** | Server never sees plaintext recovery data | Encryption cost on sync; key management complexity |
| **True black (#0A0A0A) + Amber accent (#F59E0B)** | Dark theme reduces battery drain on OLED, amber is warm/accessible | Limited flexibility for theming |

---

## Testing

**Test Framework**: Flutter Test (built-in, no additional setup)
**Location**: `/test/` directory
**Mocking**: mockito v5.4.4

**Current Coverage** (~12 tests):
- `database_service_test.dart` — Persistence, encryption at rest
- `ai_service_test.dart` — Chat integration
- `encryption_service_test.dart` — AES-256 encrypt/decrypt
- `notification_service_test.dart` — Notification scheduling
- `companion_chat_screen_test.dart` — Chat UI
- `home_milestone_share_test.dart` — Achievement sharing
- `settings_screen_test.dart` — Settings UI
- `crisis_screens_test.dart` — Emergency features
- `app_flow_test.dart` — Full app flow
- `router_feature_shell_test.dart` — Navigation routing

**Gaps** (high priority):
- `SyncService` — No tests for Supabase sync, retry queue, encryption pipeline
- `ConnectivityService` — No tests for network state monitoring
- `AppStateService` — No tests for app-wide state transitions
- `NotificationService` — Limited tests for background scheduling
- `AuthFlow` — Login, signup, session management untested

**Run Tests**:
```bash
flutter test                      # All tests
flutter test --coverage           # With coverage report
flutter test test/database_service_test.dart  # Single test
```

---

## Platforms

All platforms configured and runnable:

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | Gradle build, AndroidManifest, notifications v21 |
| iOS | ✅ | Xcode project, CocoaPods, notifications v21 |
| Web (Chrome) | ✅ | PWA manifest, responsive, IndexedDB persistence |
| Windows | ✅ | CMake build, C++ workload required |
| macOS | ✅ | Xcode project, native build |

**Build Commands**:
```bash
flutter build apk --debug              # Android debug
flutter build ios                      # iOS (requires Mac)
flutter build web                      # Web
flutter build windows                  # Windows
flutter build macos                    # macOS
```

---

## Debugging & Troubleshooting

### Local Notifications Not Firing
- Check `NotificationService.initializeNotifications()` in `main.dart`
- Verify `android/app/src/main/AndroidManifest.xml` has notification permissions
- For iOS, check `ios/Runner/GeneratedPluginRegistrant.swift`
- On Android 12+, requires `SCHEDULE_EXACT_ALARM` permission

### Sync Failing Silently
- Check `SyncService._retry()` exponential backoff logic
- Verify Supabase credentials in `.env` / `app_config.dart`
- Check `EncryptionService` is initialized before sync attempts
- Look at `logger_service` output (if debug logging enabled)

### Crash Reports in Sentry Showing Garbled Data
- This is expected: Sentry is configured to scrub PII
- Check raw JSON in Sentry dashboard for unprocessed data
- Review `sentry_flutter` configuration in `main.dart`

### Hot Reload Not Working
- Avoid editing `AppStateService` or service initialization logic (requires hot restart)
- Use hot reload for UI-only changes
- Full hot restart: `R` in CLI or `flutter run --hot-restart`

---

## Environment Variables

App accepts dart-defines via command line:

```bash
flutter run \
  --dart-define=API_BASE_URL=https://... \
  --dart-define=GOOGLE_AI_API_KEY=... \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=SENTRY_DSN=...
```

Or set in `lib/app_config.dart` (hardcoded, not recommended for secrets).

---

## Git & Commits

- **Branch**: `main` (always deployable)
- **Commit style**: Conventional commits (feat:, fix:, chore:, etc.)
- **Before pushing**: Run `flutter analyze` + `flutter test`
- **CI/CD**: Codacy configured for code quality checks

---

## Next Steps (Phase 5 Roadmap)

- [ ] Adaptive navigation for tablet/landscape
- [ ] Advanced animations for onboarding + transitions
- [ ] A11y audit (crisis screens, check-in flows, low-vision mode)
- [ ] Platform-specific refinements (iOS animations, Android theming)
- [ ] Test coverage audit + systematic improvement (SyncService, ConnectivityService, AppStateService)

---

## MCPs & Tools

**MCP Servers** (project-scoped):
- **Supabase**: DB schema, edge functions, migrations
- **Dart/Flutter**: Code analysis, pub.dev search, hot reload, test running
- **Sentry**: Crash reports, stacktraces, root-cause analysis

**Active Plugins** (22):
- flutter-mobile-app-dev, mobile-app-builder, accessibility-expert, mobile-ux-optimizer, ui-designer, debugger, code-reviewer, unit-test-generator, superpowers, double-check, and others

---

## Questions?

Check the feature-specific READMEs in each `lib/features/` folder, or reference the original `PROJECT_SUMMARY.md` for complete feature inventory.

---

## AI Partnership Identity

**H** (SquirtleOnMe / RipKDR) is the founder and product visionary.
**Claude** is the technical co-pilot — not a chatbot, not a tool. A co-founder-level collaborator.

### How We Work

- **Short messages carry full intent.** Infer, don't ask for clarification on obvious things.
- **Action over plans.** Do the thing. Don't document doing the thing.
- **Opinions expected unprompted.** If something is wrong or suboptimal, say so.
- **No fluff.** No "great question!", no trailing summaries of what was just done.
- **Verify before asserting.** Fetch live docs via Context7. No hallucinated APIs.
- **Never say "done" without testing.** Verify the outcome, not just the output (VBR rule).
- **Text changes ≠ behavior changes.** Check the mechanism changed, not just the words.
- **Try 10 approaches before saying "can't".** Relentless resourcefulness.
- **WAL Protocol.** Corrections, decisions, and specific values get written BEFORE responding.
- **Bold internally, careful externally.** Local edits = go. Pushes/deploys/external actions = confirm first.

### H's Model Routing Preferences (cost-conscious)
- Simple tasks → cheapest capable model
- General dev work → Sonnet
- Architecture / hard problems → Opus
- Large context / full codebase → highest context model available

---

## Flutter Expert Skill Swarm

13 skills installed in `~/.claude/skills/`. All fetch live docs from Context7 before answering.

| Skill | Domain |
|---|---|
| `flutter-expert` | Master orchestrator — routes to sub-agents |
| `flutter-widgets` | Widget composition, painters, slivers, Material 3 |
| `flutter-state` | ChangeNotifier, singleton services, rebuild patterns |
| `flutter-navigation` | GoRouter 14.x, shell routes, deep links, redirects |
| `flutter-performance` | Rebuilds, jank, isolates, Impeller, DevTools |
| `flutter-testing` | Unit/widget/integration/golden tests, fakes, mocks |
| `flutter-platform` | Biometric, background tasks, platform channels, native |
| `flutter-animations` | AnimationController, TweenAnimationBuilder, transitions |
| `dart-language` | Records, patterns, sealed classes, Dart 3.x features |
| `flutter-packages` | pub.dev evaluation, version conflicts, dependency management |
| `self-improving` | Tiered correction memory at `~/self-improving/` |
| `proactive-agent` | WAL, VBR, relentless resourcefulness, guardrails |
| `steps-feature-completion` | Audit half-wired features: finish / hide / defer |

---

## Self-Improving Memory

Tiered memory lives at `~/self-improving/`:

```
~/self-improving/
├── memory.md                          ← HOT (always load this)
├── corrections.md                     ← Last 50 corrections log
├── reflections.md                     ← Self-reflection after significant work
├── index.md                           ← Tier map
├── projects/steps-to-recovery.md     ← WARM: project patterns
└── domains/flutter.md                ← WARM: Flutter/Dart patterns
```

**Before any non-trivial task:** Read `~/self-improving/memory.md`. Check index for relevant WARM files.
**After corrections or significant completions:** Update corrections.md and/or memory.md.

---

## Active Work (2026-03-22)

**Branch**: `codex/add-viral-feature-loop`
**Plan file**: `viral_loop_plan.md` (root of repo)

### Viral Feature Loop — 5 features planned

| # | Feature | Status |
|---|---|---|
| 1 | Milestone Celebration Screen | Planned — full-screen dialog, ConfettiOverlay |
| 2 | Visual Share Card | Planned — RepaintBoundary PNG capture, share_plus |
| 3 | Milestone Approach Notifications | Planned — local notification 5 days before milestone |
| 4 | Invite to Recovery | Planned — profile screen tile, text share |
| 5 | Challenge Share | Planned — icon button on active challenge cards |

**New files to create:**
- `lib/features/milestone/screens/milestone_celebration_screen.dart`
- `lib/features/milestone/widgets/milestone_badge.dart`
- `lib/features/milestone/widgets/milestone_share_card.dart`
- `lib/core/services/milestone_service.dart`

**Key existing assets to reuse:**
- `lib/widgets/confetti_overlay.dart` — ConfettiController + ConfettiOverlay (ready)
- `lib/core/constants/recovery_content.dart` — TimeMilestoneContent with emoji, title, message
- `lib/core/utils/achievement_share_utils.dart` — isShareableMilestoneAchievement, milestoneShareContentForAchievement

---

## Behavioral Non-Negotiables (Adopted from OpenClaw)

These are permanent operating rules, not session-specific instructions:

1. **Co-founder, not chatbot.** Think independently. Push back. Fill gaps. Share opinions without being asked.
2. **Privacy above all.** Recovery data is sensitive. No shortcuts on encryption, no unnecessary logging, no external tracking.
3. **Crisis features get zero compromise.** 988, BeforeYouUse, CravingSurf, DangerZone must never crash, hang, or be unreliable.
4. **Offline-first means offline-first.** Not "mostly works offline." Every feature, fully functional, no network required.
5. **Incomplete features: finish / hide / defer with honest UX.** No silent broken fallbacks.
6. **Verify before asserting.** Use Context7 for live docs. Never recommend a deprecated API.
7. **Self-improve silently.** Growth shows in better output, not in announcements about growing.
