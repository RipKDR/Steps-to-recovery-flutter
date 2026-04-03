# Meta Plan: Steps to Recovery - Production Launch

> **Document Date:** 2026-04-02  
> **Last Updated:** 2026-04-02  
> **Current State:** Phase 4 Complete (2026-03-29)  
> **Goal:** Production launch with differentiated feature set  
> **Timeline:** 12 weeks to MVP launch, 16 weeks to full feature set  
> **Owner:** H + Kimi (co-founder development partnership)

---

## Current State Assessment

### ✅ What's Working
- **Flutter Version:** 3.41.6 / Dart 3.11.4
- **Architecture:** Offline-first with optional Supabase sync
- **Core Services:** 10 singletons complete and tested
- **Navigation:** GoRouter with shell routing
- **Testing:** 250+ tests passing
- **Theme:** Material 3 dark theme (true black, amber accent)
- **Security:** AES-256 encryption, biometric auth

### ❌ Critical Gaps
1. **Gratitude** - Stub, no persistence
2. **Inventory** - Stub, no persistence  
3. **Mindfulness** - Zero implementation
4. **Progress Dashboard** - Basic stub, no charts
5. **App Icons** - Missing files

---

## Phase Roadmap

```
WEEK:  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16
       ├────┤
       PHASE 5: Foundation
            ├──────────┤
            PHASE 6: Living AI Sponsor
                       ├────┤
                       PHASE 7: Nervous System
                            ├──────────┤
                            PHASE 8: Mindfulness
                                       ├────┤
                                       PHASE 9: The Pause
                                            ├────┤
                                            PHASE 10: Viral Loop
                                                 ├────┤
                                                 PHASE 11: Time Capsule
                                                      ├────────┤
                                                      PHASE 12: Hardening
```

---

## Phase 5: Foundation Completion (Weeks 1-2)

**Goal:** Complete stub features, add charts, create app icons

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 5.1 | Gratitude persistence | `database_service.dart`, `GratitudeScreen` | 2 days | P1 |
| 5.2 | Gratitude streak tracking | `GratitudeScreen` | 1 day | P1 |
| 5.3 | Inventory 10th Step questions | `InventoryScreen` | 2 days | P1 |
| 5.4 | Inventory persistence | `database_service.dart` | 1 day | P1 |
| 5.5 | Progress Dashboard charts | `fl_chart` integration | 3 days | P1 |
| 5.6 | App icons (iOS + Android) | `assets/icons/` | 1 day | P0 |

**Definition of Done:**
- [ ] All stub features persist data
- [ ] App icons display correctly
- [ ] Progress dashboard shows charts
- [ ] All tests pass
- [ ] No analysis errors

---

## Phase 6: Living AI Sponsor (Weeks 3-5)

**Goal:** Replace generic AI with living sponsor (memory + stages)

**Reference:** `docs/superpowers/plans/2026-03-22-living-ai-sponsor.md`

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 6.1 | Crisis constants | `crisis_constants.dart` | 4 hrs | P1 |
| 6.2 | Sponsor soul document | `sponsor_soul.dart` | 2 hrs | P1 |
| 6.3 | Sponsor models | `sponsor_models.dart` | 1 day | P0 |
| 6.4 | Memory store | `sponsor_memory_store.dart` | 2 days | P0 |
| 6.5 | Context assembler | `context_assembler.dart` | 1 day | P1 |
| 6.6 | Sponsor service | `sponsor_service.dart` | 3 days | P0 |
| 6.7 | Sponsor intro screen | `sponsor_intro_screen.dart` | 1 day | P1 |
| 6.8 | Sponsor chat screen | `sponsor_chat_screen.dart` | 2 days | P0 |
| 6.9 | Memory transparency | `memory_transparency_screen.dart` | 1 day | P2 |
| 6.10 | Router updates | `app_router.dart` | 4 hrs | P1 |

**Definition of Done:**
- [ ] Sponsor has persistent memory
- [ ] Relationship stages advance
- [ ] Soul document guides responses
- [ ] User can view/manage memory
- [ ] Old companion code removed

---

## Phase 7: Sponsor Nervous System (Weeks 6-7)

**Goal:** Wire sponsor into app behavior (proactive, not passive)

**Reference:** `docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md`

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 7.1 | Badge system | `sponsor_service.dart` | 1 day | P1 |
| 7.2 | Signal wiring | `_buildSignals()` | 2 days | P0 |
| 7.3 | Feature hooks (2 critical) | `onCheckInCompleted`, `onReturnFromSilence` | 2 days | P0 |
| 7.4 | Shell screen badge | `shell_screen.dart` | 1 day | P1 |
| 7.5 | Journal sponsor prompt | `journal_editor_screen.dart` | 1 day | P2 |
| 7.6 | Reading sponsor CTA | `daily_reading_screen.dart` | 4 hrs | P2 |

**Definition of Done:**
- [ ] Sponsor notices behavioral patterns
- [ ] Amber badge appears when relevant
- [ ] Return from silence triggers welcome
- [ ] High craving triggers sponsor attention

---

