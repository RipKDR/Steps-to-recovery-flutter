# Viral Loop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn genuine recovery milestones into shareable moments that drive app word-of-mouth — full-screen celebration, PNG share card, approach notifications, profile invite tile, and challenge share button.

**Architecture:** `MilestoneService` singleton gates celebration visibility and schedules approach notifications. `MilestoneCelebrationScreen` is a `showGeneralDialog` modal (not a route) triggered post-frame from `HomeScreen` after snapshot load. `MilestoneShareCard` is an off-screen `RepaintBoundary` widget captured to PNG via `RenderRepaintBoundary.toImage()`.

**Tech Stack:** Flutter 3.41.5 / Dart 3.11.3 · `share_plus` 10.1.4 (`SharePlus.instance.share(ShareParams(...))`) · `path_provider` · `flutter_local_notifications` (via existing `NotificationService.scheduleNotification`) · existing `ConfettiController` / `ConfettiOverlay`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `lib/core/services/milestone_service.dart` | Celebration gating + approach notification scheduling |
| Create | `lib/features/milestone/screens/milestone_celebration_screen.dart` | Full-screen modal with confetti, animated counter, share flow |
| Create | `lib/features/milestone/widgets/milestone_badge.dart` | Reusable emoji + amber ring badge |
| Create | `lib/features/milestone/widgets/milestone_share_card.dart` | Off-screen capturable PNG card |
| Create | `test/milestone_service_test.dart` | Unit tests for MilestoneService |
| Create | `test/milestone_celebration_screen_test.dart` | Widget tests for celebration screen |
| Modify | `lib/core/services/preferences_service.dart` | Add `hasMilestoneCelebrationShown` + `markMilestoneCelebrationShown` |
| Modify | `lib/core/services/notification_service.dart` | Add `scheduleMilestoneApproachReminder` + `cancelMilestoneApproachReminders` |
| Modify | `lib/core/services/app_state_service.dart` | Call `MilestoneService().checkAndScheduleApproachNotifications()` in `initialize()` and `updateSobrietyDate()` |
| Modify | `lib/core/constants/app_constants.dart` | Add `AppStoreLinks` + `NotificationIds.milestoneApproachBase` |
| Modify | `lib/features/home/screens/home_screen.dart` | Trigger celebration dialog post-frame; upgrade `_shareMilestone` to share PNG |
| Modify | `lib/features/profile/screens/profile_screen.dart` | Add "Invite Someone to Recovery" tile |
| Modify | `lib/features/challenges/screens/challenges_screen.dart` | Add share `IconButton` on active challenge cards |
| Test | `test/preferences_service_test.dart` | Add tests for the two new methods |

---

## Task 1: Celebration Gate — `preferences_service.dart`

**Files:**
- Modify: `lib/core/services/preferences_service.dart`
- Test: `test/preferences_service_test.dart`

- [ ] **Step 1.1: Write failing tests**

Add to the existing `PreferencesService` group in `test/preferences_service_test.dart`:

```dart
group('milestone celebration gate', () {
  test('hasMilestoneCelebrationShown returns false by default', () async {
    final svc = await _freshService();
    final shown = await svc.hasMilestoneCelebrationShown('milestone_7');
    expect(shown, isFalse);
  });

  test('markMilestoneCelebrationShown persists across reads', () async {
    final svc = await _freshService();
    await svc.markMilestoneCelebrationShown('milestone_7');
    expect(await svc.hasMilestoneCelebrationShown('milestone_7'), isTrue);
  });

  test('different keys are independent', () async {
    final svc = await _freshService();
    await svc.markMilestoneCelebrationShown('milestone_7');
    expect(await svc.hasMilestoneCelebrationShown('milestone_30'), isFalse);
  });
});
```

- [ ] **Step 1.2: Run tests to verify they fail**

```
flutter test test/preferences_service_test.dart --name "milestone celebration gate" -v
```

Expected: FAIL — method not found on PreferencesService.

- [ ] **Step 1.3: Add methods to `preferences_service.dart`**

Add after the existing biometric methods (around line 54):

