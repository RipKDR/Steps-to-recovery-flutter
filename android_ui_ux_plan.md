# Android UI/UX Polish — Full Implementation Plan

**Branch**: `claude/improve-android-ui-ux-d6PMc`
**Scope**: All 5 phases — design system, shared components, 31 screens, Android config, animations
**Research**: Modern 2026 Material 3 patterns, mental health app UX best practices, premium Flutter dark-theme techniques

---

## Design Philosophy (Research-Backed)

Based on analysis of top-performing wellness/recovery apps (Calm, Headspace, MindDoc) and 2026 Material 3 best practices:

1. **Calm, not clinical** — Soft transitions, generous whitespace, warm typography (Nunito). Recovery is emotional; the UI should feel like a safe room, not a hospital form.
2. **Tonal elevation over shadows** — M3's tonal system uses subtle color shifts instead of heavy drop shadows. On true black OLED, this means our surface hierarchy (#0A0A0A → #141414 → #1A1A1A → #1E1E1E) becomes the primary depth cue.
3. **Glassmorphism accents (subtle)** — Not everywhere, but key cards (home dashboard, milestone celebrations) get frosted glass treatment with `BackdropFilter` sigma 8-10. This is the 2026 premium look on dark themes.
4. **Purposeful micro-animations** — Every animation communicates state change, not decoration. Fade+slide for list items appearing, scale bounce on completion, shimmer for loading.
5. **Non-judgmental UX** — No guilt-based streak counters. No punishing missed days. Progress visualized gently. User can skip, mute, exit anything without friction.
6. **Typography carries 70% of perceived quality** — Nunito gives warmth. Generous line height. Clear hierarchy (Display > Headline > Title > Body > Label).
7. **One repeatable daily action + immediate feedback** — The best wellness apps have one thing users do daily with instant visual reward. Our check-in → stat update → subtle celebration handles this.

---

## Phase 1: Design System Hardening (Foundation)

Changes here cascade to all 31 screens automatically.

### 1A. Add Nunito Font via google_fonts
- **pubspec.yaml** — Add `google_fonts: ^6.2.1`
- **app_typography.dart** — Set `fontFamily: 'Nunito'` on all 15 text styles
- **app_theme.dart** — Add `fontFamily: 'Nunito'` to ThemeData so widgets reading from theme get it too

### 1B. Text Scaling Accessibility (cap at 1.3x)
- **main.dart** — Change `TextScaler.linear(1.0)` to clamp between 1.0–1.3x using `MediaQuery.textScalerOf(context)`
- Respects Android system accessibility settings without breaking layouts

### 1C. Enhance Theme Component Defaults
- **app_theme.dart** additions:
  - `bottomSheetTheme` — `AppColors.surfaceCard` background, rounded top corners (16dp radius)
  - `progressIndicatorTheme` — `linearMinHeight: 6` for consistent progress bars
  - `listTileTheme` — Consistent content padding, min vertical padding, icon color defaults
  - `dividerTheme` — `AppColors.border` color, 1px thickness, no indent by default

### 1D. Add Design Tokens for Common Sizes
- **app_spacing.dart** additions:
  - `illustrationSm = 120`, `illustrationMd = 160`, `illustrationLg = 200`
  - `cardPaddingLg = 20` (for larger content cards)
  - `sectionGap = 28` (gap between major screen sections)

### 1E. Add Glass Card Style to AppColors
- **app_colors.dart** additions:
  - `glassSurface = Color(0x1AFFFFFF)` (10% white overlay for glass effect)
  - `glassBorder = Color(0x33FFFFFF)` (20% white for glass edge highlight)

**Files**: 5 modified, 0 created

---

## Phase 2: Shared Components & Deduplication

