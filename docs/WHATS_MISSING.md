# What's Missing in Steps to Recovery Flutter

> **Assessment Date:** 2026-03-27  
> **Reference:** Comparison with React Native app (`notes/gap-analysis/rn-vs-flutter.md`)

---

## 🚨 Critical Gaps (High Priority)

### 1. Mindfulness Library - ENTIRELY MISSING
**Location:** `lib/features/mindfulness/` - Does not exist

**What RN app has:**
- MindfulnessLibraryScreen with 5 categories:
  - Breathing exercises
  - Urge surfing
  - Gratitude meditation
  - Sleep meditation
  - Affirmations
- MeditationPlayerScreen (full audio player, progress ring)
- 13 pre-recorded meditation tracks (3–15 min)
- Emergency meditation filter

**Flutter status:** Zero implementation

**Effort:** HIGH — needs audio player package, asset bundling, progress animation

---

### 2. Progress Dashboard - Minimal Stub
**Location:** `lib/features/progress/screens/progress_dashboard_screen.dart`

**What RN app has:**
- Mood chart (line/bar chart)
- Craving chart
- Mood heatmap (calendar view)
- Craving heatmap
- Recovery strength card
- Weekly report
- Weather-mood insight
- Commitment calendar
- Time range selector
- 6 custom hooks
- 12 components

**Flutter status:** Basic stats display only (check-ins, journal count, steps, meetings)

**Effort:** HIGH — needs charting library (`fl_chart` already in pubspec!), data aggregation, heatmap component

---

### 3. App Icons & Assets - Missing Files
**Location:** `assets/icons/` and `assets/images/`

**Missing files:**
| File | Required Size | Purpose |
|------|--------------|---------|
| `assets/icons/app_icon.png` | 1024x1024 | Main app icon |
| `assets/icons/app_icon_foreground.png` | 1024x1024 | Android adaptive icon foreground |
| `assets/icons/splash_logo.png` | 512x512 | Splash screen logo |
| `assets/images/*` | Various | App images |

**Current status:** Only `ICON_INSTRUCTIONS.md` and `.gitkeep` exist

**Effort:** LOW — design/create icons and add to assets

---

## ⚠️ Major Gaps (Medium-High Priority)

### 4. Meetings Feature - Partial Implementation
**Location:** `lib/features/meetings/`

**Implemented:**
- ✅ MeetingFinderScreen (basic list + filter)
- ✅ MeetingDetailScreen
- ✅ Toggle favorite

**Missing:**
- ❌ Location search with map
- ❌ AchievementsScreen
- ❌ MeetingStatsScreen
- ❌ FavoriteMeetingsScreen (has placeholder in router)
- ❌ Pre/post reflection modals
- ❌ Check-in modal
- ❌ 90-in-90 tracking

**Effort:** MED-HIGH

---

### 5. Notification Settings - Partial
**Location:** `lib/features/profile/screens/settings_screen.dart`

**Implemented:**
- ✅ Basic toggle
- ✅ Time pickers for morning/evening reminders

**Missing:**
- ❌ Geofencing support
- ❌ Encouragement toggle
- ❌ Milestone toggle
- ❌ Test notification button

**Effort:** MEDIUM

---

### 6. Security Settings - Partial
**Location:** `lib/features/profile/screens/security_settings_screen.dart`

**Implemented:**
- ✅ Biometric toggle
- ✅ Sign out
- ✅ Reset local data

**Missing:**
- ❌ Key rotation (age, manual rotation, per-table progress)
- ❌ Lock timeout
- ❌ PIN fallback

**Effort:** MEDIUM

---

### 7. Gratitude Screen - Stub
**Location:** `lib/features/gratitude/screens/gratitude_screen.dart`

**Implemented:**
- ✅ Basic text input
- ✅ In-memory list display

**Missing:**
- ❌ Persistence to database
- ❌ Streak tracking
- ❌ Past entries history
- ❌ Success modal

**Effort:** LOW (2-3 days)

---

### 8. Inventory Screen - Stub
**Location:** `lib/features/inventory/screens/inventory_screen.dart`

**Implemented:**
- ✅ Basic text fields (resentful, selfish, dishonest, afraid, harmed, kind)

**Missing:**
- ❌ Structured 10th Step yes/no questions
- ❌ Persistence to database
- ❌ Success modal

**Effort:** LOW (2-3 days)

---

### 9. Journal Editor - Partial
**Location:** `lib/features/journal/screens/journal_editor_screen.dart`

**Implemented:**
- ✅ Text input
- ✅ Tags
- ✅ Favorites
- ✅ CRUD operations