```dart
// Milestone celebration gate
Future<bool> hasMilestoneCelebrationShown(String achievementKey) async {
  await initialize();
  return _prefs?.getBool('celebration_shown_$achievementKey') ?? false;
}

Future<void> markMilestoneCelebrationShown(String achievementKey) async {
  await initialize();
  await _prefs?.setBool('celebration_shown_$achievementKey', true);
}
```

- [ ] **Step 1.4: Run tests to verify they pass**

```
flutter test test/preferences_service_test.dart -v
```

Expected: All PASS (including existing tests).

- [ ] **Step 1.5: Commit**

```bash
git add lib/core/services/preferences_service.dart test/preferences_service_test.dart
git commit -m "feat: add milestone celebration gate to PreferencesService"
```

---

## Task 2: App Store Links + Notification IDs — `app_constants.dart`

**Files:**
- Modify: `lib/core/constants/app_constants.dart`

- [ ] **Step 2.1: Add `AppStoreLinks` and `NotificationIds` constants**

Open `lib/core/constants/app_constants.dart`. After the closing `}` of `AppConstants`, add:

```dart
abstract final class AppStoreLinks {
  static const String appStore =
      'https://apps.apple.com/app/steps-to-recovery/idXXXXXXXXX';
  static const String playStore =
      'https://play.google.com/store/apps/details?id=com.stepstorecovery.app';
  static const String shareUrl = 'https://stepstorecovery.app';
}

abstract final class NotificationIds {
  // Daily check-in reminders use IDs < 1000
  static const int milestoneApproachBase = 2000;
  // 2001 = 7-day approach, 2002 = 30-day, 2003 = 90-day, 2004 = 1-year
}
```

- [ ] **Step 2.2: Verify no analysis errors**

```
flutter analyze lib/core/constants/app_constants.dart
```

Expected: No issues found.

- [ ] **Step 2.3: Commit**

```bash
git add lib/core/constants/app_constants.dart
git commit -m "feat: add AppStoreLinks and NotificationIds.milestoneApproachBase constants"
```

---

## Task 3: Approach Notification Methods — `notification_service.dart`

**Files:**
- Modify: `lib/core/services/notification_service.dart`
- Test: `test/notification_service_test.dart`

- [ ] **Step 3.1: Write failing tests**

Add to `test/notification_service_test.dart` inside the main `NotificationService` group:

```dart
group('scheduleMilestoneApproachReminder', () {
  test('schedules notification when trigger date is in the future', () async {
    final svc = makeService();
    final future = DateTime.now().add(const Duration(days: 5));
    await svc.scheduleMilestoneApproachReminder(
      id: 2001,
      milestoneTitle: '1 Week',
      milestoneDate: future.add(const Duration(days: 5)),
    );
    // Verify zonedSchedule was called once
    expect(plugin.zonedScheduleCalls, equals(1));
  });

  test('skips scheduling when trigger date is in the past', () async {
    final svc = makeService();
    final past = DateTime.now().subtract(const Duration(days: 10));
    await svc.scheduleMilestoneApproachReminder(
      id: 2001,
      milestoneTitle: '1 Week',
      milestoneDate: past,
    );
    expect(plugin.zonedScheduleCalls, equals(0));
  });
});

group('cancelMilestoneApproachReminders', () {
  test('cancels IDs 2001 through 2004', () async {
    final svc = makeService();
    await svc.cancelMilestoneApproachReminders();
    expect(plugin.cancelledIds, containsAll([2001, 2002, 2003, 2004]));
  });
});
```

> Note: Check how the existing test file exposes `plugin.zonedScheduleCalls` and `plugin.cancelledIds` — use the same mock pattern already established there.

- [ ] **Step 3.2: Run tests to verify they fail**

```
flutter test test/notification_service_test.dart --name "scheduleMilestoneApproachReminder|cancelMilestoneApproachReminders" -v
```

Expected: FAIL — methods not found.

- [ ] **Step 3.3: Add methods to `notification_service.dart`**

Find `scheduleNotification` and add after it:

```dart
/// Schedule a "5 days to milestone" approach reminder.
/// No-ops if the trigger date is already in the past.
Future<void> scheduleMilestoneApproachReminder({
  required int id,
  required String milestoneTitle,
  required DateTime milestoneDate,
  int daysWarning = 5,
}) async {
  final triggerDate = milestoneDate.subtract(Duration(days: daysWarning));
  if (triggerDate.isBefore(DateTime.now())) return;
  await scheduleNotification(
    id: id,
    title: '$daysWarning days to your $milestoneTitle milestone!',
    body: "Keep going. You're almost there.",
    scheduledDate: triggerDate,
  );
}

/// Cancel the four milestone approach reminder IDs (2001–2004).
Future<void> cancelMilestoneApproachReminders() async {
  for (int i = 2001; i <= 2004; i++) {
    await _notifications.cancel(id: i);
  }
}
```

- [ ] **Step 3.4: Run tests to verify they pass**

```
flutter test test/notification_service_test.dart -v
```

Expected: All PASS.

- [ ] **Step 3.5: Commit**

```bash
git add lib/core/services/notification_service.dart test/notification_service_test.dart
git commit -m "feat: add scheduleMilestoneApproachReminder and cancelMilestoneApproachReminders to NotificationService"
```

---

## Task 4: `MilestoneService` Singleton

**Files:**
- Create: `lib/core/services/milestone_service.dart`
- Create: `test/milestone_service_test.dart`

- [ ] **Step 4.1: Write failing tests**

Create `test/milestone_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/milestone_service.dart';
import 'package:steps_recovery_flutter/core/services/preferences_service.dart';

import 'test_helpers.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PreferencesService().resetForTest();
  });

  group('MilestoneService.shouldShowCelebration', () {
    Achievement _makeAchievement(String key) => Achievement(
          id: key,
          userId: 'u1',
          achievementKey: key,
          type: AchievementType.timeMilestone,
          earnedAt: DateTime.now(),
        );

    test('returns null when list is empty', () async {
      final result = await MilestoneService().shouldShowCelebration([]);
      expect(result, isNull);
    });

    test('returns first achievement when none have been shown', () async {
      final a = _makeAchievement('milestone_7');
      final result = await MilestoneService().shouldShowCelebration([a]);
      expect(result, equals(a));
    });

    test('skips achievement that was already shown', () async {
      final prefs = PreferencesService();
      await prefs.initialize();
      await prefs.markMilestoneCelebrationShown('milestone_7');

      final a = _makeAchievement('milestone_7');
      final b = _makeAchievement('milestone_30');
      final result = await MilestoneService().shouldShowCelebration([a, b]);
      expect(result, equals(b));
    });

    test('returns null when all achievements have been shown', () async {
      final prefs = PreferencesService();
      await prefs.initialize();
      await prefs.markMilestoneCelebrationShown('milestone_7');

      final a = _makeAchievement('milestone_7');
      final result = await MilestoneService().shouldShowCelebration([a]);
      expect(result, isNull);
    });
  });
}
```

- [ ] **Step 4.2: Run tests to verify they fail**

```
flutter test test/milestone_service_test.dart -v
```

Expected: FAIL — MilestoneService not found.

- [ ] **Step 4.3: Create `lib/core/services/milestone_service.dart`**

```dart
import '../constants/app_constants.dart';
import '../constants/recovery_content.dart';
import '../models/database_models.dart';
import 'notification_service.dart';
import 'preferences_service.dart';

/// Milestone notification ID map: sobriety days → (notif id, display title)
const _milestoneNotifMap = {
  7:   (id: 2001, title: '1 Week'),
  30:  (id: 2002, title: '1 Month'),
  90:  (id: 2003, title: '90 Days'),
  365: (id: 2004, title: '1 Year'),
};

class MilestoneService {
  static final MilestoneService _instance = MilestoneService._();
  factory MilestoneService() => _instance;
  MilestoneService._();

  /// Cancels stale approach reminders, then re-schedules for all future
  /// milestones relative to [sobrietyStart].
  Future<void> checkAndScheduleApproachNotifications(
    DateTime sobrietyStart,
  ) async {
    await NotificationService().cancelMilestoneApproachReminders();
    for (final entry in _milestoneNotifMap.entries) {
      final milestoneDate = sobrietyStart.add(Duration(days: entry.key));
      await NotificationService().scheduleMilestoneApproachReminder(
        id: entry.value.id,
        milestoneTitle: entry.value.title,
        milestoneDate: milestoneDate,
      );
    }
  }

  /// Returns the first achievement in [unviewedAchievements] whose celebration
  /// has not yet been shown to the user.
  Future<Achievement?> shouldShowCelebration(
    List<Achievement> unviewedAchievements,
  ) async {
    final prefs = PreferencesService();
    for (final achievement in unviewedAchievements) {
      final shown =
          await prefs.hasMilestoneCelebrationShown(achievement.achievementKey);
      if (!shown) return achievement;
    }
    return null;
  }
}
```