## Phase 8: Mindfulness Library (Weeks 8-10)

**Goal:** Add audio player with 5 meditation tracks

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 8.1 | Audio package research | `pubspec.yaml` | 4 hrs | P0 |
| 8.2 | Source/create 5 tracks | `assets/audio/` | 3 days | P0 |
| 8.3 | Audio player service | `audio_player_service.dart` | 2 days | P0 |
| 8.4 | Library screen | `mindfulness_library_screen.dart` | 2 days | P1 |
| 8.5 | Player screen | `meditation_player_screen.dart` | 2 days | P1 |
| 8.6 | Router integration | `app_router.dart` | 4 hrs | P1 |

**Definition of Done:**
- [ ] 5 tracks playable offline
- [ ] Progress ring shows position
- [ ] Audio continues in background
- [ ] Tracks encrypted at rest

---

## Phase 9: The Pause & Tiny Wins (Weeks 11-12)

**Goal:** 90-second urge interrupt + micro-achievement log

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 9.1 | The Pause screen | `the_pause_screen.dart` | 2 days | P0 |
| 9.2 | Home screen integration | `home_screen.dart` | 4 hrs | P1 |
| 9.3 | Tiny Wins feature module | `tiny_wins/` | 2 days | P1 |
| 9.4 | Streak tracking | `TinyWinsService` | 1 day | P2 |

**Definition of Done:**
- [ ] 90-second timer (unskippable)
- [ ] Saves win to Tiny Wins log
- [ ] Shows urge surf streak

---

## Phase 10: Viral Loop (Week 13)

**Goal:** Milestone celebrations that drive sharing

**Reference:** `docs/superpowers/plans/2026-03-22-viral-loop.md`

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 10.1 | Milestone service | `milestone_service.dart` | 1 day | P1 |
| 10.2 | Celebration screen | `milestone_celebration_screen.dart` | 2 days | P0 |
| 10.3 | Share card widget | `milestone_share_card.dart` | 1 day | P1 |
| 10.4 | Profile invite tile | `profile_screen.dart` | 4 hrs | P2 |
| 10.5 | Challenge share | `challenges_screen.dart` | 4 hrs | P2 |

**Definition of Done:**
- [ ] Auto-trigger celebrations
- [ ] PNG share card generation
- [ ] Approach notifications scheduled
- [ ] Profile has invite tile

---

## Phase 11: Time Capsule (Week 14)

**Goal:** Message to future self unlocks at milestones

### Tasks

| # | Task | File(s) | Est | Priority |
|---|------|---------|-----|----------|
| 11.1 | Recording UI | Onboarding + modal | 2 days | P2 |
| 11.2 | Lock/unlock logic | `TimeCapsuleService` | 1 day | P2 |
| 11.3 | Unlock experience | Full-screen modal | 1 day | P2 |

---

## Phase 12: Release Hardening (Weeks 15-16)

**Goal:** Production-ready app

### Tasks

| # | Task | Est | Priority |
|---|------|-----|----------|
| 12.1 | Testing (all tests pass) | 3 days | P0 |
| 12.2 | Performance optimization | 2 days | P0 |
| 12.3 | Accessibility audit | 2 days | P1 |
| 12.4 | Security audit | 1 day | P0 |
| 12.5 | Store preparation (screenshots, copy) | 2 days | P0 |
| 12.6 | Backend readiness | 2 days | P0 |
| 12.7 | Beta testing (TestFlight + Play) | 1 week | P0 |
| 12.8 | Production release | 3-5 days | P0 |

---

## Ongoing Maintenance

### Weekly
- [ ] Run full test suite
- [ ] Check flutter analyze
- [ ] Review Sentry crash reports
- [ ] Update dependencies (monthly)

### Per Feature
- [ ] Write/update tests
- [ ] Update AGENTS.md if conventions change
- [ ] Update .remember/logs/autonomous/memory.md
- [ ] Verify privacy compliance

### Pre-Commit
- [ ] flutter analyze passes
- [ ] flutter test passes
- [ ] No print() statements
- [ ] Sensitive data encrypted
- [ ] Conventional commit message

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Audio assets not ready | Medium | High | Use placeholder + synthetic |
| AI API costs spike | Low | Medium | Aggressive caching + offline fallback |
| App Store rejection | Medium | High | Submit early, prepare for rejection cycle |
| Supabase sync issues | Low | High | Make truly offline-first |
| I Am Sober adds AI | Medium | Critical | Ship first, build memory moat |

---

## Key Metrics

| Metric | Current | Target | By When |
|--------|---------|--------|---------|
| Test coverage | 250+ tests | 300+ tests | Phase 12 |
| Day 7 retention | N/A | >40% | Post-launch |
| Day 30 retention | N/A | >20% | Post-launch |
| Sponsor chat opens | N/A | 2+/week | Post-launch |
| The Pause usage | N/A | 1+/week | Post-launch |
| Milestone share rate | N/A | >20% | Post-launch |

---

## Document History

| Date | Author | Change |
|------|--------|--------|
| 2026-04-02 | Kimi | Initial meta plan |
