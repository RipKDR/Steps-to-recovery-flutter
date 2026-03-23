# Living AI Sponsor — Design Spec
*Date: 2026-03-22 | Status: Approved | Reviewed: v2*

---

## Overview

The AI Sponsor replaces the existing generic AI companion chat with a relationship-based AI that behaves like a long-term friend who has known the user through their entire recovery journey. Not a chatbot with memory bolted on — a relationship with stages, depth, voice, and genuine proactive care.

**This is the feature that makes Steps to Recovery irreplaceable.**

---

## Goals

- Replace the current `AiService`/`CompanionChatScreen` with a sponsor that has identity, memory, and a deepening relationship
- Ship soul and personality first — memory and proactivity layer in over time
- Offline-first: identity, conversation, and memory all function without network
- Privacy: all memory encrypted at rest, user controls and can delete everything
- No new backend infrastructure in MVP — extends existing Supabase edge function

---

## Architecture

```
Flutter App
  └── SponsorService (new singleton, ChangeNotifier)
        ├── SponsorIdentity        — name, vibe, stage metadata
        ├── SponsorMemoryStore     — 3-tier memory (encrypted JSON file in app documents)
        ├── ContextAssembler       — builds system prompt from soul + identity + memory + signals
        └── RecoveryApiClient      — existing edge function, extended for sponsor context

Read-only signal sources (no modification):
  DatabaseService     — check-ins, mood, cravings, journal activity, streaks
  AppStateService     — sobriety date, program type, user ID
  EncryptionService   — all sponsor data encrypted at rest
  ConnectivityService — network state for offline fallback
  NotificationService — proactive nudge hook point (phase 2)
```

`AiService` stays in the codebase — it still handles step work guidance and coping strategies in other features. `CompanionChatScreen` is deleted. `SponsorChatScreen` replaces it in the navigation shell. `SponsorService` implements `CompanionResponder` for testability.

**Fallback when `hasIdentity` is false:** Should not occur post-onboarding (default identity created on skip). If it does, `SponsorService.respond()` uses a generic warm system prompt with no memory context, no name, no stage rules — a safe floor, never an error.

---

## Data Model

### Storage Strategy

- **Identity and stage** → SharedPreferences (small, simple key-value, encrypted)
- **Memory tiers** → Encrypted JSON file: `{app_documents}/sponsor_memory.json` via `EncryptionService`. Not SharedPreferences — avoids write-flush overhead and per-origin size limits on web.

### SharedPreferences Keys

```
sponsor_identity   → JSON: SponsorIdentity
sponsor_stage      → JSON: SponsorStageData
```

### sponsor_memory.json Structure

```json
{
  "session": [ ...SponsorMemory ],
  "digest":  [ ...SponsorMemory ],   // max 20 entries
  "longterm": [ ...SponsorMemory ]   // max 50 entries
}
```

Maximum entry size: 500 characters per `summary`. Full file at capacity: ~36KB — well within any platform limit.

### Dart Types

```dart
enum SponsorVibe { warm, direct, spiritual, toughLove }

enum SponsorStage { new_, building, trusted, close, deep }

enum MemoryCategory {
  lifeContext,       // work, family, living situation
  recoveryPattern,   // triggers, hard times, warning signs
  whatWorks,         // techniques, reframes, things that land
  keyRelationship,   // named people and their significance
  hardMoment,        // crisis points, relapses, low points
}

class SponsorIdentity {
  final String name;
  final SponsorVibe vibe;
  final DateTime createdAt;
}

class SponsorStageData {
  final SponsorStage stage;
  final int engagementScore;
  final DateTime lastInteraction;
}

class SponsorMemory {
  final String id;             // uuid
  final MemoryCategory category;
  final String summary;        // extracted theme, max 500 chars, never raw text
  final DateTime createdAt;
  final DateTime? distilledAt; // set when promoted from digest → longterm
}
```

---

## SponsorService API

