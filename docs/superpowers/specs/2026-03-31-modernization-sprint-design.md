# Modernization Sprint — Design Spec
*2026-03-31 | v2 — Revised after spec review | Status: Pending Implementation*

---

## Context

Audit of the current Flutter app against 2026 modern standards reveals three concrete gaps:

1. **Mindfulness is silently broken.** No audio asset files exist. Every "play" tap either hangs or throws. Violates non-negotiable #5.

2. **Onboarding is generic and misaligned.** 5 static icon+title+description slides that open with "Your companion for working the 12 steps" — the exact opposite of the decided "Rat Park, not a sobriety tracker" product philosophy. Zero identity capture. Looks like every recovery app from 2018.

3. **Viral loop — verified partially done, verify + close remaining gaps.** The challenge share button and Profile invite tile were already implemented. This sub-project becomes a QA verification + any genuinely missing wiring.

**Explicit scope boundary:** Living AI Sponsor (proactive heartbeat, three-tier memory), Community Platform, Progress Dashboard heatmaps, Security Settings key rotation, and Notification time pickers are independent projects — not started here.

---

## Sub-Project 1: Mindfulness — Guided Visual Sessions

### Root Cause (verified)
`assets/audio/` subdirectories are declared in `pubspec.yaml` but contain zero files. `MindfulnessAudioService.setTrack()` calls `_player.setAsset(localAssetPath)` first — path doesn't resolve. Result: `MindfulnessPlayerState.error` on every tap.

### Decision: Replace with Animated Guided Sessions
Visual/haptic guided sessions that work 100% offline without any audio files. Better product decision than waiting for audio licensing:
- No headphones required
- Zero latency (no file loading)
- Works for deaf/hard-of-hearing users
- Box-breathing animations (Breathwrk, Wim Hof pattern) are proven, effective UX

When real recorded audio is sourced, `MindfulnessAudioService` is ready to receive it — we don't touch or delete the service.

### New Models (`lib/features/mindfulness/models/mindfulness_models.dart`)

**Retire `MindfulnessTrack`** (the audio-URL model). **Keep `MindfulnessCategory` enum** with all 8 values — but map sessions to all of them so no filter chip shows empty. **Keep `MindfulnessPlayerState`** — repurposed for session state. **Keep `MindfulnessProgress`**.

Add `GuidedSession` and `GuidedPhase`:

```dart
/// A session type — determines what GuidedPhase data means
enum GuidedSessionType {
  breathing,    // AnimationController circle expand/contract
  textGuided,   // Text instructions with timer, no animation circle
  progressive,  // Zone-by-zone body highlight (Body Scan)
}

class GuidedSession {
  final String id;
  final String title;
  final String description;
  final MindfulnessCategory mindfulnessCategory;
  final GuidedSessionType sessionType;
  final Duration totalDuration;
  final List<GuidedPhase> phases;  // Loops until totalDuration reached
  final bool isEmergency;          // true = shown first in crisis context
  final bool isPremium;            // always false for now — no content gating

  // Note: isPremium is carried forward on GuidedSession (not removed) to preserve
  // the card UI's PRO badge rendering path. All sessions set isPremium = false.
  // Premium gating is explicitly deferred — see scope boundary above.
}

class GuidedPhase {
  final String label;          // "Inhale", "Hold", "Exhale", "Sense", "Release"
  final Duration duration;
  final double targetScale;    // 0.5–1.0; ignored for textGuided/progressive
  final bool haptic;           // HapticFeedback.lightImpact() on phase start
  final String? instruction;   // For textGuided/progressive: the instruction text
                               // e.g. "Notice 5 things you can see"
                               // null for breathing phases (label is sufficient)
}
```

`GuidedSessionType.textGuided` and `GuidedSessionType.progressive` use `GuidedPhase.instruction` for their UX — no animation circle, just centered instruction text with a countdown. The `GuidedSessionPlayer` widget branch-renders based on `sessionType`.

### Sessions (replacing fake tracks — covers all 8 MindfulnessCategory values)

| Category | Sessions | Type | isEmergency |
|---|---|---|---|
| `breathing` | Box Breathing (4-4-4-4), 4-7-8 Breathing, Deep Breathing, Resonance Breathing | breathing | Box/4-7-8 = true |
| `bodyScan` | Quick Body Scan (5min), Full Body Scan (15min) | progressive | false |
| `grounding` | 5-4-3-2-1 Senses, STOP Technique | textGuided | 5-4-3-2-1 = true |
| `craving` | Urge Surfing, Ride the Wave | textGuided | true |
| `sleep` | 4-7-8 Extended, Progressive Muscle Relaxation | breathing/progressive | false |
| `anxiety` | Physiological Sigh, Coherence Breathing | breathing | true |
| `visualization` | Safe Place (text-guided visualization) | textGuided | false |
| `lovingKindness` | Loving-Kindness Meditation | textGuided | false |

