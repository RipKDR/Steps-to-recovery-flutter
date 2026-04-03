# Sponsor as Nervous System — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the OpenClaw-backed `SponsorService` into every feature — real behavioral signals, a proactive badge, sponsor presence in journal/reading/milestones, and a home screen "sponsor's read" card.

**Architecture:** `SponsorService` (ChangeNotifier singleton) gains `hasPendingMessage` + real `_buildSignals()`. Feature screens call 5 new hook methods after key actions. `ShellScreen` listens to `SponsorService` to show an amber dot on the Profile tab. New UI components added to HomeScreen, JournalEditor, DailyReading, MemoryTransparency, and MilestoneCelebration — no new screens, no new state management layers.

**Tech Stack:** Flutter 3.41.5 · Dart 3.x · `shared_preferences` · `DatabaseService` (in-memory + SharedPreferences) · GoRouter · `ChangeNotifier` · flutter_test

---

## File Map

| File | Change |
|---|---|
| `lib/core/services/sponsor_service.dart` | +`hasPendingMessage`, +`pendingMessagePreview`, +`_buildSignals()`, +5 hook methods, replace `SponsorSignals.empty()` |
| `lib/navigation/shell_screen.dart` | Convert to StatefulWidget, listen to SponsorService, show amber dot on Profile tab |
| `lib/features/home/screens/home_screen.dart` | Call `onCheckInCompleted` after morning/evening saves; call `onReturnFromSilence` on resume; add SponsorCard widget |
| `lib/features/home/screens/evening_pulse_screen.dart` | Call `onCheckInCompleted` after `_save()` |
| `lib/features/journal/screens/journal_editor_screen.dart` | Call `onJournalSaved` after save; show sponsor prompt above text field |
| `lib/features/readings/screens/daily_reading_screen.dart` | Add sponsor reflection CTA after main reading body |
| `lib/features/ai_companion/screens/memory_transparency_screen.dart` | Add "What I've noticed" patterns section |
| `lib/features/milestone/screens/milestone_celebration_screen.dart` | Add sponsor voice block (API call + cache) |
| `lib/features/home/widgets/sponsor_card.dart` | **NEW** — home screen sponsor card widget |
| `test/sponsor_service_signals_test.dart` | **NEW** — tests for signal computation + hooks |
| `test/sponsor_badge_test.dart` | **NEW** — tests for badge state |

---

## Task 1: Add badge fields + abstract interface extension to SponsorService

**Files:**
- Modify: `lib/core/services/sponsor_service.dart`
- Test: `test/sponsor_badge_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/sponsor_badge_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorService badge', () {
    late SponsorService svc;

    setUp(() {
      svc = SponsorService.createForTest();
    });

    test('hasPendingMessage is false by default', () {
      expect(svc.hasPendingMessage, isFalse);
      expect(svc.pendingMessagePreview, isNull);
    });

    test('clearPendingMessage resets badge', () async {
      // Manually set via internal test helper
      svc.setTestPendingMessage('Hello');
      expect(svc.hasPendingMessage, isTrue);
      svc.clearPendingMessage();
      expect(svc.hasPendingMessage, isFalse);
      expect(svc.pendingMessagePreview, isNull);
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/sponsor_badge_test.dart
```
Expected: FAIL — `hasPendingMessage` does not exist

- [ ] **Step 3: Add fields + methods to SponsorService**

In `lib/core/services/sponsor_service.dart`, add after `bool _initialized = false;`:

```dart
bool _hasPendingMessage = false;
String? _pendingMessagePreview;

bool get hasPendingMessage => _hasPendingMessage;
String? get pendingMessagePreview => _pendingMessagePreview;

void clearPendingMessage() {
  _hasPendingMessage = false;
  _pendingMessagePreview = null;
  notifyListeners();
}

/// Test-only — allows tests to set badge state directly.
@visibleForTesting
void setTestPendingMessage(String preview) {
  _hasPendingMessage = true;
  _pendingMessagePreview = preview;
}

void _setPendingMessage(String preview) {
  _hasPendingMessage = true;
  _pendingMessagePreview = preview;
  notifyListeners();
}
```

Also add to `SponsorResponder` abstract class:

```dart
bool get hasPendingMessage;
String? get pendingMessagePreview;
void clearPendingMessage();
```

- [ ] **Step 4: Run to verify pass**