```dart
class SponsorService extends ChangeNotifier implements CompanionResponder {
  static final SponsorService instance = SponsorService._internal();

  // Init
  Future<void> initialize();

  // Identity
  SponsorIdentity? get identity;
  bool get hasIdentity;
  Future<void> setupIdentity(String name, SponsorVibe vibe);

  // Memory
  Future<void> addSessionMemory(SponsorMemory memory);
  Future<void> digestSession();           // on session end
  Future<void> distillToLongTerm();       // weekly
  List<SponsorMemory> get longTermMemory;
  List<SponsorMemory> get digestMemory;
  List<SponsorMemory> get sessionMemory;
  Future<void> deleteMemory(String id);   // any tier

  // Relationship
  SponsorStage get stage;
  int get engagementScore;
  Future<void> bumpEngagement({int checkInDays, int chatDays, int journalDays});
  Future<void> recalculateEngagement();   // recompute from DatabaseService history

  // Chat
  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  });

  @override
  bool get isCloudAvailable; // ConnectivityService.isOnline — no separate health check
}
```

---

## Relationship Stage Calculation

Stored as a running total in `SponsorStageData`. Incremented by `bumpEngagement()` called on app launch after detecting new activity in `DatabaseService` (check for new check-ins, journal entries, or chat sessions since `lastInteraction`).

```
engagementScore += 2  per check-in day since lastInteraction
engagementScore += 3  per chat day with sponsor since lastInteraction
engagementScore += 1  per journal day since lastInteraction

Stage thresholds (higher of score-based or days-based wins):
  new_     → score 0–15   OR sobriety days 0–7
  building → score 16–40  OR sobriety days 8–30
  trusted  → score 41–80  OR sobriety days 31–90
  close    → score 81–150 OR sobriety days 91–365
  deep     → score 151+   OR sobriety days 365+
```

Stage never goes backward. `recalculateEngagement()` recomputes from full `DatabaseService` history — callable from settings to repair divergence if source data is deleted.

---

## ContextAssembler

Assembles the system prompt for every `respond()` call. All sections are inline strings; no network calls.

```
[SOUL DOCUMENT]
  Full content of sponsor_soul.dart constant — therapeutic frameworks,
  orientation, hard stops, soft guardrails. The character, not a ruleset.

[IDENTITY]
  "Your name is {name}."
  Vibe tone guidance:
    warm       → nurturing, patient, draws out rather than directs
    direct     → honest, efficient, no-nonsense, still caring
    spiritual  → meaning-oriented, values-based, comfortable with mystery
    toughLove  → high-expectation, honest, will name avoidance directly

[RELATIONSHIP STAGE]
  "This is day {N} of the user's journey. Stage: {stage}."
  Stage behavior rules:
    new_     → professional warmth, max 1 nudge reference/session, 3 onboarding questions
    building → references past conversations, recognises patterns, more direct
    trusted  → calls out avoidance, initiates on drift, less formal
    close    → deep references, weekly digest context, pushes on growth
    deep     → full journey awareness, growth-oriented challenges

[MEMORY SUMMARY]
  Last 5 long-term memories + last 3 digest entries as bullet points.
  Format: "- {category}: {summary}"
  Never includes raw journal or step-work text.

[SIGNALS]
  - Sobriety days: {N}
  - Mood trend (last 7 days): {improving | stable | declining | no data}
  - Craving level vs personal baseline: {above | at | below | no data}
  - Check-in streak: {N} days
  - Days since last journal entry: {N}
  - Days since last human contact recorded: {N}
  - Engagement score: {N}

[RESPONSE CONTRACT]
  - Respond as {name}, first person, never break character
  - Match the {vibe} tone
  - Do not diagnose, prescribe, or claim clinical authority
  - If crisis mode active: shift to direct, grounded, immediate — suggest 988
  - Max 200 words unless user is in clear distress
  - End with a question or opening, not a closing statement
  - Never use "As an AI" or break the sponsor persona
```

---

## Session Lifecycle

A **session** starts when `SponsorChatScreen` mounts (`initState`). It ends when:
- The screen is disposed (user navigates away), OR
- The app goes to background (`AppLifecycleState.paused`)

`SponsorChatScreen` listens to `AppLifecycleState` via `WidgetsBindingObserver`.

**Session memory persistence**: session memory is written to `sponsor_memory.json` on every `addSessionMemory()` call — not held in memory only. This means it survives app crashes. It is cleared only after `digestSession()` completes successfully.