This ensures all 8 enum values have ≥1 session — no filter chip shows an empty state.

### `GuidedSessionPlayer` Widget (`lib/features/mindfulness/widgets/guided_session_player.dart`)

A `StatefulWidget` with `SingleTickerProviderStateMixin`:

- **`breathing` type:** Amber circle, `AnimationController` drives scale via `CurvedAnimation(parent: controller, curve: Curves.easeInOut)`. Phase label centered. Countdown beneath. Loops phases.
- **`textGuided` type:** No circle. `GuidedPhase.instruction` text centered (large, readable). Countdown beneath.
- **`progressive` type:** Body outline SVG with highlighted zone per phase (or simplified text list if SVG adds complexity — implementor calls this).
- All types: play/pause FAB, phase progress ring (`percent_indicator` package, already in pubspec), session complete screen, haptic on phase start.

**Replaces `_MiniPlayer`**: The existing `_MiniPlayer` widget in `MindfulnessLibraryScreen` reads from `MindfulnessAudioService`. In the redesign, `GuidedSessionPlayer` is presented as a `showModalBottomSheet` from the track card — not an always-on mini player. The `_MiniPlayer` widget is removed. There is no in-library persistent playback indicator in v1. A persistent mini-player can be added when real audio is introduced.

### Crisis Context Routing
Sessions with `isEmergency: true` are surfaced first when arriving from crisis screens.

**Mechanism:** Add an optional `bool emergency = false` named parameter to `MindfulnessLibraryScreen`. The router passes `extra: {'emergency': true}` when navigating from `CravingSurfScreen`, `GroundingExercisesScreen`, and `EmergencyScreen`. `MindfulnessLibraryScreen` reads `GoRouterState.extra as Map<String, dynamic>?` and sorts `isEmergency` sessions to the top if `emergency == true`.

Route change needed in `app_router.dart`: `/mindfulness` route adds `extra` forwarding. All existing navigations to `/mindfulness` that don't pass `extra` default to `emergency: false` — no behavior change.

### Data Flow
```
MindfulnessLibraryScreen
  └── List<GuidedSession> (const, defined in screen or a GuidedSessionData class)
        └── onTap → showModalBottomSheet → GuidedSessionPlayer
                         ├── AnimationController (breathing)
                         ├── Timer.periodic (countdown)
                         └── HapticFeedback.lightImpact() (phase transitions)
```

No service calls. No database writes. No new packages. `MindfulnessAudioService` untouched.

---

## Sub-Project 2: Viral Loop — Verification + Gap Close

### What's Already Implemented (verified via code review)
- `ChallengesScreen`: Share `IconButton` exists on active challenge cards, wired to `SharePlus.instance.share(ShareParams(...))` with `AppStoreLinks.shareUrl`
- `ProfileScreen`: "Invite Someone to Recovery" tile exists in Support section, wired to `SharePlus.instance.share(...)`
- `MilestoneCelebrationScreen`, `MilestoneShareCard`, `MilestoneService`: all present and triggered from `HomeScreen`

### This Sub-Project Is a QA Gate, Not a Build Task

Manually verify end-to-end on a device/simulator:

**Verification checklist:**
- [ ] Set sobriety date → check that `MilestoneService.checkAndScheduleApproachNotifications()` fires (verify via notification channel or debug log)
- [ ] Advance to a milestone day (or mock days) → `MilestoneCelebrationScreen` fires post-frame from `HomeScreen` ✓
- [ ] Tap share on celebration screen → off-screen `RepaintBoundary` captures PNG → `SharePlus` share sheet opens with PNG attached
- [ ] Challenges screen: active challenge card has share icon → tap → share sheet opens with formatted text + store link
- [ ] Profile screen: "Invite to Recovery" tile taps → share sheet opens with invite message
- [ ] `AppStoreLinks` constants have placeholder IDs — flag these for when app IDs are assigned (not blocking, just a note)

If any of the above fail: fix the wiring. Document what was broken. No new architecture required.

---

## Sub-Project 3: Onboarding Redesign — Rat Park Flow