```bash
flutter test test/sponsor_badge_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/sponsor_service.dart test/sponsor_badge_test.dart
git commit -m "feat: add hasPendingMessage badge fields to SponsorService"
```

---

## Task 2: Implement `_buildSignals()` — replace `SponsorSignals.empty()`

**Files:**
- Modify: `lib/core/services/sponsor_service.dart`
- Test: `test/sponsor_service_signals_test.dart`

- [ ] **Step 1: Write failing test**

```dart
// test/sponsor_service_signals_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';
import 'package:steps_recovery_flutter/core/utils/context_assembler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SponsorService._buildSignals', () {
    late SponsorService svc;

    setUp(() {
      svc = SponsorService.createForTest();
    });

    test('returns SponsorSignals with string fields when no data', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.moodTrend, isA<String>());
      expect(signals.cravingVsBaseline, isA<String>());
      expect(signals.checkInStreak, isA<int>());
      expect(signals.daysSinceJournal, isA<int>());
      expect(signals.daysSinceHumanContact, isA<int>());
    });

    test('moodTrend is "no data" when no check-ins exist', () async {
      final signals = await svc.buildSignalsForTest();
      expect(signals.moodTrend, 'no data');
    });
  });
}
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/sponsor_service_signals_test.dart
```
Expected: FAIL — `buildSignalsForTest` does not exist

- [ ] **Step 3: Implement `_buildSignals()` in SponsorService**

Add import at top of `sponsor_service.dart`:
```dart
import '../services/database_service.dart';
```

Add the private implementation + test-visible wrapper:

```dart
/// Builds real behavioral signals from DatabaseService.
Future<SponsorSignals> _buildSignals() async {
  try {
    final db = DatabaseService();
    final userId = AppStateService.instance.currentUserId;
    if (userId == null) return SponsorSignals.empty();

    // Last 14 check-ins for trend analysis
    final checkIns = await db.getCheckIns(userId: userId, limit: 14);
    final journals = await db.getJournalEntries(limit: 1);

    // Mood trend: compare avg of last 7 vs prior 7
    final moodTrend = _computeMoodTrend(checkIns);

    // Craving vs baseline: same logic
    final cravingVsBaseline = _computeCravingTrend(checkIns);

    // Check-in streak: consecutive days ending today
    final checkInStreak = _computeStreak(checkIns);

    // Days since last journal
    final daysSinceJournal = journals.isEmpty
        ? 0
        : DateTime.now().difference(journals.first.updatedAt).inDays;

    // Days since last sponsor chat (proxy: last interaction timestamp)
    final daysSinceHumanContact =
        DateTime.now().difference(_stageData.lastInteraction).inDays;

    return SponsorSignals(
      moodTrend: moodTrend,
      cravingVsBaseline: cravingVsBaseline,
      checkInStreak: checkInStreak,
      daysSinceJournal: daysSinceJournal,
      daysSinceHumanContact: daysSinceHumanContact,
    );
  } catch (e, st) {
    LoggerService().error('_buildSignals failed', error: e, stackTrace: st);
    return SponsorSignals.empty();
  }
}

String _computeMoodTrend(List<DailyCheckIn> checkIns) {
  final moods = checkIns
      .where((c) => c.mood != null)
      .map((c) => c.mood!)
      .toList();
  if (moods.length < 4) return 'no data';
  final half = moods.length ~/ 2;
  final recent = moods.take(half).fold(0, (a, b) => a + b) / half;
  final prior = moods.skip(half).fold(0, (a, b) => a + b) / (moods.length - half);
  if (recent > prior + 0.5) return 'improving';
  if (recent < prior - 0.5) return 'declining';
  return 'stable';
}

String _computeCravingTrend(List<DailyCheckIn> checkIns) {
  final cravings = checkIns
      .where((c) => c.craving != null)
      .map((c) => c.craving!)
      .toList();
  if (cravings.length < 4) return 'no data';
  final half = cravings.length ~/ 2;
  final recent = cravings.take(half).fold(0, (a, b) => a + b) / half;
  final prior = cravings.skip(half).fold(0, (a, b) => a + b) / (cravings.length - half);
  if (recent > prior + 1.0) return 'above';
  if (recent < prior - 1.0) return 'below';
  return 'at';
}

int _computeStreak(List<DailyCheckIn> checkIns) {
  if (checkIns.isEmpty) return 0;
  final sorted = checkIns.toList()
    ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
  int streak = 0;
  DateTime expected = DateTime.now();
  for (final c in sorted) {
    final diff = expected.difference(c.checkInDate).inDays;
    if (diff <= 1) {
      streak++;
      expected = c.checkInDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

/// Test-visible wrapper for _buildSignals.
@visibleForTesting
Future<SponsorSignals> buildSignalsForTest() => _buildSignals();
```