- [ ] **Step 4.4: Run tests to verify they pass**

```
flutter test test/milestone_service_test.dart -v
```

Expected: All PASS.

- [ ] **Step 4.5: Commit**

```bash
git add lib/core/services/milestone_service.dart test/milestone_service_test.dart
git commit -m "feat: add MilestoneService with celebration gating and approach notification scheduling"
```

---

## Task 5: Wire `MilestoneService` into `AppStateService`

**Files:**
- Modify: `lib/core/services/app_state_service.dart`

- [ ] **Step 5.1: Add import and calls**

At the top of `app_state_service.dart`, add:

```dart
import 'milestone_service.dart';
```

In `initialize()`, after `_sobrietyDate` is loaded (find the line where `_sobrietyDate` is set from prefs) add:

```dart
if (_sobrietyDate != null) {
  unawaited(
    MilestoneService().checkAndScheduleApproachNotifications(_sobrietyDate!),
  );
}
```

In `updateSobrietyDate()`, after the date is persisted (after `await _prefs?.setString(...)`) add:

```dart
if (value != null) {
  unawaited(
    MilestoneService().checkAndScheduleApproachNotifications(value),
  );
}
```

> `unawaited` prevents blocking state restoration; import `dart:async` if not already present.

- [ ] **Step 5.2: Verify no analysis errors**

```
flutter analyze lib/core/services/app_state_service.dart
```

Expected: No issues found.

- [ ] **Step 5.3: Commit**

```bash
git add lib/core/services/app_state_service.dart
git commit -m "feat: wire MilestoneService approach notifications into AppStateService initialize and updateSobrietyDate"
```

---

## Task 6: `MilestoneBadge` Widget

**Files:**
- Create: `lib/features/milestone/widgets/milestone_badge.dart`

- [ ] **Step 6.1: Create the widget**

```dart
import 'package:flutter/material.dart';

/// Amber gradient ring badge displaying a milestone [emoji].
class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({super.key, required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
            ),
          ),
        ),
        Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF121212),
          ),
        ),
        Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ],
    );
  }
}
```

- [ ] **Step 6.2: Verify no analysis errors**

```
flutter analyze lib/features/milestone/widgets/milestone_badge.dart
```

Expected: No issues found.

- [ ] **Step 6.3: Commit**

```bash
git add lib/features/milestone/widgets/milestone_badge.dart
git commit -m "feat: add MilestoneBadge widget with amber gradient ring"
```

---

## Task 7: `MilestoneShareCard` Widget

**Files:**
- Create: `lib/features/milestone/widgets/milestone_share_card.dart`

- [ ] **Step 7.1: Create the widget**

```dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import 'milestone_badge.dart';

class MilestoneShareCard extends StatelessWidget {
  const MilestoneShareCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.message,
  });

  final String emoji;
  final String title;
  final String message;

  /// Capture the widget identified by [repaintKey] as a PNG [XFile].
  /// Returns null if the RenderObject is not ready.
  static Future<XFile?> capture(GlobalKey repaintKey) async {
    final boundary = repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    final bytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/milestone_share.png');
    await file.writeAsBytes(bytes);
    return XFile(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121212), Color(0xFF1A1200)],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Steps to Recovery',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          Column(
            children: [
              MilestoneBadge(emoji: emoji, size: 120),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'One day at a time.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStoreLinks.shareUrl,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7.2: Verify no analysis errors**

```
flutter analyze lib/features/milestone/widgets/milestone_share_card.dart
```

Expected: No issues found.

- [ ] **Step 7.3: Commit**

```bash
git add lib/features/milestone/widgets/milestone_share_card.dart
git commit -m "feat: add MilestoneShareCard widget with RepaintBoundary capture"
```

---

## Task 8: `MilestoneCelebrationScreen`

**Files:**
- Create: `lib/features/milestone/screens/milestone_celebration_screen.dart`
- Create: `test/milestone_celebration_screen_test.dart`

> This is the largest task. Read `lib/core/constants/recovery_content.dart` lines 39–313 to understand `TimeMilestoneContent` fields (`emoji`, `title`, `message`, `days`) before implementing.

- [ ] **Step 8.1: Write failing widget tests**

Create `test/milestone_celebration_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/features/milestone/screens/milestone_celebration_screen.dart';