### 2A. Create GlassCard Widget
- **Create** `lib/widgets/glass_card.dart` — Premium card with subtle frosted glass effect
  - Uses `BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8))` wrapped in `RepaintBoundary`
  - Falls back to solid `AppColors.surfaceCard` when `MediaQuery.disableAnimations` is true
  - Parameters: `child`, `padding`, `borderRadius`, `blur` (sigma, default 8)
  - Used sparingly: home dashboard cards, milestone celebrations, profile header

### 2B. Consolidate Date Formatting
Replace local `_formatDate()` in 6 screens with `AppUtils.formatDate()` / `AppUtils.formatShortDate()`:
- `daily_reading_screen.dart`, `journal_list_screen.dart`, `journal_editor_screen.dart`
- `inventory_screen.dart`, `meeting_detail_screen.dart`, `memory_transparency_screen.dart`

### 2C. Replace Custom Empty States with Shared EmptyState Widget
5 screens have custom `_EmptyState` implementations. Replace with `EmptyState` from `lib/widgets/`:
- `gratitude_screen.dart` — `_EmptyGratitudeState` → `EmptyState`
- `journal_list_screen.dart` — inline empty state → `EmptyState`
- `danger_zone_screen.dart` — `_EmptyState` → `EmptyState`
- `challenges_screen.dart` — `_EmptyChallengesState` → `EmptyState`
- `progress_dashboard_screen.dart` — `_EmptyMilestoneState` → `EmptyState`

### 2D. Standardize Filter Chips
- **Create** `lib/widgets/app_filter_chip.dart` — Wraps `ChoiceChip` with app amber styling
- Replace custom `_FilterChip` in `journal_list_screen.dart`
- Replace raw `ChoiceChip` in `meeting_finder_screen.dart`

### 2E. Create Dialog/BottomSheet Utilities
- **Create** `lib/widgets/app_dialog.dart` — `showAppDialog()`, `showAppConfirmDialog()`, `showAppBottomSheet()`
- Consistent Material 3 styling: rounded corners, tonal surface, proper padding
- Apply in `sponsor_screen.dart`, `security_settings_screen.dart`, `meeting_finder_screen.dart`, `daily_reading_screen.dart`

### 2F. Create AppFormField Widget
- **Create** `lib/widgets/app_form_field.dart` — Label + TextField with consistent spacing
- Parameters: `label`, `controller`, `hintText`, `maxLines`, `prefixIcon`, `validator`
- Apply in `inventory_screen.dart` (6 repetitive label+TextField groups)

### 2G. Create SettingsSection Widget
- **Create** `lib/widgets/settings_section.dart` — Grouped card section for settings screens
- Parameters: `title`, `children` (list of ListTile/SwitchListTile)
- Visual: Card with rounded corners, section title above, consistent internal spacing
- Apply in `settings_screen.dart`, `security_settings_screen.dart`, `ai_settings_screen.dart`

### 2H. Export all new widgets in barrel
- **widgets.dart** — Add exports for glass_card, app_filter_chip, app_dialog, app_form_field, settings_section

**Files**: ~12 modified, 5 created

---

## Phase 3: Screen-by-Screen Polish

### Priority: LOW polish screens first

#### 3A. Gratitude Screen
- Replace custom empty state with `EmptyState` widget
- Use themed `InputDecoration` on TextField (not `InputBorder.none`)
- Add `Semantics` labels to add/delete buttons
- Wrap body in `SafeArea`
- Add `Dismissible` for swipe-to-delete (modern Android gesture)
- Add `flutter_animate` fade+slideUp for entries appearing
- More generous spacing between entries (`AppSpacing.sectionGap`)

#### 3B. Inventory Screen
- Replace `_formatDate` with `AppUtils.formatDate`
- Replace 6 label+TextField groups with `AppFormField`
- Add `Semantics` labels
- Add save confirmation SnackBar with amber check icon
- Add `SafeArea` for bottom edge-to-edge