**Missing:**
- ❌ Voice recording
- ❌ Speech-to-text transcription
- ❌ Memory extraction (AI)
- ❌ Share modal

**Effort:** MEDIUM

---

### 10. Widget Settings - ENTIRELY MISSING
**RN app has:**
- 4-step widget setup
- Live preview
- Display toggles
- Manual sync

**Flutter status:** Not mentioned anywhere in codebase

**Effort:** MEDIUM

---

### 11. Crisis/Emergency - Partial
**Location:** `lib/features/crisis/`, `lib/features/emergency/`

**Implemented:**
- ✅ BeforeYouUseScreen
- ✅ EmergencyScreen
- ✅ DangerZoneScreen

**Missing:**
- ❌ GroundingExercise
- ❌ SafeDialInterventionScreen
- ❌ AddRiskyContactModal
- ❌ RiskyContactCard
- ❌ CloseCallInsights

**Effort:** MEDIUM

---

### 12. Auth - Partial
**Location:** `lib/features/auth/`

**Implemented:**
- ✅ LoginScreen
- ✅ SignupScreen

**Missing:**
- ❌ ForgotPasswordScreen (button exists but is commented out in login_screen.dart:117-124)
- ❌ BiometricPrompt

**Effort:** LOW

---

## 📋 Other Notable Gaps

### Charts & Analytics
- `fl_chart` is in pubspec.yaml but NOT used in Progress Dashboard
- Mood heatmap component needed
- Craving visualization needed

### Geofencing
- Referenced in gap analysis for notifications
- No implementation found

### App Store Link
- Placeholder `idXXXXXXXXX` in `lib/core/constants/app_constants.dart:116`
- Needs real App Store ID

### Home Screen Widgets
- Planned (Phase 5) but not specced or implemented
- See `notes/features/original-ideas.md:30`

---

## ✅ What's Well Implemented

| Feature | Status | Notes |
|---------|--------|-------|
| Core services (10 singletons) | ✅ Complete | All services from AGENTS.md implemented |
| Navigation (go_router) | ✅ Complete | Shell routing with 4 tabs |
| Theme system | ✅ Complete | Material 3 with custom dark theme |
| Encryption | ✅ Complete | AES-256 via EncryptionService |
| Database | ✅ Complete | CRUD for all entities |
| Steps work | ✅ Complete | 12 steps with questions |
| AI Sponsor/Companion | ✅ Complete | Chat with memory |
| Biometric auth | ✅ Complete | Basic toggle works |
| Tests | ✅ Complete | 27 test files |
| Onboarding | ✅ Complete | Full flow |
| Challenges | ✅ Complete | With templates |
| Daily readings | ✅ Complete | 24-hour rotation |
| Safety plan | ✅ Complete | Basic implementation |
| Sponsor setup | ✅ Complete | Intro + chat screens |

---

## 📝 TODO Comments Found in Code

1. **`lib/features/home/screens/home_screen.dart:224`**
   ```dart
   // TODO(viral-loop): Upgrade to PNG share using MilestoneShareCard
   ```

2. **`linux/flutter/CMakeLists.txt:9`** & **`windows/flutter/CMakeLists.txt:9`**
   ```cmake
   # TODO: Move the rest of this into files in ephemeral
   ```

---

## 🎯 Recommended Priority Order

### Phase 1: Quick Wins (2-3 days each)
1. **Gratitude** — Add persistence + streak tracking
2. **Inventory** — Add structure + persistence
3. **App icons** — Create and add asset files
4. **Forgot Password** — Complete auth flow

### Phase 2: Medium Effort (1-2 weeks)
5. **Security settings** — Key rotation, PIN fallback
6. **Notification settings** — Geofencing, test button
7. **Progress Dashboard** — Add charts using fl_chart
8. **Crisis additions** — Grounding exercises, safe dial

### Phase 3: High Effort (2-4 weeks)
9. **Mindfulness library** — Full feature with audio player
10. **Meetings enhancements** — Maps, stats, 90-in-90
11. **Journal voice** — Recording + transcription
12. **Widget settings** — Home screen widget setup

---

## 📁 Related Documentation

- `notes/gap-analysis/rn-vs-flutter.md` — Detailed comparison
- `AGENTS.md` — Architecture overview
- `PROJECT_SUMMARY.md` — Project overview
- `notes/features/original-ideas.md` — Feature ideas backlog
- **`docs/WHATS_MISSING_BACKEND.md`** — Backend/Supabase gaps (database, sync, deployment)
