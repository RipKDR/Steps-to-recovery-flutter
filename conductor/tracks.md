# Tracks Registry: Steps to Recovery

> Work units with status. Update when a track starts, changes state, or completes.

## Active Tracks

| ID | Name | Phase | Status | Started |
|---|---|---|---|---|
| phase-6-ai-sponsor | Living AI Sponsor | 6 | 🔄 In Progress | 2026-03-29 |
| phase-7-nervous-system | Sponsor Nervous System | 7 | 🔄 In Progress | 2026-04-02 |
| phase-8-mindfulness | Mindfulness Library | 8 | 🔄 In Progress | 2026-04-02 |

## Planned Tracks

| ID | Name | Phase | Status | Depends On |
|---|---|---|---|---|
| phase-9-the-pause | The Pause + Tiny Wins | 9 | 📅 Planned | phase-6-ai-sponsor |
| phase-10-viral-loop | Viral Loop (Milestone Share) | 10 | 📅 Planned | — |
| phase-11-time-capsule | Time Capsule | 11 | 📅 Planned | phase-10-viral-loop |
| phase-12-hardening | Release Hardening | 12 | 📅 Planned | all phases |

## Completed Tracks

| ID | Name | Phase | Completed |
|---|---|---|---|
| phase-1-core-services | Core Services (10 singletons) | 1 | 2026-03-21 |
| phase-2-navigation | GoRouter Shell Navigation | 2 | 2026-03-22 |
| phase-3-features | Feature Screens (19 modules) | 3 | 2026-03-25 |
| phase-4-ux-polish | UX Polish + Animations | 4 | 2026-03-29 |
| phase-5-foundation | Foundation Completion | 5 | 2026-04-02 |

---

## Track Status Legend

| Symbol | Meaning |
|---|---|
| 🔄 In Progress | Actively being implemented |
| 📅 Planned | Designed, not started |
| ✅ Complete | Shipped, verified |
| ⏸ Blocked | Waiting on dependency or decision |
| 🗑 Archived | Abandoned or superseded |

---

## Phase 6: Living AI Sponsor — Detail

**Goal:** Replace generic AI companion with a living sponsor that has persistent memory, relationship stages, and a soul document guiding responses.

**Reference plans:** `docs/superpowers/plans/2026-03-22-living-ai-sponsor.md`

| Task | File(s) | Status |
|---|---|---|
| 6.1 Crisis constants | `crisis_constants.dart` | ✅ |
| 6.2 Sponsor soul document | `sponsor_soul.dart` | ✅ |
| 6.3 Sponsor models | `sponsor_models.dart` | ✅ |
| 6.4 Memory store | `sponsor_memory_store.dart` | ✅ |
| 6.5 Context assembler | `context_assembler.dart` | 🔄 |
| 6.6 Sponsor service | `sponsor_service.dart` | 🔄 |
| 6.7 Sponsor intro screen | `sponsor_intro_screen.dart` | ✅ |
| 6.8 Sponsor chat screen | `sponsor_chat_screen.dart` | 🔄 |
| 6.9 Memory transparency | `memory_transparency_screen.dart` | 🔄 |
| 6.10 Router updates | `app_router.dart` | 🔄 |

**Definition of Done:**
- [ ] Sponsor has persistent memory across sessions
- [ ] Relationship stages advance (New → Building → Trusted → Close → Deep)
- [ ] Soul document guides response tone and content
- [ ] User can view and manage sponsor memory
- [ ] Old generic companion code removed

---

## Phase 7: Sponsor Nervous System — Detail

**Goal:** Wire sponsor into app behavior — proactive signals, not just reactive chat.

**Reference plans:** `docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md`

| Task | File(s) | Status |
|---|---|---|
| 7.1 Badge system | `sponsor_service.dart` | 🔄 |
| 7.2 Signal wiring | `_buildSignals()` in sponsor_service | 🔄 |
| 7.3 Feature hook: onCheckInCompleted | `home_screen.dart` | 📅 |
| 7.4 Feature hook: onReturnFromSilence | `shell_screen.dart` | 📅 |
| 7.5 Shell screen badge | `shell_screen.dart` | 📅 |
| 7.6 Journal sponsor prompt | `journal_editor_screen.dart` | 📅 |
| 7.7 Reading sponsor CTA | `daily_reading_screen.dart` | 📅 |

**Definition of Done:**
- [ ] Sponsor notices behavioral patterns (silence, craving spikes)
- [ ] Amber badge appears on sponsor tab when relevant
- [ ] Return from silence (7+ days) triggers welcome back message
- [ ] High craving level triggers sponsor attention signal

---

## Phase 8: Mindfulness Library — Detail

**Goal:** Audio player with 5+ meditation tracks, encrypted at rest, playable offline.

| Task | File(s) | Status |
|---|---|---|
| 8.1 Audio player service | `mindfulness_audio_service.dart` | 🔄 |
| 8.2 Library screen | `mindfulness_library_screen.dart` | 🔄 |
| 8.3 Player screen | `meditation_player_screen.dart` | 📅 |
| 8.4 Source/create tracks | `assets/audio/` | 📅 |
| 8.5 Router integration | `app_router.dart` | 📅 |

**Definition of Done:**
- [ ] 5 tracks playable offline
- [ ] Progress ring shows position
- [ ] Audio continues in background
- [ ] Tracks encrypted at rest

---

## Phase 10: Viral Loop — Detail (Planned)

**Reference plans:** `docs/superpowers/plans/2026-03-22-viral-loop.md`

| Task | File(s) | Status |
|---|---|---|
| 10.1 Milestone service | `milestone_service.dart` | 📅 |
| 10.2 Celebration screen | `milestone_celebration_screen.dart` | 📅 |
| 10.3 Share card widget | `milestone_share_card.dart` | 📅 |
| 10.4 Profile invite tile | `profile_screen.dart` | 📅 |
| 10.5 Challenge share | `challenges_screen.dart` | 📅 |