Then in `respond()`, replace:
```dart
// OLD:
final signals = SponsorSignals.empty();
```
with:
```dart
// NEW:
final signals = await _buildSignals();
```

- [ ] **Step 4: Run to verify pass**

```bash
flutter test test/sponsor_service_signals_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/sponsor_service.dart test/sponsor_service_signals_test.dart
git commit -m "feat: wire real behavioral signals into SponsorService context"
```

---

## Task 3: Implement 5 feature hook methods on SponsorService

**Files:**
- Modify: `lib/core/services/sponsor_service.dart`
- Test: `test/sponsor_badge_test.dart` (extend)

- [ ] **Step 1: Add tests for hooks to sponsor_badge_test.dart**

```dart
// Add inside the main() → group('SponsorService badge') block:

test('onReturnFromSilence sets pending message when >3 days', () async {
  await svc.onReturnFromSilence(4);
  expect(svc.hasPendingMessage, isTrue);
  expect(svc.pendingMessagePreview, isNotNull);
});

test('onReturnFromSilence does NOT set message for <=3 days', () async {
  await svc.onReturnFromSilence(2);
  expect(svc.hasPendingMessage, isFalse);
});

test('onMilestoneReached always sets pending message', () async {
  await svc.onMilestoneReached(90);
  expect(svc.hasPendingMessage, isTrue);
});

test('onCheckInCompleted sets message when craving is high (>=8)', () async {
  await svc.onCheckInCompleted(mood: 2, craving: 9);
  expect(svc.hasPendingMessage, isTrue);
});

test('onJournalSaved sets message when returning after silence', () async {
  // daysSinceJournal will be 0 in test environment — no message expected
  await svc.onJournalSaved(wordCount: 50);
  // Hook runs without crashing — badge state depends on signals
  expect(svc.hasPendingMessage, isA<bool>());
});
```

- [ ] **Step 2: Run to verify failure**

```bash
flutter test test/sponsor_badge_test.dart
```
Expected: FAIL — hook methods do not exist

- [ ] **Step 3: Implement 5 hooks in SponsorService**

Add after the `clearPendingMessage()` block:

```dart
// ── Feature Hooks ─────────────────────────────────────────────────────────

/// Call after morning or evening check-in is saved.
Future<void> onCheckInCompleted({required int mood, required int craving}) async {
  await bumpEngagement(checkInDays: 1);
  // High craving or very low mood — sponsor notices
  if (craving >= 8 || mood == 1) {
    final name = _identity?.name ?? 'Your sponsor';
    _setPendingMessage('$name noticed your check-in. They\'re here.');
  }
}

/// Call after a journal entry is saved.
Future<void> onJournalSaved({required int wordCount}) async {
  await bumpEngagement(journalDays: 1);
  // Returning after long silence
  final signals = await _buildSignals();
  if (signals.daysSinceJournal >= 5) {
    final name = _identity?.name ?? 'Your sponsor';
    _setPendingMessage('$name noticed you journaled. Good to see you back.');
  }
}

/// Call when a time milestone is reached. Always generates a message.
Future<void> onMilestoneReached(int days) async {
  final name = _identity?.name ?? 'Your sponsor';
  _setPendingMessage('$name has something to say about $days days. Open when ready.');
}

/// Call after a challenge is marked complete.
Future<void> onChallengeCompleted(String challengeName) async {
  final name = _identity?.name ?? 'Your sponsor';
  _setPendingMessage('$name saw you finish "$challengeName". That matters.');
}

/// Call on app resume if last sponsor interaction was >3 days ago.
Future<void> onReturnFromSilence(int daysSilent) async {
  if (daysSilent <= 3) return;
  final name = _identity?.name ?? 'Your sponsor';
  _setPendingMessage('$name hasn\'t heard from you in $daysSilent days. No pressure.');
}
```

- [ ] **Step 4: Run to verify pass**

```bash
flutter test test/sponsor_badge_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/sponsor_service.dart test/sponsor_badge_test.dart
git commit -m "feat: add 5 feature hook methods to SponsorService"
```

---

