# Living AI Sponsor
*Feature design — 2026-03-22 — Status: Approved, not yet specced*

---

## What It Is

An AI agent that behaves like a long-term friend who has known you through your entire recovery. Not a chatbot with memory bolted on — a relationship that has stages, depth, voice, and genuine proactive care. It reaches out before you fall, not after.

The 3am best friend that actually *knows* you.

---

## Identity

- User names the sponsor during onboarding (e.g. "Rex")
- User picks a starting vibe: warm / direct / spiritual / tough love
- Vibe adapts over time based on what actually works for this user
- Sponsor has a consistent voice and personality across all interactions

---

## Three-Tier Memory

| Tier | What | When |
|---|---|---|
| Session | What was said in this conversation | Discarded after session |
| Daily Digest | Extracted themes, emotional state, key moments | Nightly, server-side |
| Long-Term | Distilled patterns, relationship milestones, what works for this user | Weekly extraction from digests |

Memory is NEVER raw text. Always extracted themes and structured data. Encrypted at rest.

**Memory Transparency UI** — "What does [name] know about me?"
- Memory cards by category: Life Context, Recovery Patterns, What Works For You, Key Relationships, Hard Moments
- Any card can be deleted by the user
- Non-negotiable feature — not optional

---

## Relationship Stages

| Stage | Trigger | Behaviour |
|---|---|---|
| New (0–7d) | First open | 3 onboarding questions. Warm, professional. Max 1 nudge/day. |
| Building (7–30d) | Consistent use | References past convos. Recognises patterns. More direct. |
| Trusted (30–90d) | Regular engagement | Calls out avoidance. Initiates on drift. Less formal. |
| Close (90–365d) | Sustained relationship | Deep references. Weekly digest. Pushes on growth. |
| Deep (365d+) | Long-term | Full journey awareness. Growth-oriented challenges. |

Stage is earned (engagement score + interaction depth + consistency), not just time.

---

## Data Access — Hybrid

**Sees (aggregated signals):**
- Mood trends, craving scores, check-in streaks
- Days since last journal (not content)
- Stepwork phase / progress
- App engagement score
- Days since human contact
- Chat sentiment trend (declining / stable / improving)

**Never sees:**
- Raw journal text
- Raw stepwork answers
- Private notes

**Explicit share:**
- User can tap "share my week" → sends a summary
- User can share a specific journal entry manually

---

## Proactive Behavior

**Behavioral drift alerts (always on):**
- Missed check-ins
- Craving spike above personal baseline
- 3+ days no human contact
- 3+ consecutive declining moods
- Week of silence from the user

**Scheduled touchpoints (opt-in per type):**
- Morning nudge
- Weekly Sunday digest in sponsor's voice
- Milestone approach reminders
- Journal prompts from sponsor

**User-controlled cap:** max X notifications per day (user sets this)

---

## Proactive Message Types

| Type | Trigger | Example |
|---|---|---|
| Achievement reaction | Milestone hit | "73 days. I remember when you thought 30 was impossible." |
| Journal prompt | Sponsor-initiated | "Something's been on my mind for you. Want to explore it?" |
| Pattern observation | Drift detected | "You've gone quiet. That's a pattern we've talked about." |
| Weekly digest | Sunday 6pm | Week summary in sponsor's voice |
| Recovery content | Contextually relevant | "This resonated with what you shared on Tuesday" |

---

## Voice Mode

- Sponsor responses can be spoken (TTS — on-device or ElevenLabs)
- User can respond via voice-to-text
- 3am mode auto-suggests voice: "Want to just talk instead of type?"
- Voice persona matches chosen vibe

---

## Real Human Bridge

When isolation or drift detected, sponsor offers to draft a message to a real contact.

- AI drafts: "Hi [name], I need some support tonight."
- User reviews → sends or edits → sends (pre-authorised contacts can be sent directly)
- AI never sends without consent — but pre-authorisation reduces 3am friction
- This is a guardrail built as a feature: the sponsor actively pushes toward human connection

---

## Crisis Escalation Tree (5 Levels)

```
Level 1 — Sponsor shift
  Risk band = elevated
  Direct, crisis-ready, immediate coping technique

Level 2 — Persistence (10 min no response)
  Push notification: "Hey. Still here. You okay?"

Level 3 — Human bridge offer (5 more min no response)
  "Want me to text [contact]?"

Level 4 — Auto-draft (user accepts)
  Draft to emergency contact → user sends (or pre-authorised = sends immediately)

Level 5 — Hard escalation (riskBand = critical)
  988 full screen. Sponsor stays present. "I'm not going anywhere."
```

---

## Architecture

```
Flutter App
  └── SponsorService (singleton, matches existing pattern)
        ├── RecoveryApiClient (HTTP + SSE streaming)
        ├── SponsorIdentityCache (local encrypted)
        ├── MemoryTransparencyStore (local cache for UI)
        └── ProactiveHandler (heartbeat → notifications)

Recovery API (Supabase Edge Functions)
  ├── SafetyClassifier (guardrails — invisible to user)
  ├── ContextBuilder
  │     ├── SignalAggregator
  │     ├── EngagementScorer
  │     ├── RelationshipCalculator
  │     └── MemoryRetriever
  ├── RiskEngine
  │     ├── CrisisDetector
  │     ├── DriftDetector
  │     └── EscalationOrchestrator
  ├── MemoryService
  │     ├── SessionDigestor (nightly)
  │     ├── LongTermExtractor (weekly)
  │     └── MemoryEditor (user-controlled)
  └── OpenClawAdapter
        └── ContextAssembler → OpenClaw → model providers
```

---

## API Endpoints (new, beyond scaffold)

```
GET  /v1/sponsor/identity
PUT  /v1/sponsor/identity
GET  /v1/sponsor/memory
DELETE /v1/sponsor/memory/:id
POST /v1/proactive/check
POST /v1/sponsor/draft-message
GET  /v1/sponsor/weekly-digest
POST /v1/crisis/escalate
```

---

## Open Questions

- [ ] Voice provider: on-device TTS vs ElevenLabs?
- [ ] Memory extraction: how do we extract themes without reading raw journal content? (NLP on server-side, encrypted pipeline)
- [ ] Sponsor Soul Document: does H contribute personal voice/phrases directly?