`digestSession()` flow:
1. Read session memory from file
2. Run heuristic extraction (see below)
3. Append up to 3 new digest entries
4. Clear session tier
5. Write file

---

## Memory Extraction Heuristics (MVP — Client-Side)

No NLP. Extraction scans the conversation turn for extractable signals using rule-based matching.

**What triggers extraction** (evaluated on each user message before adding session memory):

| Signal | Extraction Rule | Category |
|---|---|---|
| Named person mentioned | Regex `\b[A-Z][a-z]+\b` near relationship word (mum, dad, brother, partner, friend, sponsor) | keyRelationship |
| Time pattern | "always", "every Sunday", "whenever I", "after work" | recoveryPattern |
| Emotional peak | Exclamation, "finally", "I can't", "this is the first time" | hardMoment or whatWorks |
| Reframe landed | Sponsor said "write that down" OR user said "that's exactly it" / "I never thought" | whatWorks |
| Trigger named | "makes me want to", "when I'm around", "craving spike" | recoveryPattern |
| Life context | Work, housing, money, health mentioned casually | lifeContext |

**Summary format**: The matched sentence or clause, trimmed to 200 chars, prefixed with context: `"Sunday evenings are often hard — isolation and anticipatory anxiety about the week ahead."`

**Max 3 extractions per session** — avoid flooding digest with noise.

---

## Offline Conversation Fallback

When `ConnectivityService.isConnected` is false, `respond()` does not call the edge function. Instead:

1. **Read memory** — pull last 3 long-term memories relevant to time of day (if evening: recoveryPattern category; otherwise: whatWorks)
2. **Select empathetic opener** — random pick from a curated static list (20 entries) in `sponsor_soul.dart`, e.g.:
   - "I can't connect right now, but I'm still here. You don't need me to tell you what you already know."
   - "No signal, but that doesn't change anything between us. What's going on?"
3. **Append memory echo** — if any relevant memories exist: "Last time we talked about this, you mentioned: '{summary}'. Still true?"
4. **Append coping resource** — one item from existing `RecoveryContent.copingStrategies`

The offline response is clearly not an AI response — it reads as a cached message from the sponsor. It is warm, useful, and does not pretend to be live.

---

## Crisis Safety

`detectCrisis()` runs on every user message **before** it is sent to the edge function. The keyword list currently lives inside `AiService.detectCrisis()` as a local variable — implementation must extract it to a top-level constant (e.g., `crisis_constants.dart`) so both `AiService` and `SponsorService` can share it.

On detection:
1. `ContextAssembler` appends a crisis system prompt addendum:
   ```
   CRISIS MODE ACTIVE. Shift immediately. Be direct, grounded, present.
   Acknowledge the pain first. Then: one concrete next step.
   Always include: "988 is there right now if you need it."
   Do not give lists. Do not minimise. Stay with them.
   ```
2. Sponsor response is rendered with a red ambient border in the UI
3. A 988 deeplink chip appears below the sponsor bubble (existing `CrisisScreen` infrastructure)

Full 5-level escalation (persistence, human bridge, auto-draft, hard escalation) deferred to Phase 2. This is documented and intentional — not silent.

---

## UI Components

### SponsorChatScreen
Replaces `CompanionChatScreen` in the navigation shell (screen deleted).

Additions over old chat:
- Top bar: amber circle avatar (sponsor initial), name, stage badge (e.g. "Building")
- Info icon in top bar → navigates to `MemoryTransparencyScreen`
- "Share my week" chip → appends aggregated signal summary to the user's next message
- Quick reply chips (contextual, max 3, generated from last sponsor response keywords)
- Crisis: red ambient border + 988 chip when `detectCrisis()` triggers
- On `dispose` and on `paused`: calls `SponsorService.digestSession()`
- On mount: calls `SponsorService.bumpEngagement()` to update score

### SponsorIntroScreen
Final step of existing onboarding flow.

- Amber radial glow at top center
- Headline: `"One more thing."` — Subtext: `"You have a sponsor waiting."`
- `TextFormField`: "What do you want to call them?" (placeholder: "Rex")
- Vibe selector: 4 pill buttons, one selected at a time (Warm default)
- CTA: `"Meet [name] →"` — disabled until name is non-empty
- Skip: creates default identity (`name: "Alex"`, `vibe: warm`)
- On submit: `SponsorService.setupIdentity(name, vibe)` then navigate to home

