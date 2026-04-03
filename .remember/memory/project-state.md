# Project State — Steps to Recovery

**Last Updated:** 2026-04-02
**Status:** Phase 5 In Progress / Foundation Completion

---

## Current Phase

- **Flutter Version:** 3.41.6 / Dart 3.11.4
- **Architecture:** Offline-first with optional Supabase sync
- **Auth:** Local-first with biometric/session lock
- **Storage:** AES-256 encrypted SharedPreferences
- **UI:** Material 3, Dark-mode first

---

## Critical Context

- **Privacy Mandate:** No PII leaves the device unless Supabase sync is explicitly enabled.
- **Data Security:** All journal entries, check-ins, and step-work are encrypted at rest.
- **Offline First:** All features must function without an internet connection.

---

## Completed Milestones

### Phase 4 Complete (2026-03-29)
- ✅ **Mindfulness Integration:** Quick action on Home Screen + Route integration.
- ✅ **Meeting Stats Integration:** Entry point from Meeting Finder screen.
- ✅ **Audio Asset Preparation:** Directory structure and `pubspec.yaml` registration complete.
- ✅ **Bug Fixes:** Achievement Share CTA correctly filters viewed milestones.
- ✅ **Test Stability:** Updated `settings_screen_test.dart` to match current UI; all 250 tests passing.

### Meta Planning Complete (2026-04-02)
- ✅ **Competitor Analysis:** Documented landscape in `docs/analysis/COMPETITOR_ANALYSIS.md`
- ✅ **Feature Workflow:** User journey maps in `docs/planning/FEATURE_WORKFLOW.md`
- ✅ **Production Plan:** 16-week roadmap in `docs/meta/PRODUCTION_PLAN.md`
- ✅ **Ongoing Todo:** Living task list in `docs/meta/ONGOING_TODO.md`

---

## Current Phase: Phase 6 - Living AI Sponsor (Weeks 1-3)

**Goal:** Replace generic AI with relationship-based sponsor (memory + stages + soul)

### Phase 5 Complete (2026-04-02) ✅
✅ Gratitude - Full persistence, streak tracking
✅ Inventory - Step 10 questions, persistence
✅ Progress Dashboard - 4 chart types (mood, craving, heatmap, step progress)
✅ App icons - Generated for all platforms
✅ Splash screens - Generated for all platforms

### Phase 6 COMPLETE ✅ (2026-04-02)
**Reference:** docs/superpowers/plans/2026-03-22-living-ai-sponsor.md

**All Tasks Complete - Living AI Sponsor Fully Implemented:**

**Core Infrastructure:**
- ✅ 6.1 Crisis Constants (5/5 tests)
- ✅ 6.2 Sponsor Soul Document (therapeutic orientation)
- ✅ 6.3 Sponsor Models (14/14 tests)
- ✅ 6.4 Sponsor Memory Store (8/8 tests)
- ✅ 6.5 Context Assembler (prompt builder)
- ✅ 6.6 Sponsor Service (12/12 tests)

**UI Implementation:**
- ✅ 6.7 Sponsor Intro Screen (1/1 tests)
- ✅ 6.8 Sponsor Chat Screen (8/8 tests)
- ✅ 6.9 Memory Transparency Screen
- ✅ 6.10 Router Updates

**Total: 48/48 tests passing**

### Definition of Done
- [ ] All stub features persist data
- [ ] App icons display correctly on both platforms
- [ ] Progress dashboard shows meaningful charts
- [ ] All tests pass (`flutter test`)
- [ ] No analysis errors (`flutter analyze`)

---

## Upcoming Phases

| Phase | Timeline | Focus |
|-------|----------|-------|
| Phase 6 | Weeks 3-5 | Living AI Sponsor (memory + stages) |
| Phase 7 | Weeks 6-7 | Sponsor Nervous System (proactive) |
| Phase 8 | Weeks 8-10 | Mindfulness Library (5 tracks) |
| Phase 9 | Weeks 11-12 | The Pause + Tiny Wins |
| Phase 10 | Week 13 | Viral Loop (milestones) |
| Phase 11 | Week 14 | Time Capsule |
| Phase 12 | Weeks 15-16 | Release Hardening |

---

## Key Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| Competitor Analysis | `docs/analysis/COMPETITOR_ANALYSIS.md` | Market landscape |
| Feature Workflow | `docs/planning/FEATURE_WORKFLOW.md` | User journey maps |
| Production Plan | `docs/meta/PRODUCTION_PLAN.md` | 16-week roadmap |
| Ongoing Todo | `docs/meta/ONGOING_TODO.md` | Living task list |
| Living AI Sponsor Plan | `docs/superpowers/plans/2026-03-22-living-ai-sponsor.md` | Sponsor implementation |
| Nervous System Plan | `docs/superpowers/plans/2026-04-02-sponsor-nervous-system.md` | Proactive features |
| Viral Loop Plan | `docs/superpowers/plans/2026-03-22-viral-loop.md` | Growth features |

---

## Verification Commands

```powershell
.\tool\flutterw.ps1 analyze              # Static analysis
.\tool\flutterw.ps1 test                 # All tests (250+)
.\tool\flutterw.ps1 run -d chrome        # Run on Chrome
.\tool\flutterw.ps1 build apk --debug    # Android debug build
```

---

## Open Questions / TODO

- [ ] Source or generate real mindfulness audio tracks (currently using empty directories)
- [ ] Final accessibility audit on physical devices
- [ ] App Store ID for share links (currently placeholder)
- [ ] Beta tester recruitment for TestFlight/Play

---

## Key Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Test Coverage | 300+ tests | 250+ |
| Day 7 Retention | >40% | N/A (pre-launch) |
| Day 30 Retention | >20% | N/A (pre-launch) |
| Sponsor Chat Opens | 2+/week | N/A (pre-launch) |
| The Pause Usage | 1+/week | N/A (pre-launch) |

---

## Risks

| Risk | Status | Mitigation |
|------|--------|------------|
| Audio assets not ready | Active | Use placeholder + CC tracks |
| App icon design | Active | Use temporary or hire designer |
| AI API costs | Monitoring | Aggressive caching |
| I Am Sober adds AI | Watching | Ship first, build moat |