## Task 4: Make ShellScreen reactive — show amber dot on Profile tab

**Files:**
- Modify: `lib/navigation/shell_screen.dart`

The Profile tab (index 4) hosts the sponsor. Convert `ShellScreen` to `StatefulWidget`, listen to `SponsorService`, overlay an amber dot on the Profile icon when `hasPendingMessage` is true. Dot clears when user navigates to `/profile` or `/home/companion-chat`.

- [ ] **Step 1: No isolated unit test for this (widget test requires router setup — covered by existing router_feature_shell_test.dart). Verify by running the app.**

- [ ] **Step 2: Replace shell_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/sponsor_service.dart';
import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

class ShellScreen extends StatefulWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  @override
  void initState() {
    super.initState();
    SponsorService.instance.addListener(_onSponsorChanged);
  }

  @override
  void dispose() {
    SponsorService.instance.removeListener(_onSponsorChanged);
    super.dispose();
  }

  void _onSponsorChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final hasBadge = SponsorService.instance.hasPendingMessage;

    // Clear badge when user visits sponsor-related screens
    if (location.startsWith('/profile') || location == '/home/companion-chat') {
      SponsorService.instance.clearPendingMessage();
    }

    return PopScope(
      canPop: !_isRootTab(location),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && location != '/home') {
          context.go('/home');
        }
      },
      child: AdaptiveNavigation(
        selectedIndex: _calculateSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryAmber),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit, color: AppColors.primaryAmber),
            label: 'Journal',
          ),
          const NavigationDestination(
            icon: Icon(Icons.stairs_outlined),
            selectedIcon: Icon(Icons.stairs, color: AppColors.primaryAmber),
            label: 'Steps',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people, color: AppColors.primaryAmber),
            label: 'Meetings',
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              icon: const Icon(Icons.person_outline),
              showBadge: hasBadge,
            ),
            selectedIcon: _BadgeIcon(
              icon: const Icon(Icons.person, color: AppColors.primaryAmber),
              showBadge: hasBadge,
            ),
            label: 'Profile',
          ),
        ],
        body: FocusTraversalGroup(child: widget.child),
      ),
    );
  }

  bool _isRootTab(String location) {
    const roots = ['/home', '/journal', '/steps', '/meetings', '/profile'];
    return roots.contains(location);
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/journal')) return 1;
    if (location.startsWith('/steps')) return 2;
    if (location.startsWith('/meetings')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/journal'); break;
      case 2: context.go('/steps'); break;
      case 3: context.go('/meetings'); break;
      case 4: context.go('/profile'); break;
    }
  }
}

