# Modernization Sprint — Design Spec
*2026-03-31 | Status: Pending Implementation*

---

## Context

Audit of the current Flutter app against 2026 modern standards reveals three concrete gaps that need to close before any new major feature work begins:

1. **Mindfulness is silently broken.** The screen exists, categories filter, the player renders — but no audio files exist in the project. Every "play" tap fails silently or crashes. Non-negotiable #5 violated.

2. **Onboarding is generic and misaligned.** Current: 5 static icon+title+description slides → signup. Target (already decided in notes): Rat Park framing, identity capture, conversation-mode AI sponsor intro, adaptive paths for 5 user types. The app's stated philosophy and its first impression are completely disconnected.

3. **Viral loop gaps.** The plan was designed and the core milestone/share infrastructure was built, but `ChallengesScreen` share button and Profile "Invite to Recovery" tile are missing. These are the loop-closing touches.

**Scope boundary:** Living AI Sponsor (proactive heartbeat, three-tier memory) and Community Platform are independent projects — too large for this sprint, not started here.

---

## Sub-Project 1: Mindfulness — Guided Visual Sessions

### Problem
`assets/audio/` folders are declared in pubspec.yaml but contain zero files. `MindfulnessAudioService.setTrack()` uses `localAssetPath` first — but the paths don't resolve. Result: loading spinner that never resolves, or a thrown exception.

### Decision
Replace the audio-dependent track model with **animated guided sessions** that work 100% offline without any asset files. This is a better product decision, not just a fix:
- No headphones required
- Zero latency (no file loading)
- More accessible (works without sound)
- Visual breathing guides (Breathwrk, Wim Hof pattern) are proven UX

When real recorded audio is sourced and licensed in the future, the existing `MindfulnessAudioService` is ready to receive them.

### Architecture

**New: `GuidedSession` model** alongside the existing `MindfulnessTrack`:
```dart
class GuidedSession {
  final String id;
  final String title;
  final String description;
  final MindfulnessCategory category;
  final Duration totalDuration;
  final List<GuidedPhase> phases; // e.g. inhale 4s, hold 4s, exhale 4s, hold 4s
}

class GuidedPhase {
  final String label;          // "Inhale", "Hold", "Exhale"
  final Duration duration;
  final double targetScale;    // Animator circle target (0.5–1.0)
  final bool haptic;           // Whether to fire a haptic on phase start
}
```

**New: `GuidedSessionPlayer` widget** — a self-contained animated player:
- Expanding/contracting amber circle with phase label + countdown
- `AnimationController` (vsync) driving scale via `CurvedAnimation`
- Haptic feedback on each phase transition (`HapticFeedback.lightImpact()`)
- Progress ring (the existing `percent_indicator` package)
- Play/pause/restart controls

**Modify: `MindfulnessLibraryScreen`** — replace `MindfulnessTrack` data with `GuidedSession` definitions. Remove fake audio URLs. The screen structure (categories, filter chips, detail card) stays the same.

