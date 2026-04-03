# Ongoing Todo List: Steps to Recovery

> **Document Date:** 2026-04-02  
> **Last Updated:** 2026-04-02  
> **Status:** Living Document - Update daily as work progresses  
> **Owner:** Development Team

---

## Legend

- `[ ]` = Not started
- `[-]` = In progress
- `[x]` = Complete
- `[~]` = Blocked/Deferred
- **P0** = Blocker (ship stops without this)
- **P1** = Critical (high user impact)
- **P2** = Important (medium impact)
- **P3** = Nice-to-have (low impact)

---

## Current Sprint: PHASE 7 - Sponsor Nervous System (Weeks 4-5)

**Goal:** Wire sponsor into app behavior - proactive, not passive

**Reference:** docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md

---

### P0: Badge System & Hooks

```
[x] 7.1 Badge system
    File: lib/core/services/sponsor_service.dart
    Tests: test/sponsor_badge_test.dart (3/3 passing)
    Status: ✅ Complete - hasPendingMessage, pendingMessagePreview, clearPendingMessage()

[x] 7.2 Real signal wiring
    File: lib/core/services/sponsor_service.dart
    Tests: test/sponsor_service_signals_test.dart (4/4 passing)
    Status: ✅ Complete - _buildSignals() with mood trend, craving baseline, streak calculations

[x] 7.3 Feature hooks (5 methods)
    File: lib/core/services/sponsor_service.dart
    Tests: test/sponsor_hooks_test.dart (4/4 passing)
    Status: ✅ Complete - onCheckInCompleted, onJournalSaved, onMilestoneReached, onChallengeCompleted, onReturnFromSilence

[x] 7.4 Shell screen badge
    File: lib/navigation/shell_screen.dart
    Tests: test/shell_screen_badge_test.dart (1/1 passing)
    Status: ✅ Complete - Converted to StatefulWidget, amber dot on Profile tab, auto-clears on visit

[x] 7.5 Journal sponsor prompt
    File: lib/features/journal/screens/journal_editor_screen.dart
    Status: ✅ Complete - Wired onJournalSaved hook, sponsor prompt chip above text field

[x] 7.6 Daily reading sponsor CTA
    File: lib/features/readings/screens/daily_reading_screen.dart
    Status: ✅ Complete - "What would [name] ask you about this?" button

[x] 7.7 Memory transparency patterns
    File: lib/features/ai_companion/screens/memory_transparency_screen.dart
    Status: ✅ Complete - "What I've noticed" section with 3 pattern detectors
```

### P1: Optional Extensions (Post-MVP)

```
[ ] 7.8 SponsorCard on HomeScreen
    File: lib/features/home/widgets/sponsor_card.dart
    Add: Home screen sponsor card with weekly read
    Est: 4 hours
    Ref: docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md (Task 9)

[ ] 7.9 Milestone voice
    File: lib/features/milestone/screens/milestone_celebration_screen.dart
    Add: Sponsor message block with caching
    Est: 1 day
    Ref: docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md (Task 10)
```

---

## Backlog: PHASE 8 - Mindfulness Library

```
[ ] 8.1 Audio package research

[ ] 8.2 Source/create 5 meditation tracks
    BLOCKER: Need audio assets

[ ] 8.3 Audio player service

[ ] 8.4 Library screen

[ ] 8.5 Player screen

[ ] 8.6 Router integration
```

---

## Backlog: PHASE 9 - The Pause & Tiny Wins

```
[ ] 9.1 The Pause screen

[ ] 9.2 Home screen integration

[ ] 9.3 Tiny Wins feature module

[ ] 9.4 Streak tracking
```

---

## Backlog: PHASE 10 - Viral Loop

```
[ ] 10.1 Milestone service
    Ref: docs/superpowers/plans/2026-03-22-viral-loop.md

[ ] 10.2 Celebration screen

[ ] 10.3 Share card widget

[ ] 10.4 Profile invite tile

[ ] 10.5 Challenge share buttons
```

---

## Backlog: PHASE 11 - Time Capsule

```
[ ] 11.1 Recording UI

[ ] 11.2 Lock/unlock logic

[ ] 11.3 Unlock experience
```

