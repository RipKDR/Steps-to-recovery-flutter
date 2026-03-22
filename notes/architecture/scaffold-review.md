# H's Scaffold — Review & Decisions
*Reviewed 2026-03-22*

Scaffold location: `C:\Users\H\Downloads\steps_to_recovery_flutter_scaffold.zip`

---

## What the Scaffold Is

A Flutter shell for the AI sponsor feature with:
- Feature slices: Chat, Journal, Stepwork, Contacts, Safety plan, Profile, Settings
- Fake in-memory chat API with keyword-based responses
- Backend contract notes (placeholder)
- Riverpod state management
- `RecoveryStateSnapshot` model
- Streaming chat API design with `action_suggestion` events

---

## What to Keep

### Architecture pattern — Flutter → Recovery API → OpenClaw
The app never talks to OpenClaw directly. Backend mediates everything. This is correct and non-negotiable.

### `RecoveryStateSnapshot` model
Multi-dimensional state is the right shape:
```dart
phase, riskBand24h, craving, isolation, shame, engagement
```
Expand to also include: `relationshipStage`, `relationshipDays`, `appEngagementScore`, `missedCheckIns`, `daysSinceJournal`, `daysSinceHumanContact`, `chatSentimentTrend`, `stepworkPhase`

### Streaming chat with `action_suggestion` events
AI doesn't just reply — it injects UI actions into the stream. "Call sponsor" becomes a button, not text. Keep this pattern.

### `/v1/memory/forget` endpoint
User control over what the AI knows. Non-negotiable. Keep.

### FakeChatApi keyword responses
Good logic for offline/disconnected fallback mode. The isolation response especially is exactly right framing. Keep as fallback, replace with real API.

### `clientContext` in chat payload
Already sends `screen` and `localTime`. Expand to include: `isNightMode`, `sessionDurationSeconds`, `recentScreens`, `relationshipStage`, `daysSober`

---

## What to Replace / Change

### Riverpod → singleton services
The existing app uses singleton services + ChangeNotifier. Introducing Riverpod creates two competing state systems. `SponsorService` will follow the same singleton pattern as `DatabaseService`, `AppStateService`, etc.

### Flat `backend_contract.md`
Needs to grow to cover identity, memory summary, proactive check, engagement context, and crisis escalation endpoints.

---

## Scaffold's Key Non-Negotiables (preserve these)

1. Do not connect mobile client directly to OpenClaw
2. Do not store authoritative product memory in OpenClaw workspace files
3. Keep safety/risk inference server-side
4. Do not design the AI as a replacement for human sponsors or recovery community
5. Prefer simple, maintainable architecture over clever abstractions