#### 3C. Sponsor Chat Screen
- Replace `GestureDetector` send button with `IconButton` for proper ink splash + accessibility
- Replace `_QuickChip` `GestureDetector` with `ActionChip` for Material ripple
- Add `Semantics` to message bubbles (role: "message", label with sender name)
- Use `AppSpacing.touchTargetComfortable` instead of hardcoded 44
- Add animated typing indicator (3 pulsing dots) when `_isSending`
- Message bubbles: slight rounded corners increase (radiusXl = 12 → 16) for modern chat feel

### Priority: MEDIUM polish screens

#### 3D. Onboarding Screen
- Replace hardcoded 150x150 with `AppSpacing.illustrationMd`
- Remove redundant `ElevatedButton.styleFrom` override (theme handles it)
- Use `smooth_page_indicator` (already in pubspec) instead of manual dots
- Add `flutter_animate` fade+scale transitions between pages
- Add `Semantics` labels to page indicators and skip button
- More generous padding around page content for breathing room

#### 3E. Auth Screens (Login + Signup)
- Add `AutofillHints.email` and `AutofillHints.password` (Android Autofill integration)
- Replace `TextField` with `TextFormField` + `Form` for validation
- Add `Semantics` labels
- Polish spacing: more whitespace between form fields (`AppSpacing.xxl` instead of `lg`)
- Logo area: add subtle fade-in animation on screen entry

#### 3F. Settings Screen
- Replace raw `toIso8601String().split('T').first` with `AppUtils.formatDate`
- Group settings into `SettingsSection` cards (Account, Notifications, Privacy, About)
- Replace bare `CircularProgressIndicator` with `LoadingState`
- Consistent `ListTile` height and leading icon styling

#### 3G. Challenges Screen
- Replace bare `CircularProgressIndicator` with `LoadingState` or `ShimmerLoading`
- Replace custom empty state with `EmptyState`
- Standardize progress bar height via theme
- Add `Semantics` to challenge cards and share buttons
- Challenge cards: add subtle border highlight for active challenges

#### 3H. Progress Dashboard
- Replace bare `CircularProgressIndicator` with `LoadingState`
- Replace custom empty state with `EmptyState`
- Replace raw date formatting with `AppUtils.formatDate`
- Add `Semantics` to stat cards and milestone cards
- Stat cards: staggered `flutter_animate` fade+slideUp on load
- Use `GlassCard` for the main sobriety counter section

#### 3I. Home Screen (already HIGH but key screen)
- Main sobriety day counter: wrap in `GlassCard` for premium depth
- Stat cards row: add staggered `flutter_animate` entry animation
- Quick action cards: subtle scale-on-tap feedback
- Ensure `SafeArea` bottom accounts for gesture nav bar

#### 3J. Safety Plan Screen
- Already decent — add `Semantics` labels
- Step indicators: increase touch target to `AppSpacing.touchTargetComfortable` (48dp)

#### 3K. Daily Reading Screen
- Replace `_formatDate` with `AppUtils.formatDate`
- Use `showAppBottomSheet` for library modal
- Add `flutter_animate` fade for reading content transitions

#### 3L. Sponsor Screen
- Use `showAppDialog` for editor/delete dialogs
- Remove redundant button style overrides

#### 3M. Meeting Finder Screen
- Replace `ChoiceChip` with `AppFilterChip`
- Add `Semantics`

#### 3N. Danger Zone Screen
- Replace custom `_EmptyState` with shared `EmptyState`
- Add `SafeArea` for bottom padding

#### 3O. Steps Screens (overview, detail, review)
- Add `Semantics` labels
- Standardize progress bar styling via theme

#### 3P. Crisis Screens (emergency, before_you_use, craving_surf)
- Already HIGH polish — light touch only
- Replace any hardcoded dimensions with spacing tokens
- Verify `SafeArea` handling

**Files**: ~22 modified

---

## Phase 4: Android-Specific Refinements