### Current Auth Flow (unchanged by this sprint)
`/bootstrap` → `/onboarding` → `/signup` → `/sponsor-intro` → `/home`

The redesign replaces only the content of `/onboarding`. The routing guard, auth flow, and `/sponsor-intro` screen are **not modified**. This is the critical scoping decision that keeps this sub-project deliverable.

### New Models Required Before Implementation

**`RecoveryPath` enum** — new file: `lib/core/models/recovery_path.dart`
```dart
/// The user's self-identified recovery context.
/// Inferred silently from onboarding conversation — never displayed as a label.
enum RecoveryPath {
  twelveStep,           // "stay sober", AA/NA/GA language
  nonTwelveStep,        // SMART, secular, evidence-based
  harmReduction,        // "cut back", "manage better", not abstinence-focused
  behavioralAddiction,  // gambling, screens, food, sex — no substance
  unknown,              // "I don't know", "just struggling" — safe default
}
```

**`AppStateService` additions** — new private fields + public methods:
```dart
// New keys (private)
static const String _keyRecoveryPath = 'recovery_path';
static const String _keyUserName = 'user_name';
static const String _keyFeaturePriority = 'feature_priority';
static const String _keyOnboardingContext = 'onboarding_context';

// New public getters
RecoveryPath get recoveryPath => /* read from _prefs, default RecoveryPath.unknown */
String? get userName => _userName;  // distinct from displayName (email account name)
List<String> get featurePriority => /* read from _prefs, default [] */

// New public setters
Future<void> setRecoveryPath(RecoveryPath path) async { ... notifyListeners(); }
Future<void> setUserName(String? name) async { ... notifyListeners(); }
Future<void> setFeaturePriority(List<String> keys) async { ... notifyListeners(); }
Future<void> setOnboardingContext(String context) async { ... }

// Language lookup — single point for path-adaptive strings
String labelFor(AppLabel label) {
  switch (label) {
    case AppLabel.stepWork:
      return switch(recoveryPath) {
        RecoveryPath.harmReduction => 'Self-Reflection',
        RecoveryPath.behavioralAddiction => 'Personal Work',
        RecoveryPath.nonTwelveStep => 'Reflection Work',
        _ => 'Step Work',
      };
    case AppLabel.cleanTime:
      return switch(recoveryPath) {
        RecoveryPath.harmReduction => 'Days on my plan',
        RecoveryPath.behavioralAddiction => 'Day streak',
        _ => 'Days Clean',
      };
    case AppLabel.cravings:
      return switch(recoveryPath) {
        RecoveryPath.twelveStep => 'Cravings',
        _ => 'Urges',
      };
    case AppLabel.aiCompanion:
      return switch(recoveryPath) {
        RecoveryPath.twelveStep => 'AI Sponsor',
        RecoveryPath.harmReduction => 'AI Support',
        RecoveryPath.behavioralAddiction => 'AI Coach',
        _ => 'AI Companion',
      };
  }
}
```

**`AppLabel` enum** — added alongside `AppStateService` or in `app_constants.dart`:
```dart
enum AppLabel { stepWork, cleanTime, cravings, aiCompanion }
```

### Feature Priority Key Map

Screen 4 chip selections → internal keys → home screen ordering:

| Display Label | Internal Key | Maps to quick action |
|---|---|---|
| Track my days | `track_days` | Sobriety card (already top) |
| Journal and reflection | `journal` | Journal quick action |
| Someone to talk to | `ai_companion` | AI Companion quick action |
| Understanding my patterns | `progress` | Progress quick action |
| Connect with others | `community` | (deferred — no community tab yet, key stored but no UI effect) |
| Something for cravings | `crisis` | Emergency / CravingSurf quick action |

`HomeScreen._QuickActions` reads `AppStateService.instance.featurePriority` and sorts its action list so that matched keys appear first. Default (empty list) = current static order.

### New Onboarding Flow (6 Screens)

The current `OnboardingScreen` `PageView` with generic `_OnboardingPage` data objects is replaced by a `PageView` of 6 dedicated widget classes. Each is distinct enough in interaction that a generic data-driven approach creates more complexity than it saves.

#### Screen 1 — `_WelcomeScreen`
Full-bleed amber gradient (matches `AppColors.primaryGradient`). Centered text:
> *"This is a place to build the life you want to stay in."*

One `ElevatedButton`: "Let's start." No skip. No mention of 12 steps, addiction, or sobriety.