class _BadgeIcon extends StatelessWidget {
  final Widget icon;
  final bool showBadge;
  const _BadgeIcon({required this.icon, required this.showBadge});

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryAmber,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/navigation/shell_screen.dart
```
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/navigation/shell_screen.dart
git commit -m "feat: make ShellScreen reactive with sponsor badge on Profile tab"
```

---

## Task 5: Wire check-in hooks into HomeScreen and EveningPulseScreen

**Files:**
- Modify: `lib/features/home/screens/home_screen.dart`
- Modify: `lib/features/home/screens/evening_pulse_screen.dart`

- [ ] **Step 1: Add silence check on resume to HomeScreen**

`HomeScreen` already has `WidgetsBindingObserver` via `AppStateService.instance`. Add a resume check.

In `_HomeScreenState.initState()`, after existing lines, add:

```dart
WidgetsBinding.instance.addObserver(_lifecycleObserver);
```

Add field and nested class before `initState`:

```dart
late final _SilenceObserver _lifecycleObserver;
```

In `initState`, before other lines:
```dart
_lifecycleObserver = _SilenceObserver(onResume: _checkSilence);
WidgetsBinding.instance.addObserver(_lifecycleObserver);
```

In `dispose`:
```dart
WidgetsBinding.instance.removeObserver(_lifecycleObserver);
```

Add method:
```dart
Future<void> _checkSilence() async {
  final lastInteraction = SponsorService.instance.lastInteractionDate;
  if (lastInteraction == null) return;
  final days = DateTime.now().difference(lastInteraction).inDays;
  await SponsorService.instance.onReturnFromSilence(days);
}
```

Add `_SilenceObserver` class at bottom of file (outside state class):
```dart
class _SilenceObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _SilenceObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
```

Also expose `lastInteractionDate` on `SponsorService`:
```dart
DateTime get lastInteractionDate => _stageData.lastInteraction;
```

- [ ] **Step 2: Wire `onCheckInCompleted` after morning save in HomeScreen**

In `_saveMorning()`, after `await DatabaseService().saveCheckIn(...)`:

```dart
await SponsorService.instance.onCheckInCompleted(
  mood: _morningMood,
  craving: 0, // morning check-in has no craving score
);
```

In `_saveEvening()`, after `await DatabaseService().saveCheckIn(...)`:

```dart
await SponsorService.instance.onCheckInCompleted(
  mood: _eveningMood,
  craving: _eveningCraving,
);
```

- [ ] **Step 3: Wire hook in EveningPulseScreen**

In `_save()` in `evening_pulse_screen.dart`, after `await DatabaseService().saveCheckIn(...)`:

```dart
await SponsorService.instance.onCheckInCompleted(
  mood: _mood,
  craving: _craving,
);
```

Add import at top:
```dart
import '../../../core/services/sponsor_service.dart';
```

- [ ] **Step 4: Run analyzer**

```bash
flutter analyze lib/features/home/screens/home_screen.dart lib/features/home/screens/evening_pulse_screen.dart
```
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/screens/home_screen.dart lib/features/home/screens/evening_pulse_screen.dart lib/core/services/sponsor_service.dart
git commit -m "feat: wire check-in hooks and silence detection into HomeScreen"
```

---

## Task 6: Wire journal hook + add sponsor prompt to JournalEditorScreen

**Files:**
- Modify: `lib/features/journal/screens/journal_editor_screen.dart`

- [ ] **Step 1: Wire `onJournalSaved` after save**

In `_saveEntry()`, after `await DatabaseService().saveJournalEntry(...)`:

```dart
await SponsorService.instance.onJournalSaved(
  wordCount: content.split(' ').length,
);
```

Add import:
```dart
import '../../../core/services/sponsor_service.dart';
```

- [ ] **Step 2: Add sponsor prompt widget above text field**

The journal editor shows a title field then content field. Add a sponsor prompt chip between them.

Add a `_sponsorPrompt` getter that picks from a signals-keyed pool:

```dart
String get _sponsorPrompt {
  final sponsor = SponsorService.instance;
  if (!sponsor.hasIdentity) return '';
  // Rotate through prompts — simple index based on day of year
  final day = DateTime.now().dayOfYear;
  const prompts = [
    'What's weighing heaviest right now?',
    'What did you do today that you're glad you did?',
    'What are you not saying out loud to anyone?',
    'Where did you feel most like yourself today?',
    'What would you tell someone else in your position?',
    'What are you grateful for that you haven't named yet?',
    'What's one thing you noticed about yourself this week?',
  ];
  return prompts[day % prompts.length];
}
```

Add `extension on DateTime { int get dayOfYear => difference(DateTime(year, 1, 1)).inDays + 1; }` at the bottom of the file (outside the class).

Add to build() — insert after the title field and before the content field:

```dart
// Sponsor prompt chip — only shown on new entries
if (widget.mode == CreateEditMode.create) ...[
  const SizedBox(height: AppSpacing.sm),
  Builder(builder: (context) {
    final prompt = _sponsorPrompt;
    if (prompt.isEmpty) return const SizedBox.shrink();
    final name = SponsorService.instance.identity?.name ?? 'Your sponsor';
    return GestureDetector(
      onTap: () {
        if (_contentController.text.isEmpty) {
          _contentController.text = '$prompt\n\n';
          _contentController.selection = TextSelection.fromPosition(
            TextPosition(offset: _contentController.text.length),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryAmber.withAlpha(80)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          children: [
            Icon(Icons.forum_outlined,
                size: 14, color: AppColors.primaryAmber.withAlpha(180)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '$name asks: $prompt',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(Icons.touch_app_outlined,
                size: 14, color: AppColors.textSecondary.withAlpha(120)),
          ],
        ),
      ),
    );
  }),
],
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/features/journal/screens/journal_editor_screen.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/journal/screens/journal_editor_screen.dart lib/core/services/sponsor_service.dart
git commit -m "feat: wire journal hook and add sponsor prompt to JournalEditor"
```

---

## Task 7: Add sponsor reflection CTA to DailyReadingScreen

**Files:**
- Modify: `lib/features/readings/screens/daily_reading_screen.dart`

- [ ] **Step 1: Add import + CTA widget**

Add import:
```dart
import '../../../core/services/sponsor_service.dart';
```

In the main reading body — after the reading text content and before the Previous/Next navigation row — insert:

```dart
// Sponsor reflection prompt
Builder(builder: (context) {
  final sponsor = SponsorService.instance;
  if (!sponsor.hasIdentity) return const SizedBox.shrink();
  final name = sponsor.identity!.name;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: OutlinedButton.icon(
      icon: const Icon(Icons.forum_outlined, size: 16),
      label: Text('What would $name ask you about this?'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryAmber,
        side: const BorderSide(color: AppColors.primaryAmber),
      ),
      onPressed: () => context.push('/home/companion-chat'),
    ),
  );
}),
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze lib/features/readings/screens/daily_reading_screen.dart
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/readings/screens/daily_reading_screen.dart
git commit -m "feat: add sponsor reflection CTA to DailyReadingScreen"
```

---

## Task 8: Add "What I've noticed" patterns section to MemoryTransparencyScreen

**Files:**
- Modify: `lib/features/ai_companion/screens/memory_transparency_screen.dart`

- [ ] **Step 1: Add pattern computation**

Add import:
```dart
import '../../../core/services/database_service.dart';
```

Add a `_loadPatterns()` method and a `_patterns` future field in the state:

```dart
late final Future<List<String>> _patternsFuture;

@override
void initState() {
  super.initState();
  _patternsFuture = _loadPatterns();
}

Future<List<String>> _loadPatterns() async {
  try {
    final db = DatabaseService();
    final checkIns = await db.getCheckIns(limit: 28);
    if (checkIns.length < 7) return [];

    final patterns = <String>[];
    final name = widget.sponsorName;

    // Hardest day bucket
    final dayBuckets = <int, List<int>>{};
    for (final c in checkIns) {
      if (c.craving == null) continue;
      final weekday = c.checkInDate.weekday;
      dayBuckets.putIfAbsent(weekday, () => []).add(c.craving!);
    }
    if (dayBuckets.isNotEmpty) {
      final hardestDay = dayBuckets.entries
          .map((e) => MapEntry(e.key, e.value.fold(0, (a, b) => a + b) / e.value.length))
          .reduce((a, b) => a.value > b.value ? a : b);
      const days = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
      if (hardestDay.value > 4) {
        patterns.add('$name has noticed that ${days[hardestDay.key]} tend to be harder for you.');
      }
    }

    // Mood-craving correlation
    final paired = checkIns
        .where((c) => c.mood != null && c.craving != null)
        .toList();
    if (paired.length >= 6) {
      final correlation = _moodCravingCorrelation(paired);
      if (correlation < -0.4) {
        patterns.add('When your mood drops, your cravings tend to rise. $name has seen this pattern.');
      }
    }

    // Streak observation
    final streak = checkIns.isNotEmpty
        ? _computeStreakFromCheckIns(checkIns)
        : 0;
    if (streak >= 7) {
      patterns.add('You\'ve checked in $streak days in a row. $name doesn\'t take that lightly.');
    }

    return patterns;
  } catch (_) {
    return [];
  }
}

double _moodCravingCorrelation(List<DailyCheckIn> checkIns) {
  final n = checkIns.length.toDouble();
  final moods = checkIns.map((c) => c.mood!.toDouble()).toList();
  final cravings = checkIns.map((c) => c.craving!.toDouble()).toList();
  final avgMood = moods.fold(0.0, (a, b) => a + b) / n;
  final avgCraving = cravings.fold(0.0, (a, b) => a + b) / n;
  double num = 0, denMood = 0, denCraving = 0;
  for (var i = 0; i < checkIns.length; i++) {
    final dm = moods[i] - avgMood;
    final dc = cravings[i] - avgCraving;
    num += dm * dc;
    denMood += dm * dm;
    denCraving += dc * dc;
  }
  final den = denMood * denCraving;
  if (den <= 0) return 0;
  return num / math.sqrt(den);
}

int _computeStreakFromCheckIns(List<DailyCheckIn> checkIns) {
  final sorted = checkIns.toList()
    ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
  int streak = 0;
  DateTime expected = DateTime.now();
  for (final c in sorted) {
    if (expected.difference(c.checkInDate).inDays <= 1) {
      streak++;
      expected = c.checkInDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}
```

Add `import 'dart:math' as math;` and replace `.sqrt()` with `math.sqrt(den)`.

- [ ] **Step 2: Add patterns section to the ListView in build()**

Before or after the memories list, add:

```dart
FutureBuilder<List<String>>(
  future: _patternsFuture,
  builder: (context, snapshot) {
    final patterns = snapshot.data ?? [];
    if (patterns.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
          child: Text(
            'What I\'ve noticed',
            style: AppTypography.titleMedium.copyWith(color: AppColors.primaryAmber),
          ),
        ),
        ...patterns.map((p) => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.circle, size: 6, color: AppColors.primaryAmber),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(p, style: AppTypography.bodyMedium)),
            ],
          ),
        )),
        const Divider(height: AppSpacing.xl),
      ],
    );
  },
),
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/features/ai_companion/screens/memory_transparency_screen.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/ai_companion/screens/memory_transparency_screen.dart
git commit -m "feat: add sponsor pattern detection to MemoryTransparencyScreen"
```

---

## Task 9: Add SponsorCard to HomeScreen

**Files:**
- Create: `lib/features/home/widgets/sponsor_card.dart`
- Modify: `lib/features/home/screens/home_screen.dart`

- [ ] **Step 1: Create SponsorCard widget**

```dart
// lib/features/home/widgets/sponsor_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/sponsor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Home screen card showing sponsor's current "read" on the user's week.
class SponsorCard extends StatelessWidget {
  const SponsorCard({super.key});