import 'test_helpers.dart';

Achievement _makeAchievement(String key) => Achievement(
      id: key,
      userId: 'u1',
      achievementKey: key,
      type: AchievementType.timeMilestone,
      earnedAt: DateTime.now(),
    );

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shows milestone title and continue button', (tester) async {
    await createSignedInUser(sobrietyDate: DateTime.now().subtract(const Duration(days: 7)));

    await tester.pumpWidget(MaterialApp(
      home: MilestoneCelebrationScreen(
        achievement: _makeAchievement('milestone_7'),
      ),
    ));
    await tester.pump();

    expect(find.textContaining('1 Week'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('continue button dismisses the dialog', (tester) async {
    await createSignedInUser(sobrietyDate: DateTime.now().subtract(const Duration(days: 7)));

    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (ctx) => ElevatedButton(
        onPressed: () async {
          await showGeneralDialog(
            context: ctx,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            pageBuilder: (c, _, __) => MilestoneCelebrationScreen(
              achievement: _makeAchievement('milestone_7'),
            ),
          );
          dismissed = true;
        },
        child: const Text('open'),
      )),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });
}
```

- [ ] **Step 8.2: Run tests to verify they fail**

```
flutter test test/milestone_celebration_screen_test.dart -v
```

Expected: FAIL — `MilestoneCelebrationScreen` not found.

- [ ] **Step 8.3: Look up `TimeMilestoneContent` fields**

Read `lib/core/constants/recovery_content.dart` lines 1–60 to confirm field names.

- [ ] **Step 8.4: Create `milestone_celebration_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/recovery_content.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../widgets/confetti_overlay.dart';
import '../widgets/milestone_badge.dart';
import '../widgets/milestone_share_card.dart';

class MilestoneCelebrationScreen extends StatefulWidget {
  const MilestoneCelebrationScreen({super.key, required this.achievement});

  final Achievement achievement;

  @override
  State<MilestoneCelebrationScreen> createState() =>
      _MilestoneCelebrationScreenState();
}