### MemoryTransparencyScreen
Accessible from sponsor chat top bar info icon.

- Header: `"What [name] knows about you."`
- Subtext: `"You control this. Delete anything, anytime."`
- Memories from `longTermMemory` grouped by `MemoryCategory`
- Each card: category label, summary text, `"Learned [date]"` timestamp, delete icon
- Delete: `SponsorService.deleteMemory(id)` + fade-out animation
- Empty state: `"[name] is still learning. Come back after a few conversations."`

---

## Onboarding Integration

`SponsorIntroScreen` is inserted as the final screen in the existing onboarding flow. The `GoRouter` onboarding redirect now checks **both**:
1. `AppStateService.isOnboardingComplete` (existing)
2. `SponsorService.hasIdentity` (new)

Both must be true to leave the onboarding flow. This means `app_router.dart` redirect logic is updated — the spec acknowledges this change.

---

## What's Deferred

| Feature | Phase | Notes |
|---|---|---|
| Streaming responses | 2 | Architecture already supports it |
| Proactive heartbeat / drift alerts | 2 | `NotificationService` hook point exists |
| Scheduled touchpoints (morning nudge, weekly digest) | 2 | Opt-in, user-controlled |
| Voice mode (TTS/STT) | 3 | On-device or ElevenLabs |
| Real human bridge | 3 | AI drafts message to emergency contact |
| Full 5-level crisis escalation | 2 | Current keyword + 988 is documented MVP floor |
| Server-side memory extraction (NLP) | 2 | Heuristics ship first |

Nothing deferred ships with broken or silent UX. The MVP sponsor is fully functional.

---

## Testing Plan

**Unit:**
- `SponsorService` — identity CRUD, memory encrypted roundtrip (all 3 tiers), stage calculation, `bumpEngagement`, `recalculateEngagement`, `digestSession` extraction, `distillToLongTerm` pruning
- `ContextAssembler` — prompt structure, all sections present, signal injection, offline flag disables API call
- `SponsorMemoryStore` — file write/read/encrypt/decrypt roundtrip, size limits enforced

**Widget:**
- `SponsorIntroScreen` — name input validates, vibe pill selection, CTA disabled when empty, skip creates default
- `SponsorChatScreen` — message flow, crisis border + 988 chip on keyword, digest called on dispose, offline response rendered
- `MemoryTransparencyScreen` — cards render grouped by category, delete fades card + removes from service

**Integration:**
- Full flow: onboarding → sponsor setup → chat → memory written → transparency screen → delete → memory gone

**Edge cases:**
- No identity set → generic fallback, no crash
- Empty memory → empty state in transparency screen
- Crisis keyword → correct UI and prompt injection
- Offline → offline response rendered, no API call made
- App killed mid-session → session memory survives, digest runs on next session end
- Engagement score with no source data → score stays 0, stage stays new_

---

## Files

**New:**
```
lib/core/services/sponsor_service.dart
lib/core/services/sponsor_memory_store.dart
lib/core/models/sponsor_models.dart
lib/core/utils/context_assembler.dart
lib/core/constants/sponsor_soul.dart
lib/features/ai_companion/screens/sponsor_chat_screen.dart
lib/features/ai_companion/screens/sponsor_intro_screen.dart
lib/features/ai_companion/screens/memory_transparency_screen.dart
test/sponsor_service_test.dart
test/sponsor_memory_store_test.dart
test/context_assembler_test.dart
test/sponsor_chat_screen_test.dart
test/sponsor_intro_screen_test.dart
test/memory_transparency_screen_test.dart
```

**Modified:**
```
lib/navigation/app_router.dart         — add SponsorIntroScreen, update redirect logic, swap chat screen
```

**Deleted:**
```
lib/features/ai_companion/screens/companion_chat_screen.dart
test/companion_chat_screen_test.dart
```

**Unchanged:**
```
lib/core/services/ai_service.dart      — still used for step guidance + coping strategies
```
