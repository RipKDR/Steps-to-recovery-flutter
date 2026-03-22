# Gap Analysis — Reference RN App vs Flutter App
*Completed 2026-03-22*

Reference project: `C:\Users\H\Steps-to-recovery\apps\mobile\src\features\`
Flutter project: `C:\Users\H\Steps-to-recovery-flutter\lib\features\`

---

## Critical Gaps (Flutter is missing entirely or substantially)

### 1. Mindfulness (ENTIRELY MISSING)
**RN has:** MindfulnessLibraryScreen (5 categories: breathing, urge surfing, gratitude, sleep, affirmation), MeditationPlayerScreen (full audio player, progress ring), 13 pre-recorded meditation tracks (3–15 min), emergency meditation filter
**Flutter has:** Nothing
**Effort:** HIGH — needs audio player package, asset bundling, progress animation

### 2. Progress Dashboard (minimal stub)
**RN has:** Mood chart, craving chart, mood heatmap, craving heatmap, recovery strength card, weekly report, weather-mood insight, commitment calendar, time range selector, 6 custom hooks, 12 components
**Flutter has:** Basic stats display only
**Effort:** HIGH — needs charting library, data aggregation, heatmap component

### 3. Meetings (partial)
**RN has:** MeetingFinderScreen (location search), AchievementsScreen, MeetingStatsScreen, FavoriteMeetingsScreen, MeetingDetailScreen, pre/post reflection modals, check-in modal, 90-in-90 tracking
**Flutter has:** Basic list + basic detail only
**Effort:** MED-HIGH

### 4. Notification Settings (partial)
**RN has:** Time-picker for 4 reminders, geofencing support, encouragement toggle, milestone toggle, test notification button
**Flutter has:** Basic toggle, no time-pickers, no geofencing
**Effort:** MEDIUM

### 5. Security Settings (partial)
**RN has:** Key rotation (age, manual rotation, per-table progress), lock timeout, PIN fallback
**Flutter has:** Basic biometric toggle
**Effort:** MEDIUM

### 6. Widget Settings (MISSING)
**RN has:** 4-step widget setup, live preview, display toggles, manual sync
**Flutter has:** Nothing
**Effort:** MEDIUM

---

## Medium Gaps

### 7. Gratitude (stub)
**RN has:** Streak tracking, past entries history, success modal
**Flutter has:** Basic text input, no persistence, no streak
**Effort:** LOW

### 8. Inventory (stub)
**RN has:** Structured 10th Step yes/no questions, notes, success modal
**Flutter has:** Basic text fields, no structure, no persistence
**Effort:** LOW

### 9. Journal (partial)
**RN has:** Voice recording + transcription, memory extraction, share modal
**Flutter has:** Text input only
**Effort:** MEDIUM

### 10. Crisis/Emergency (partial)
**RN has:** GroundingExercise, SafeDialInterventionScreen, AddRiskyContactModal, RiskyContactCard, CloseCallInsights
**Flutter has:** BeforeYouUseScreen, EmergencyScreen, DangerZoneScreen
**Effort:** MEDIUM

### 11. Home Screen (partial)
**RN has:** Upcoming milestones card, relapse risk card, sync status indicator
**Flutter has:** Basic dashboard
**Effort:** LOW

### 12. Auth (partial)
**RN has:** ForgotPasswordScreen, BiometricPrompt
**Flutter has:** Login + Signup only
**Effort:** LOW

---

## Priority Order (recommended)

1. Gratitude + Inventory completion — quick wins, 2–3 days each
2. Mindfulness — high impact, pure feature add
3. Notification Settings (time pickers + geofencing)
4. Progress Dashboard (charts + analytics)
5. Meetings (achievements + reflections + 90-in-90)
6. Security Settings (key rotation)
7. Widget Settings
8. Journal enhancements (voice + sharing)
9. Crisis/Emergency additions
10. Home Screen additions