class _MilestoneCelebrationScreenState
    extends State<MilestoneCelebrationScreen> {
  final _confettiController = ConfettiController();
  final _repaintKey = GlobalKey();
  bool _sharing = false;

  TimeMilestoneContent? get _content =>
      RecoveryContent.timeMilestones.firstWhereOrNull(
        (m) => 'milestone_${m.days}' == widget.achievement.achievementKey,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confettiController.fire();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onShare() async {
    setState(() => _sharing = true);
    try {
      // Wait one frame so Offstage widget is laid out
      await Future.delayed(Duration.zero);
      final xFile = await MilestoneShareCard.capture(_repaintKey);
      final content = _content;
      if (xFile != null) {
        await SharePlus.instance.share(ShareParams(
          files: [xFile],
          subject: 'My Recovery Milestone',
          text: content != null
              ? '${content.title} sober! ${AppStoreLinks.shareUrl}'
              : AppStoreLinks.shareUrl,
        ));
      } else {
        await SharePlus.instance.share(ShareParams(
          text: content != null
              ? '${content.title} sober! ${AppStoreLinks.shareUrl}'
              : AppStoreLinks.shareUrl,
        ));
      }
      LoggerService().info(
        'event=milestone_card_shared achievementKey=${widget.achievement.achievementKey}',
      );
    } catch (e) {
      LoggerService().warning('milestone share failed: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _onDismiss() async {
    await PreferencesService()
        .markMilestoneCelebrationShown(widget.achievement.achievementKey);
    await DatabaseService().markAchievementViewed(widget.achievement.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final emoji = content?.emoji ?? '🎉';
    final title = content?.title ?? 'Milestone';
    final message = content?.message ?? 'Keep going.';

    return ConfettiOverlay(
      controller: _confettiController,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Stack(
            children: [
              // Off-screen share card (Offstage keeps it in layout tree for capture)
              Offstage(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: MilestoneShareCard(
                    emoji: emoji,
                    title: title,
                    message: message,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MilestoneBadge(emoji: emoji, size: 100),
                      const SizedBox(height: 24),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: content?.days ?? 0),
                        duration: const Duration(seconds: 2),
                        builder: (_, value, __) => Text(
                          '$value',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: const Color(0xFFF59E0B)),
                        ),
                      ),
                      Text(
                        'days sober',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _sharing ? null : _onShare,
                            icon: _sharing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.share_outlined),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: _onDismiss,
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
```

> **Important:** Read `lib/core/constants/recovery_content.dart` to verify:
> - The class/list name (e.g. `RecoveryContent.timeMilestones` or `TimeMilestoneContent.milestones`)
> - The `days` field name and `emoji`, `title`, `message` fields
> - Adjust imports/calls accordingly. The `_content` getter must use the correct accessor.

- [ ] **Step 8.5: Run tests to verify they pass**

```
flutter test test/milestone_celebration_screen_test.dart -v
```

Expected: PASS.

- [ ] **Step 8.6: Run full test suite to check regressions**

```
flutter test
```

Expected: All passing (or same failures as before).

- [ ] **Step 8.7: Commit**

```bash
git add lib/features/milestone/ test/milestone_celebration_screen_test.dart
git commit -m "feat: add MilestoneCelebrationScreen with confetti, animated counter, share flow"
```

---

## Task 9: Wire Celebration Trigger in `home_screen.dart`

**Files:**
- Modify: `lib/features/home/screens/home_screen.dart`

> Read the current `home_screen.dart` before editing. Key landmarks:
> - `_loadSnapshot()` at line 157 — where `unreadShareableMilestones` is built
> - `initState()` where `_snapshotFuture` is assigned
> - `_shareMilestone()` — upgrade to share PNG

- [ ] **Step 9.1: Add celebration trigger after snapshot loads**

In `initState()`, after `_snapshotFuture = _loadSnapshot();`, add:

```dart
_snapshotFuture.then((data) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;
    final achievement = await MilestoneService().shouldShowCelebration(
      data.unreadShareableMilestones,
    );
    if (achievement != null && mounted) {
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (ctx, _, __) =>
            MilestoneCelebrationScreen(achievement: achievement),
      );
    }
  });
});
```

Add the required imports at the top:

```dart
import '../../milestone/screens/milestone_celebration_screen.dart';
import '../../../core/services/milestone_service.dart';
```

- [ ] **Step 9.2: Upgrade `_shareMilestone` to share PNG image**

Find `_shareMilestone()`. It currently builds share text. Replace the `SharePlus.instance.share(...)` call to first attempt PNG capture:

```dart
// Build a temporary off-screen share card to capture
final repaintKey = GlobalKey();
// NOTE: The existing share button shares text today.
// Full PNG upgrade requires embedding MilestoneShareCard offscreen here.
// For now, keep text share; celebration screen handles PNG.
// This upgrade can be deferred to a follow-up.
```

> Keep the existing text share behavior in `_shareMilestone()` for now — the celebration screen handles PNG sharing. Mark with a TODO comment to unify later.

- [ ] **Step 9.3: Verify no analysis errors**

```
flutter analyze lib/features/home/screens/home_screen.dart
```

Expected: No issues found.

- [ ] **Step 9.4: Run home screen tests**

```
flutter test test/home_milestone_share_test.dart -v
```

Expected: All PASS.

- [ ] **Step 9.5: Commit**

```bash
git add lib/features/home/screens/home_screen.dart
git commit -m "feat: trigger MilestoneCelebrationScreen post-frame from HomeScreen"
```

---

## Task 10: Profile Screen — Invite Tile

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart`

> Read `profile_screen.dart` before editing. Find the "Support" section — it contains a `_SettingsSection` with `_SettingsTile` children.

- [ ] **Step 10.1: Add import for share_plus and app_constants**

```dart
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
```

- [ ] **Step 10.2: Add invite tile to the Support section**

Inside the Support `_SettingsSection`'s children list, add:

```dart
_SettingsTile(
  icon: Icons.group_add_outlined,
  title: 'Invite Someone to Recovery',
  subtitle: 'Share the app with someone who might need it',
  onTap: () async {
    await SharePlus.instance.share(ShareParams(
      text: "I use Steps to Recovery to stay accountable in my sobriety. "
          "It's private, works offline, and completely free. "
          "${AppStoreLinks.shareUrl}",
      subject: 'A recovery app worth trying',
    ));
  },
),
```

- [ ] **Step 10.3: Verify no analysis errors**

```
flutter analyze lib/features/profile/screens/profile_screen.dart
```

Expected: No issues found.

- [ ] **Step 10.4: Commit**

```bash
git add lib/features/profile/screens/profile_screen.dart
git commit -m "feat: add Invite Someone to Recovery tile to profile support section"
```

---

## Task 11: Challenges Screen — Share Button on Active Cards

**Files:**
- Modify: `lib/features/challenges/screens/challenges_screen.dart`

> Read `challenges_screen.dart` before editing. Find where active challenge cards are built — look for a `ListView`/`Column` rendering active challenges with their title and duration.

- [ ] **Step 11.1: Add share button to active challenge cards**

In the widget building each active challenge card, add a trailing `IconButton`:

```dart
IconButton(
  icon: const Icon(Icons.share_outlined),
  tooltip: 'Share this challenge',
  onPressed: () async {
    final shareText =
        "I'm doing a ${challenge.durationDays}-day ${challenge.title} "
        "challenge in my recovery. One day at a time. "
        "${AppStoreLinks.shareUrl}";
    await SharePlus.instance.share(ShareParams(
      text: shareText,
      subject: 'Recovery Challenge',
    ));
  },
),
```

> Adjust field names (`challenge.durationDays`, `challenge.title`) to match what the challenges model actually exposes — read the model before wiring.

- [ ] **Step 11.2: Add required imports**

```dart
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
```

- [ ] **Step 11.3: Verify no analysis errors**

```
flutter analyze lib/features/challenges/screens/challenges_screen.dart
```

Expected: No issues found.

- [ ] **Step 11.4: Commit**

```bash
git add lib/features/challenges/screens/challenges_screen.dart
git commit -m "feat: add share button to active challenge cards"
```

---

## Task 12: Final Verification

- [ ] **Step 12.1: Run full test suite**

```
flutter test
```

Expected: All existing tests pass + new tests pass.

- [ ] **Step 12.2: Run analyzer on all modified files**

```
flutter analyze
```

Expected: No issues found.

- [ ] **Step 12.3: Manual smoke test — Celebration Screen**

```
# In DevTools or debug build: set sobriety date 30 days ago in profile, restart app
# Home screen should show MilestoneCelebrationScreen
# Tap Continue → dialog dismisses, does not reappear on next restart
# Tap Share → OS share sheet appears
```

- [ ] **Step 12.4: Manual smoke test — Notifications**

```
# Set sobriety date 25 days ago → 30-day milestone in 5 days
# Check scheduled notifications via flutter_local_notifications pending list
# Expected: notification ID 2002 scheduled for sobriety_start + 25 days
```

- [ ] **Step 12.5: Final commit**

```bash
git add .
git commit -m "chore: viral loop implementation complete — celebration, share card, notifications, invite, challenge share"
```

---

## Privacy Audit

| Feature | Status |
|---------|--------|
| Celebration screen | Fully local — no network |
| Share card PNG | On-device capture; temp file; contains only milestone title + branding — no username/PII |
| Approach notifications | Local only — no network call |
| Invite to Recovery | Opt-in text share — no tracking |
| Challenge share | Opt-in text share — no tracking |

All features: offline-first ✅ · privacy-first ✅ · opt-in ✅ · no external SDKs ✅