### 4A. App Identity
- **AndroidManifest.xml** — Change `android:label` to `"Steps to Recovery"`
- **build.gradle.kts** — Change `applicationId` from `com.example.steps_recovery_flutter` (confirm final ID)

### 4B. Launch Theme Fix (eliminate white flash)
- **values/styles.xml** — Change `LaunchTheme` parent from `Theme.Light.NoTitleBar` to `Theme.Black.NoTitleBar`
- This eliminates the white flash between system boot and Flutter rendering on dark theme
- Verify night theme already uses black parent (it does)

### 4C. Splash Screen
- Verify `assets/icons/splash_logo.png` exists
- Run `dart run flutter_native_splash:create` to regenerate with true black background

### 4D. Edge-to-Edge SafeArea Audit
Add bottom `SafeArea` to screens missing it (Android gesture nav bar overlap):
- `gratitude_screen.dart`, `inventory_screen.dart`, `challenges_screen.dart`, `danger_zone_screen.dart`

### 4E. Bottom Navigation Bar Polish
- **shell_screen.dart** — Ensure bottom nav sits above gesture bar with proper padding
- Add subtle divider line above bottom nav for visual separation
- Selected item: amber icon + label. Unselected: muted gray icon only (no label) for cleaner look

**Files**: 5-7 modified

---

## Phase 5: Animation & Polish Pass

### 5A. Page Transitions
- **app_router.dart** — Add `CustomTransitionPage` with Material 3 fade-through for push routes
- Tab switches: keep `NoTransitionPage` (instant, feels native)
- Modal routes (crisis screens): slide-up from bottom

### 5B. Micro-interactions via flutter_animate
Applied sparingly for premium feel:
- **List items appearing**: `.animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0)` — subtle, not distracting
- **Card completion**: `.animate().scale(begin: 1.0, end: 1.02, duration: 150.ms)` — brief scale pulse
- **Stat counters**: `TweenAnimationBuilder` count-up (home screen already does this — extend to progress dashboard)
- **Screen entry**: fade in over 200ms (all screens via shared wrapper or per-screen)
- All animations respect `MediaQuery.disableAnimations`

### 5C. Loading States: Shimmer Skeletons
Replace bare `CircularProgressIndicator` with contextual `ShimmerLoading` layouts:
- **Journal list** → shimmer skeleton of 3 card shapes
- **Meeting finder** → shimmer skeleton of map placeholder + 2 list items
- **Challenges list** → shimmer skeleton of 2 challenge cards
- **Progress dashboard** → shimmer skeleton of stat row + chart placeholder

### 5D. Haptic Feedback
- Add `HapticFeedback.lightImpact()` on:
  - Check-in completion
  - Milestone celebration trigger
  - Tab switches
  - Craving slider endpoint changes
- Subtle physical feedback = premium feel on Android

**Files**: ~8 modified

---

## Implementation Order

```
Phase 1 (Foundation)     ← Do first, everything inherits
  ↓
Phase 2 (Components)     ← Build tools before using them
  ↓
Phase 4 (Android Config) ← Quick wins, can parallel with Phase 3
  ↓
Phase 3 (Screen Polish)  ← Biggest phase, use new components
  ↓
Phase 5 (Animations)     ← Final layer of premium feel
```

---

## Summary

| Phase | Effort | Impact | Files |
|-------|--------|--------|-------|
| 1: Design System | Small | High (cascading) | 5 |
| 2: Shared Components | Medium | High (dedup + new widgets) | ~17 |
| 3: Screen Polish | Large | Very High (visible) | ~22 |
| 4: Android Config | Small | Medium (identity + no white flash) | 6 |
| 5: Animation | Medium | High (premium feel) | ~8 |

**Total**: ~58 file touches across all phases
**New files**: 5 (glass_card, app_filter_chip, app_dialog, app_form_field, settings_section)
**New dependency**: 1 (google_fonts)
**Design philosophy**: Calm, warm, non-judgmental, premium dark-theme with tonal depth + subtle glass accents