---

## Backlog: PHASE 12 - Release Hardening

```
[ ] 12.1 Testing (all tests pass)

[ ] 12.2 Performance optimization

[ ] 12.3 Accessibility audit

[ ] 12.4 Security audit

[ ] 12.5 Store preparation

[ ] 12.6 Backend readiness

[ ] 12.7 Beta testing

[ ] 12.8 Production release
```

---

## Completed Phases

### Phase 6 ✅ COMPLETE - Living AI Sponsor

**Phase 6 Summary:** Living AI Sponsor fully implemented (48/48 tests passing)
- Core infrastructure: Crisis constants, Soul document, Models, Memory store, Context assembler, Service
- UI Screens: Intro, Chat, Memory transparency
- All routes connected

```
[x] 6.1 Crisis Constants
    File: lib/core/constants/crisis_constants.dart
    Tests: test/crisis_constants_test.dart (5/5 passing)

[x] 6.2 Sponsor Soul Document
    File: lib/core/constants/sponsor_soul.dart

[x] 6.3 Sponsor Models
    File: lib/core/models/sponsor_models.dart
    Tests: test/sponsor_models_test.dart (16/16 passing)

[x] 6.4 Sponsor Memory Store
    File: lib/core/services/sponsor_memory_store.dart
    Tests: test/sponsor_memory_store_test.dart (8/8 passing)

[x] 6.5 Context Assembler
    File: lib/core/utils/context_assembler.dart

[x] 6.6 Sponsor Service
    File: lib/core/services/sponsor_service.dart
    Tests: test/sponsor_service_test.dart (12/12 passing)

[x] 6.7 Sponsor Intro Screen
    File: lib/features/ai_companion/screens/sponsor_intro_screen.dart
    Tests: test/sponsor_intro_screen_test.dart (1/1 passing)

[x] 6.8 Sponsor Chat Screen
    File: lib/features/ai_companion/screens/sponsor_chat_screen.dart
    Tests: test/sponsor_chat_screen_test.dart (8/8 passing)

[x] 6.9 Memory Transparency Screen
    File: lib/features/ai_companion/screens/memory_transparency_screen.dart

[x] 6.10 Router Updates
    File: lib/navigation/app_router.dart
```

---

## Blocked Items

| Task | Blocked By | Resolution |
|------|------------|------------|
| 8.2 Source meditation tracks | Need audio assets | Use placeholder or CC tracks |

---

## Recently Completed

| Date | Task | Notes |
|------|------|-------|
| 2026-04-02 | Task 7.7 Memory patterns | "What I've noticed" with pattern detection (agent swarm) |
| 2026-04-02 | Task 7.6 Daily reading CTA | "What would [name] ask you about this?" button |
| 2026-04-02 | Task 7.5 Journal sponsor prompt | Sponsor prompt chip + onJournalSaved hook |
| 2026-04-02 | Task 7.4 Shell screen badge | 291/291 tests passing |
| 2026-04-02 | Task 7.3 Feature hooks | 4/4 tests passing |
| 2026-04-02 | Task 7.2 Signal wiring | 4/4 tests passing |
| 2026-04-02 | Task 7.1 Badge system | 3/3 tests passing |
| 2026-03-29 | Phase 4 complete | 250+ tests passing |
| 2026-03-27 | Memory system operational | Auto-load configured |

---

## Quick Commands Reference

```bash
# Run app
.\tool\flutterw.ps1 run -d chrome
.\tool\flutterw.ps1 run -d <device_id>

# Quality checks
.\tool\flutterw.ps1 analyze
.\tool\flutterw.ps1 test
.\tool\flutterw.ps1 test test/<file>_test.dart

# Build
.\tool\flutterw.ps1 build apk --release
.\tool\flutterw.ps1 build ios --release
```

---

## Document History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-02 | Kimi | Updated - Phase 7 tasks 7.1-7.7 complete (agent swarm) |
| 2026-04-02 | Kimi | Updated - Phase 7 tasks 7.1-7.6 complete |
| 2026-04-02 | Kimi | Updated - Phase 7 tasks 7.1-7.4 complete |
| 2026-04-02 | Kimi | Initial todo list creation |