**Remove: `MindfulnessAudioService` dependency** from the screen (keep the service for future audio use — just don't initialize it in the screen).

### Sessions to implement (replaces current fake tracks)

| Category | Sessions |
|---|---|
| Breathing | Box Breathing (4-4-4-4), 4-7-8 Breathing, Deep Breathing, Resonance Breathing |
| Grounding | 5-4-3-2-1 Senses (text-guided timer), Body Scan (progressive zone highlights) |
| Craving | Urge Surfing (ride-the-wave visualization), STOP technique |
| Sleep | 4-7-8 Extended, Progressive Muscle Relaxation |
| Anxiety | Physiological Sigh (2-in 1-out), Coherence Breathing |

**Emergency filter** — sessions ≤ 3min get an `isEmergency: true` flag, shown first when user arrives from crisis screen.

### Data flow
```
MindfulnessLibraryScreen
  └── List<GuidedSession> (hardcoded, no service needed)
        └── GuidedSessionPlayer (widget, AnimationController, haptics)
```

No service changes. No database changes. Fully offline. No new packages.

---

## Sub-Project 2: Viral Loop — Gap Fill

### What Already Exists (verified in codebase)
- `MilestoneService` — celebration gating + approach notification scheduling
- `MilestoneCelebrationScreen` — full-screen modal, confetti, animated counter
- `MilestoneShareCard` — off-screen capturable PNG card
- `HomeScreen` — triggers celebration post-frame, `_shareMilestone` wired, off-screen card rendering

### What's Missing
**A. ChallengesScreen share button**
- An `IconButton(icon: Icon(Icons.share_outlined))` on active challenge cards
- On tap: `SharePlus.instance.share(ShareParams(text: ...))` with a formatted message
- Example: *"I'm on day 5 of the [Challenge Name] challenge. #StepsToRecovery"*
- No PNG needed — text share is sufficient for challenges

**B. Profile "Invite to Recovery" tile**
- A `ListTile` in `ProfileScreen` (below settings, above sign out)
- Icon: `Icons.person_add_outlined`
- On tap: `SharePlus.instance.share(ShareParams(text: ..., subject: ...))` with App Store / Play Store invite link using `AppStoreLinks` constants
- Text: *"I've been using Steps to Recovery for my journey. It might help you too. [link]"*

### What to verify works end-to-end
- Milestone celebration fires correctly after days-sober changes
- Share PNG captures properly on both iOS and Android
- Approach notifications schedule and cancel correctly

---

## Sub-Project 3: Onboarding Redesign — Rat Park Flow

### Problem
Current onboarding is a generic marketing slide deck. It:
- Opens with "Your companion for working the 12 steps" — immediately excludes 4 of 5 user types
- Collects zero identity data — the app knows nothing about why this person downloaded it
- Routes straight to signup with no sponsor intro, no path selection
- Looks like every other recovery app built in 2018

### Design (from approved notes)

**Core principle:** Lead with the user's experience, not their label. No "sobriety date" required on day one.

### New Onboarding Flow (6 screens)

#### Screen 1 — The Reframe
> *"This is a place to build the life you want to stay in."*

No mention of addiction. No sobriety counter. No program selection. Amber gradient background, large warm type, one CTA button: "Let's start."

Design: full-bleed amber gradient, centered text, single button. No skip button on this screen — it's one tap.

#### Screen 2 — Meet Your Sponsor (Conversation Mode)
Shift to a chat-bubble style UI. The AI sponsor introduces itself:

> *"Hi. I'm here to support you however I can."*
> *"What should I call you?"*

User types their name. Warm, personal, immediate. Then:

> *"And what should I call myself? You can pick a name for me."*

Optional name suggestions in chips below the input (Rex, Sam, Jordan, Alex). If skipped, defaults to "Your Sponsor" — user can rename in settings.

**Data stored:** `sponsorName` (user choice) + `userName` (their name) → `AppStateService` + seed to AI sponsor context.

#### Screen 3 — What Brought You Here (Open, No Judgement)
Still conversation mode. Sponsor asks:

> *"What brought you here today? You can be as specific or as vague as you want."*

Free text input. No required answer. User can type anything or tap "I'll come back to this" to skip.

**What this seeds:** AI sponsor's initial context. Stored as first session message, digested into memory tier 1 when Living AI Sponsor is built.

**Path detection (handled silently, no labels shown to user):**

| User types | App infers |
|---|---|
| "stay sober" / "clean time" / "AA" / "NA" | `path: twelveStep` |
| "cut back" / "drink less" / "manage" | `path: harmReduction` |
| "gamble" / "screens" / "food" / "sex" | `path: behavioralAddiction` |
| "not sure" / "struggling" / "I don't know" | `path: unknown` |
| "SMART" / "not 12-step" / "secular" | `path: nonTwelveStep` |

Path is stored in `AppStateService` as `userPath` enum. All language throughout the app adapts to this path (a single lookup — not a content fork). If path is `unknown`, safe neutral language is used everywhere.

#### Screen 4 — What Would Help Most (Feature Priority)
Light, optional. Single question:

> *"What feels most useful right now? Pick 1-2:"*

Selectable chips (multi-select, 1-2 max):
- Track my days
- Journal and reflection
- Someone to talk to at hard moments
- Understanding my patterns
- Connect with others
- Something to do when cravings hit

**What this does:** Reorders home screen quick actions to put the selected features first. Changes nothing architecturally — just `PreferencesService.setFeaturePriority(List<String>)`. Can be changed anytime in Settings.

#### Screen 5 — Privacy Setup (Minimal)
> *"Your data is encrypted on your device. A few quick settings:"*

Two toggles:
- Biometric lock (off by default, recommended)
- Notifications (on by default)

One line at the bottom: "You can configure everything else in Settings."

No legal walls, no long privacy policy scroll, no cookie banners. Those aren't needed in an offline-first encrypted app and they destroy trust.

#### Screen 6 — Into the App
Transition to home screen.

30 seconds after home loads, sponsor sends first in-app message:

> *"I'm here whenever you need to talk. How are you feeling right now?"*

This is NOT a push notification — it's a local message that appears in the sponsor chat, with a badge on the AI Companion quick action. First thing the user sees when they tap it.

### Language Adaptation (by `userPath`)

| Feature | `twelveStep` | `harmReduction` | `behavioralAddiction` | `unknown` |
|---|---|---|---|---|
| Step work tab | "Step Work" | "Self-Reflection" | "Personal Work" | "Reflection Work" |
| Sobriety counter | "Days Clean" | "Days on my plan" (opt-in) | "Days streak" | "Days" |
| Cravings label | "Cravings" | "Urges" | "Urges" | "Urges" |
| Sponsor intro | "AI Sponsor" | "AI Support" | "AI Coach" | "AI Companion" |

This adaptation is a single `AppStateService.userPath` lookup in each widget — not a content fork, not duplicate screens.

### What does NOT change in onboarding redesign
- Auth flow (signup/login screens) — not touched
- Existing service initialization
- Existing routing logic (onboarding → signup → home)
- No new packages required

### Architecture notes
The `OnboardingScreen` is currently a `PageView` with `_OnboardingPage` data objects. The redesign replaces this with a `PageView` of 6 distinct screen widgets (not generic data objects), since each screen has different interaction patterns (static, chat input, chip selection, toggles).

The conversation mode UI (screens 2-3) uses simple chat bubbles — not the full `SponsorChatScreen` — because it needs to be fast and frictionless. It's a tailored UI for this specific moment.

---

## Success Criteria

### Sub-Project 1 (Mindfulness)
- [ ] Tapping any mindfulness session starts a working animated guided experience
- [ ] All 10+ sessions function without network, without any external files
- [ ] Sessions from crisis context (craving surf, grounding) surface the emergency-flagged sessions first
- [ ] No `MindfulnessPlayerState.error` states reachable in normal usage

### Sub-Project 2 (Viral Loop)
- [ ] Challenge cards show share button, tapping it opens OS share sheet with formatted text
- [ ] Profile screen shows "Invite to Recovery" tile
- [ ] End-to-end: reach a milestone → celebration screen fires → share card captured → share sheet opens
- [ ] Approach notifications schedule when sobriety date is set

### Sub-Project 3 (Onboarding)
- [ ] No slide says "12 steps" on screen 1
- [ ] Sponsor name capture works and persists
- [ ] Free-text "what brought you here" is stored and available to AI sponsor
- [ ] Feature priority selection reorders home screen quick actions
- [ ] `userPath` enum stored in AppStateService, language adaptation active in home + steps + AI companion
- [ ] First sponsor message appears in chat 30s after home load (not a push notification)
- [ ] Biometric toggle works from onboarding

---

## Explicitly Deferred (NOT in this sprint)

- Living AI Sponsor (proactive behavior, three-tier memory, escalation tree) — own spec
- Community Platform — own spec
- Progress Dashboard heatmaps/correlation analysis — own spec
- Security Settings key rotation — own spec
- Notification time pickers / geofencing — own spec
- Home screen contextual/behavioral adaptation — follows onboarding (needs userPath data first)
- Real recorded audio assets for mindfulness — when sourced/licensed, the service is ready

---

## Open Questions Resolved for This Sprint

**Onboarding ask "are you in recovery?" directly?** → No. Path is inferred from what user volunteers. No label is ever applied by the app.

**Does `unknown` path get the sobriety counter?** → Yes, opt-in. Screen doesn't show it by default. User can add it from home screen after onboarding.

**Where is onboarding conversation stored?** → Screen 3 answer stored as `PreferencesService.setOnboardingContext(String)`. When Living AI Sponsor is built, this becomes the first memory digest input.

**Sponsor name skipped?** → Defaults to "Your Sponsor" (stored as `null` in service, resolved at render time). User can rename at any time in AI Settings.