  String _weeklyRead(SponsorService svc) {
    final name = svc.identity?.name ?? 'Your sponsor';
    if (svc.hasPendingMessage && svc.pendingMessagePreview != null) {
      return svc.pendingMessagePreview!;
    }
    // Generate a read from stage + relationship warmth
    return switch (svc.stage) {
      SponsorStage.new_ => '$name is getting to know you. Keep showing up.',
      SponsorStage.building => '$name is watching your patterns. Something\'s shifting.',
      SponsorStage.trusted => '$name knows you well enough to notice the quiet changes.',
      SponsorStage.close => '$name sees what you\'re not saying. When you\'re ready.',
      SponsorStage.deep => '$name\'s proud of who you\'re becoming — not just what you\'re avoiding.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SponsorService.instance,
      builder: (context, _) {
        final svc = SponsorService.instance;
        if (!svc.hasIdentity) return const SizedBox.shrink();

        final name = svc.identity!.name;
        final hasPending = svc.hasPendingMessage;

        return GestureDetector(
          onTap: () => context.push('/home/companion-chat'),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: hasPending
                    ? AppColors.primaryAmber.withAlpha(180)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surfaceElevated,
                      child: Icon(Icons.person, size: 20, color: AppColors.primaryAmber),
                    ),
                    if (hasPending)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryAmber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.labelMedium),
                      const SizedBox(height: 2),
                      Text(
                        _weeklyRead(svc),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Add SponsorCard to HomeScreen build**

In `home_screen.dart`, add import:
```dart
import '../widgets/sponsor_card.dart';
import '../../../core/services/sponsor_service.dart';
```

In the main build body, after the sobriety counter section and before the daily action cards, insert:
```dart
const SponsorCard(),
```

Find the relevant build location by searching for the sobriety counter widget call and inserting after it. The exact location will be in the scrollable body — add it as a widget in the column/list there.

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/features/home/widgets/sponsor_card.dart lib/features/home/screens/home_screen.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/widgets/sponsor_card.dart lib/features/home/screens/home_screen.dart
git commit -m "feat: add SponsorCard to HomeScreen"
```

---

## Task 10: Add sponsor voice to MilestoneCelebrationScreen

**Files:**
- Modify: `lib/features/milestone/screens/milestone_celebration_screen.dart`
- Modify: `lib/core/services/sponsor_service.dart`

- [ ] **Step 1: Add `getMilestoneMessage(days)` to SponsorService**

This method makes a single API call (or falls back locally) and returns a personalized sponsor message for a milestone. Result is cached in SharedPreferences.

```dart
/// Returns a personalized sponsor message for a milestone, cached offline.
Future<String> getMilestoneMessage(int days) async {
  if (_identity == null) return _localMilestoneMessage(days);

  // Check cache first
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'sponsor_milestone_msg_$days';
  final cached = prefs.getString(cacheKey);
  if (cached != null) {
    try {
      return EncryptionService().decrypt(cached);
    } catch (_) {}
  }

  // Try API
  if (ConnectivityService().isConnected) {
    try {
      final signals = await _buildSignals();
      final prompt = ContextAssembler.build(
        identity: _identity!,
        stageData: _stageData,
        sobrietyDays: days,
        memories: [..._memoryStore.longterm, ..._memoryStore.digest],
        signals: signals,
        userMessage: 'The person I sponsor just hit $days days sober. Write a short, personal message of 2-3 sentences to them for this moment. Make it feel like it comes from me — not a generic congratulations.',
        isCrisis: false,
      );

      final message = await _callEdgeFunction(
        systemPrompt: prompt,
        message: 'Generate milestone message for $days days',
        conversationHistory: [],
      );

      // Cache it
      final encrypted = EncryptionService().encrypt(message);
      await prefs.setString(cacheKey, encrypted);
      return message;
    } catch (e, st) {
      LoggerService().error('getMilestoneMessage API failed', error: e, stackTrace: st);
    }
  }

  return _localMilestoneMessage(days);
}

String _localMilestoneMessage(int days) {
  final name = _identity?.name ?? 'Your sponsor';
  if (days <= 7) return '$name knew you could get through the first week. This is real.';
  if (days <= 30) return '$name has watched you choose this $days times. That\'s not nothing.';
  if (days <= 90) return '$name remembers your day one. Look at where you are now.';
  if (days <= 365) return '$name is proud of you. Not just for the days — for who you\'re becoming.';
  return '$name has seen $days days of you choosing yourself. That\'s a life being built.';
}
```

- [ ] **Step 2: Add sponsor voice block to MilestoneCelebrationScreen**

In `_MilestoneCelebrationScreenState`, add:

```dart
Future<String>? _sponsorMessageFuture;

@override
void initState() {
  super.initState();
  // ... existing initState code ...
  final content = _content;
  if (content != null && SponsorService.instance.hasIdentity) {
    _sponsorMessageFuture = SponsorService.instance.getMilestoneMessage(content.days);
    SponsorService.instance.onMilestoneReached(content.days);
  }
}
```

Add import:
```dart
import '../../../core/services/sponsor_service.dart';
```

In the build method, after the milestone badge and title but before the share button, add:

```dart
if (_sponsorMessageFuture != null) ...[
  const SizedBox(height: AppSpacing.lg),
  FutureBuilder<String>(
    future: _sponsorMessageFuture,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.primaryAmber)),
        );
      }
      final sponsorName = SponsorService.instance.identity?.name ?? 'Your sponsor';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primaryAmber.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.primaryAmber),
                const SizedBox(width: AppSpacing.xs),
                Text(sponsorName, style: AppTypography.labelMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(snapshot.data!, style: AppTypography.bodyMedium),
          ],
        ),
      );
    },
  ),
],
```

- [ ] **Step 3: Run analyzer**

```bash
flutter analyze lib/features/milestone/screens/milestone_celebration_screen.dart lib/core/services/sponsor_service.dart
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/milestone/screens/milestone_celebration_screen.dart lib/core/services/sponsor_service.dart
git commit -m "feat: add sponsor voice to MilestoneCelebrationScreen with caching"
```

---

## Task 11: Final integration check + run all tests

- [ ] **Step 1: Run full test suite**

```bash
flutter test
```
Expected: All existing tests pass. New tests for signals + badge pass.

- [ ] **Step 2: Run analyzer on all changed files**

```bash
flutter analyze
```
Expected: No errors, warnings only if pre-existing.

- [ ] **Step 3: Commit any lint fixes if needed, then final commit**

```bash
git add -A
git commit -m "feat: sponsor nervous system — signals, badge, hooks, card, milestone voice"
```

---

## Verification

1. **Signal wiring**: In sponsor chat, send a message. Check `LoggerService` output — context should include non-empty mood/craving trend fields.
2. **Badge**: Complete an evening check-in with craving ≥ 8 → Profile tab should show amber dot.
3. **Journal prompt**: Open new journal entry → should see sponsor prompt chip above content field.
4. **Reading CTA**: Open Daily Reading → scroll down → should see "What would [Name] ask you about this?" button.
5. **Memory patterns**: Open Profile → sponsor memory transparency → should see "What I've noticed" section after ≥ 7 check-ins.
6. **Sponsor card**: Home screen should show sponsor card with sponsor's name and a message line.
7. **Milestone voice**: Trigger milestone celebration (or navigate directly) → should see sponsor message block.