#### Screen 2 — `_MeetScreen` (Conversation Mode)
Chat-bubble UX — NOT the `SponsorChatScreen`. A lightweight tailored UI: amber sponsor bubble on the left, user input on the right.

Conversation:
1. Sponsor: *"Hi. I'm here to support you however I can."* (first bubble, appears with fade-in delay)
2. Sponsor: *"What should I call you?"*
3. User text input field. Placeholder: "Your name or nickname…"
4. **Skip affordance:** A `TextButton("Skip for now")` beneath the input. If tapped: `userName = null`. Defaults to `displayName` from signup (read from `AppStateService.displayName` post-auth). This is the correct fallback — signup happens after onboarding, so `userName` stays null until set here or carried forward as `displayName` post-signup.
5. On submit (non-empty text): stores via `AppStateService.setUserName(text)`.

**Next button** advances page. If `userName` field is empty and Skip was not tapped: advance anyway (same as skip — not blocked).

#### Screen 3 — `_WhyScreen` (Conversation Mode, continued)
Same chat-bubble UI.

Sponsor (using captured name, or "you" if null):
> *"What brought you here today? You can be as specific or as vague as you want."*

Free text input. `TextButton("I'll come back to this")` skips and stores `null`.

On submit (or skip): stores via `AppStateService.setOnboardingContext(text ?? '')`.

**Silent path detection** (run on the stored text, no UI feedback):
```dart
RecoveryPath _inferPath(String text) {
  final lower = text.toLowerCase();
  if (RegExp(r'\b(aa|na|ga|12.step|12 step|sober|sobriety|clean)\b').hasMatch(lower))
    return RecoveryPath.twelveStep;
  if (RegExp(r'\b(cut back|drink less|manage|reduce|harm reduction)\b').hasMatch(lower))
    return RecoveryPath.harmReduction;
  if (RegExp(r'\b(gambl|screen|food|sex|porn|relationship|binge)\b').hasMatch(lower))
    return RecoveryPath.behavioralAddiction;
  if (RegExp(r'\b(smart recovery|secular|evidence.based|no program)\b').hasMatch(lower))
    return RecoveryPath.nonTwelveStep;
  return RecoveryPath.unknown;
}
```
Calls `AppStateService.setRecoveryPath(_inferPath(text))` after storing context.

If skipped: `RecoveryPath.unknown` (default — already set at init).

#### Screen 4 — `_PriorityScreen` (Feature Selection)
Static — no chat bubble. Clean card with:
- Heading: *"What feels most useful right now?"*
- Sub: *"Pick 1 or 2 — you can change this anytime."*
- 6 `FilterChip` widgets in a `Wrap`. Max 2 selectable. `AppFilterChip` (existing reusable widget).
- On "Next": `AppStateService.setFeaturePriority(selectedKeys)`. If nothing selected: stores empty list, no error.

#### Screen 5 — `_PrivacyScreen`
Simple settings. Heading: *"Your data is encrypted on your device."*

Two `SwitchListTile`s:
- **Biometric Lock** — off by default. On toggle-on: calls `BiometricService.isAvailable()` first. If not available (no enrolled biometrics), shows a `SnackBar`: *"No biometrics set up on this device. You can enable this in Settings later."* Leaves the switch off. Does NOT call `setBiometricEnabled(true)` if unavailable.
- **Notifications** — on by default.

One footer line: *"Configure everything else in Settings."*

On "Next": persists both values via `AppStateService.setBiometricEnabled()` and `AppStateService.setNotificationsEnabled()` (already exist).

#### Screen 6 — `_ReadyScreen`
Minimal. Text: *"You're all set."* Optional secondary: *"Your companion is ready whenever you are."*

`ElevatedButton`: "Continue". Calls `_completeOnboarding()` (same as current, same method signature):
```dart
Future<void> _completeOnboarding() async {
  await AppStateService.instance.completeOnboarding();
  if (!mounted) return;
  context.go('/signup');
}
```

Routing continues unchanged: `/signup` → `/sponsor-intro` → `/home`.

### First Sponsor Message (deferred from spec v1)

The "30 seconds after home loads, sponsor sends first in-app message" mechanism was under-specified. **This is deferred to the Living AI Sponsor sprint**, where the full proactive messaging infrastructure will be built. The mechanism requires: `SponsorMemoryStore` with pre-seeded message support, badge count on nav item, and proper first-message gating — all of which belong in that spec.

