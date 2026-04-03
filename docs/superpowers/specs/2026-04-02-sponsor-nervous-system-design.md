# Sponsor as Nervous System — Design Spec
*2026-04-02 | Approved by H*

## Problem
`SponsorService` is a brilliant therapist operating blind. `SponsorSignals.empty()` is passed on every chat turn — the sponsor never sees mood trends, craving baselines, streak data, journal activity, or silence gaps. It's also siloed to one tab and fully passive.

## Goal
Make the OpenClaw-backed sponsor the connective tissue of the entire app: seeing real behavioral data, having a subtle presence in every feature, and quietly signalling when the user needs it — without interruption.

## Scope

### 1. Signal Wiring
Replace `SponsorSignals.empty()` in `SponsorService.respond()` with `_buildSignals()` reading from `DatabaseService`:
- `moodTrend`: avg mood last 7 check-ins vs prior 7 → improving/stable/declining/no data
- `cravingVsBaseline`: same delta on craving scores
- `checkInStreak`: consecutive check-in days
- `daysSinceJournal`: from last journal entry timestamp
- `daysSinceHumanContact`: proxy = days since sponsor chat opened

### 2. Proactive Badge
- `SponsorService` adds `bool hasPendingMessage` + `String? pendingMessagePreview`
- Recomputed on app resume and after each feature hook
- Bottom nav sponsor tab shows amber dot when true
- Clears on sponsor chat open

### 3. Feature Hooks (5 new SponsorService methods)
| Hook | Caller | Trigger |
|---|---|---|
| `onCheckInCompleted(mood, craving)` | Evening/Morning pulse save | Spike or streak |
| `onJournalSaved(wordCount)` | Journal editor | Return after silence |
| `onMilestoneReached(days)` | Milestone screen | Always |
| `onChallengeCompleted(name)` | Challenges screen | Stage-appropriate ack |
| `onReturnFromSilence(days)` | App resume (>3d gap) | Non-judgmental welcome |

### 4. Sponsor Prompts in Features
- **Journal editor**: subtle sponsor prompt above text field, keyed to signals
- **Daily reading**: "What would [name] ask you about this?" → opens sponsor chat with reading as context
- **Challenges**: sponsor name on active challenge card for pattern-matched challenges

### 5. Pattern Detection in Memory Transparency
New "What I've noticed" section in `MemoryTransparencyScreen`:
- Hardest time of week (day + hour bucket with highest avg craving)
- Mood-craving correlation statement
- Streak observation
All rendered in sponsor voice, computed locally from check-in data.

### 6. Home Screen Sponsor Card
New card on `HomeScreen` between sobriety counter and action cards:
- Sponsor name + subtle relationship warmth
- 1–2 sentence weekly read from signals (local, no API unless significant)
- "Talk to [name] →" tap target
- Collapses to single line with no meaningful data yet

### 7. Milestone Voice
`MilestoneCelebrationScreen` gets a sponsor message block:
- One API call at milestone hit with full context
- Cached to `DatabaseService` for offline
- Falls back to soul-document local generation if offline at milestone moment

## Files Affected
- `lib/core/services/sponsor_service.dart` — signal wiring, badge, 5 hooks
- `lib/core/utils/context_assembler.dart` — _buildSignals helper (or inline in service)
- `lib/navigation/app_router.dart` — badge state passed to bottom nav
- `lib/features/home/screens/home_screen.dart` — sponsor card widget
- `lib/features/journal/screens/journal_editor_screen.dart` — sponsor prompt
- `lib/features/readings/screens/daily_reading_screen.dart` — sponsor CTA
- `lib/features/challenges/screens/challenges_screen.dart` — sponsor attribution
- `lib/features/ai_companion/screens/memory_transparency_screen.dart` — patterns section
- `lib/features/milestone/screens/milestone_celebration_screen.dart` — sponsor voice
- `lib/features/home/screens/evening_pulse_screen.dart` — check-in hook
- `lib/features/home/screens/morning_intention_screen.dart` — check-in hook

## Non-Goals
- No push notifications for proactive messages (badge only)
- No Riverpod or new state management
- No new screens
- Sponsor prompts in journal/reading are optional/dismissible — never blocking