**In this sprint:** Screen 2 conversation warms the user up. Screen 6 transitions to signup → sponsor-intro, which already exists and captures sponsor identity. The sponsor-intro screen already asks the user "name your AI companion" — this is the warm sponsor intro that happens post-auth. No additional first-message mechanism is needed here.

### Explicit: Auth Route Order

Onboarding completes → `context.go('/signup')`. Signup creates account. Router guard then checks `!sponsor.hasIdentity` → `/sponsor-intro`. Sponsor-intro fires. Only then → `/home`.

`onboardingContext` and `userName` are stored in `AppStateService` before auth. After signup creates the user account and `AppStateService.signIn()` is called, both fields persist in SharedPreferences and are available when the AI sponsor is later initialized in `/sponsor-intro`.

---

## Data Model Summary (all new fields)

| Field | Service | SharedPreferences key | Type | Default |
|---|---|---|---|---|
| `recoveryPath` | `AppStateService` | `recovery_path` | `RecoveryPath` (enum, stored as string) | `RecoveryPath.unknown` |
| `userName` | `AppStateService` | `user_name` | `String?` | `null` |
| `featurePriority` | `AppStateService` | `feature_priority` | `List<String>` (JSON) | `[]` |
| `onboardingContext` | `AppStateService` | `onboarding_context` | `String` | `''` |

All four are loaded in `AppStateService.initialize()` alongside existing fields. Single source of truth is `AppStateService`. `PreferencesService` does not own these fields.

---

## Success Criteria

### Sub-Project 1 (Mindfulness)
- [ ] Tapping any session starts a working animated/guided experience — no error state, no loading spinner that never resolves
- [ ] All 8 `MindfulnessCategory` filter chips return ≥1 session
- [ ] Breathing sessions: amber circle animates through phases, haptic fires on each transition
- [ ] Text-guided sessions: instruction text displays per phase, countdown works
- [ ] Emergency sessions surface first when navigating from `CravingSurfScreen` or `EmergencyScreen` (`?` extra parameter)
- [ ] No `MindfulnessPlayerState.error` reachable in normal usage
- [ ] `MindfulnessAudioService` is unchanged and still compiles

### Sub-Project 2 (Viral Loop QA)
- [ ] Challenge share button taps → share sheet with correct text
- [ ] Profile invite tile taps → share sheet with invite message
- [ ] Milestone: set sobriety date → approach notifications scheduled (verify in debug)
- [ ] Celebration screen fires → share PNG captured → share sheet opens with PNG

### Sub-Project 3 (Onboarding)
- [ ] Screen 1: No mention of 12 steps or addiction
- [ ] Screen 2: Sponsor bubble appears with name prompt; text input works; skip works; `userName` stored correctly
- [ ] Screen 3: Free text stored as `onboardingContext`; `RecoveryPath` inferred and stored
- [ ] Screen 3: Skip stores `RecoveryPath.unknown`
- [ ] Screen 4: Max 2 chips selectable; `featurePriority` stored; empty selection is fine
- [ ] Screen 5: Biometric toggle checks enrollment before enabling; snackbar shown if unavailable
- [ ] Screen 5: Notification toggle persists correctly
- [ ] Screen 6: `completeOnboarding()` fires → routes to `/signup`
- [ ] After full flow: `AppStateService.recoveryPath != null` is the correct inferred value
- [ ] Home screen quick actions reorder when `featurePriority` is non-empty
- [ ] `AppStateService.labelFor(AppLabel.stepWork)` returns `'Self-Reflection'` when path is `harmReduction`
- [ ] `AppStateService.labelFor(AppLabel.cleanTime)` returns `'Days on my plan'` when path is `harmReduction`
- [ ] Step work tab and AI companion label respect `labelFor()` lookups in their widgets

---

## Explicitly Deferred

- First sponsor message on home load (30s mechanism) — Living AI Sponsor sprint
- Living AI Sponsor: proactive behavior, three-tier memory, escalation tree — own spec
- Community Platform — own spec
- Progress Dashboard heatmaps/correlation — own spec
- Security Settings key rotation — own spec
- Notification time pickers / geofencing — own spec
- Home screen contextual/behavioral adaptation — follows onboarding (needs `recoveryPath` data first)
- Real recorded audio for mindfulness — service is ready, assets TBD
- Premium content gating — `isPremium` field carried on `GuidedSession`, all set to `false`
- `community` feature priority key has no home screen effect until community tab exists
- Mentor role, supporting-someone-else path — community sprint
