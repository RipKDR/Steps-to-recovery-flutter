# Viral Feature Loop — Implementation Plan
**Branch**: `codex/add-viral-feature-loop`
**Date**: 2026-03-22

---

## Goal

Strengthen the app's word-of-mouth growth by turning genuine recovery milestones into beautiful, shareable moments. The loop:

**User achieves milestone → Full-screen celebration → Beautiful image card shared → Friend downloads → Friend achieves → Shares → Repeat**

All mechanics are opt-in, offline-capable, and privacy-safe.

---

## What Already Exists (Don't Rebuild)

| Asset | Location |
|---|---|
| `ConfettiController` + `ConfettiOverlay` | `lib/widgets/confetti_overlay.dart` |
| `TimeMilestoneContent` with emoji, title, message, days | `lib/core/constants/recovery_content.dart` (lines 39–313) |
| `achievement_share_utils.dart` with `isShareableMilestoneAchievement`, `milestoneShareContentForAchievement` | `lib/core/utils/achievement_share_utils.dart` |
| `share_plus` 10.1.4 — `SharePlus.instance.share(ShareParams(files: [xFile]))` | `pubspec.yaml` |
| `path_provider` — `getTemporaryDirectory()` | `pubspec.yaml` |
| `Achievement`, `AchievementType`, `AchievementKeys` | `lib/core/models/database_models.dart`, `lib/core/constants/app_constants.dart` |
| `NotificationService.scheduleNotification(id, title, body, scheduledDate)` | `lib/core/services/notification_service.dart` |

---

## Priority-Ordered Feature List

| # | Feature | Impact | Effort |
|---|---|---|---|
| 1 | **Milestone Celebration Screen** | Highest — emotionally resonant, gates sharing | Medium |
| 2 | **Visual Share Card** (image, not text) | High — shareable image > text in chats/social | Medium |
| 3 | **Milestone Approach Notifications** | High — drives return behavior at key moments | Low |
| 4 | **Invite to Recovery** (profile) | Medium — low-friction app referral | Low |
| 5 | **Challenge Share** | Low-Medium — quick win, extends sharing surface | Low |

---

## Files to Create

```
lib/features/milestone/
  screens/
    milestone_celebration_screen.dart   # Full-screen dialog (showGeneralDialog)
  widgets/
    milestone_badge.dart                # Emoji + ring widget (shared between screens)
    milestone_share_card.dart           # Off-screen widget captured to PNG via RepaintBoundary

lib/core/services/
    milestone_service.dart              # Singleton: celebration gating + approach notification scheduling
```

---

## Files to Modify

| File | Change |
|---|---|
| `lib/core/services/preferences_service.dart` | Add `hasMilestoneCelebrationShown(key)` / `markMilestoneCelebrationShown(key)` |
| `lib/core/services/notification_service.dart` | Add `scheduleMilestoneApproachReminder()` + `cancelMilestoneApproachReminders()` |
| `lib/core/services/app_state_service.dart` | Call `MilestoneService().checkAndScheduleApproachNotifications()` on `initialize()` and `updateSobrietyDate()` |
| `lib/core/constants/app_constants.dart` | Add `AppStoreLinks` class (App Store, Play Store, share URL) |
| `lib/features/home/screens/home_screen.dart` | Show celebration dialog post-frame on `_loadSnapshot`; upgrade existing share button to use image card |
| `lib/features/profile/screens/profile_screen.dart` | Add "Invite Someone to Recovery" tile to Support section |
| `lib/features/challenges/screens/challenges_screen.dart` | Add share `IconButton` to active challenge cards |

---

## Implementation Steps (Ordered)

### Step 1 — `preferences_service.dart`: Celebration Gate

Add two methods to prevent re-showing the celebration:

```dart
Future<bool> hasMilestoneCelebrationShown(String achievementKey) async {
  return _prefs.getBool('celebration_shown_$achievementKey') ?? false;
}

Future<void> markMilestoneCelebrationShown(String achievementKey) async {
  await _prefs.setBool('celebration_shown_$achievementKey', true);
}
```

### Step 2 — `app_constants.dart`: App Store Links

```dart
abstract final class AppStoreLinks {
  static const String appStore = 'https://apps.apple.com/app/steps-to-recovery/idXXXXXXXXX';
  static const String playStore = 'https://play.google.com/store/apps/details?id=com.stepstorecovery.app';
  static const String shareUrl = 'https://stepstorecovery.app';
}
```

Also add notification ID constants:
```dart
// In NotificationIds (or existing constant class):
static const int milestoneApproachBase = 2000;
// 2001 = approach to 7d, 2002 = 30d, 2003 = 90d, 2004 = 1y
```

### Step 3 — `notification_service.dart`: Approach Reminder

```dart
Future<void> scheduleMilestoneApproachReminder({
  required int id,
  required String milestoneTitle,
  required DateTime milestoneDate,
  int daysWarning = 5,
}) async {
  final triggerDate = milestoneDate.subtract(Duration(days: daysWarning));
  if (triggerDate.isBefore(DateTime.now())) return;
  await scheduleNotification(
    id,
    '$daysWarning days to your $milestoneTitle milestone!',
    'Keep going. You\'re almost there.',
    triggerDate,
  );
}

Future<void> cancelMilestoneApproachReminders() async {
  for (int i = 2001; i <= 2004; i++) {
    await _notifications.cancel(i);
  }
}
```

### Step 4 — `milestone_service.dart`: New Singleton

```dart
class MilestoneService {
  static final MilestoneService _instance = MilestoneService._();
  factory MilestoneService() => _instance;
  MilestoneService._();

  // Cancels stale reminders, then schedules approach notifications
  // for all future milestones based on sobriety start date.
  Future<void> checkAndScheduleApproachNotifications(DateTime sobrietyStart) async { ... }

  // Returns first unviewed shareable milestone achievement
  // that hasn't had its celebration shown yet.
  Future<Achievement?> shouldShowCelebration(List<Achievement> unviewedAchievements) async { ... }
}
```

The milestone day/ID map for notification scheduling:
```dart
const _milestoneNotifMap = {
  7: (id: 2001, title: '1 Week'),
  30: (id: 2002, title: '1 Month'),
  90: (id: 2003, title: '90 Days'),
  365: (id: 2004, title: '1 Year'),
};
```

Wire into `AppStateService`:
- In `initialize()`: call `MilestoneService().checkAndScheduleApproachNotifications(sobrietyDate)`
- In `updateSobrietyDate()`: call same after date is saved

### Step 5 — `milestone_badge.dart`: Emoji Badge Widget

```dart
class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({super.key, required this.emoji, required this.size});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      // Outer amber gradient ring
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)]),
        ),
      ),
      // Inner dark circle
      Container(
        width: size * 0.85,
        height: size * 0.85,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF121212), // surface dark
        ),
      ),
      Text(emoji, style: TextStyle(fontSize: size * 0.45)),
    ]);
  }
}
```

### Step 6 — `milestone_share_card.dart`: Capturable Widget

The card is wrapped in `RepaintBoundary` with a `GlobalKey`. It renders off-screen inside an `Offstage` in the celebration dialog's Stack.

Card layout (1080×1080px logical, square):
- Background: `LinearGradient` (dark surface → amber)
- Top: "Steps to Recovery" label
- Center: `MilestoneBadge` (120px) + milestone title + message
- Bottom: "One day at a time." + `AppStoreLinks.shareUrl`

Capture static method:
```dart
static Future<XFile?> capture(GlobalKey repaintKey) async {
  final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  if (byteData == null) return null;
  final bytes = byteData.buffer.asUint8List();
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/milestone_share.png');
  await file.writeAsBytes(bytes);
  return XFile(file.path);
}
```

### Step 7 — `milestone_celebration_screen.dart`: Full-Screen Modal

Triggered via `showGeneralDialog` (not a route) from the home screen.

Layout:
```
Stack:
  AnimatedOpacity(dark scrim)
  ConfettiOverlay(controller: _confetti, child:
    Center(
      Card(
        MilestoneBadge(emoji, size: 100)
        TweenAnimationBuilder<int>(0 → daysSober) — animated counter
        Text(milestone.title) — displayLarge
        Text(milestone.message) — bodyMedium
        Offstage(MilestoneShareCard offscreen with repaintKey)
        Row([ShareButton, JournalButton, ContinueButton])
      )
    )
  )
```

Share button flow:
1. `WidgetsBinding.instance.addPostFrameCallback` to ensure Offstage is laid out
2. `MilestoneShareCard.capture(repaintKey)` → `XFile?`
3. If image: `SharePlus.instance.share(ShareParams(files: [xFile], subject: ..., text: ...))`
4. On success: `analyticsService.trackEvent('milestone_card_shared', ...)`
5. On dismiss: `PreferencesService().markMilestoneCelebrationShown(achievement.achievementKey)` + `DatabaseService().markAchievementViewed(achievement.id)`

### Step 8 — `home_screen.dart`: Wire Celebration Trigger

In `_loadSnapshot().then(...)`:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  if (!mounted) return;
  final achievement = await MilestoneService().shouldShowCelebration(
    data.unreadShareableMilestones,
  );
  if (achievement != null && mounted) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (ctx, _, __) => MilestoneCelebrationScreen(achievement: achievement),
    );
  }
});
```

Also update `_shareMilestone()` to call `MilestoneShareCard.capture()` + share image (upgrades existing share button on sobriety card).

### Step 9 — `profile_screen.dart`: Invite Tile

Add to existing Support `_SettingsSection`:
```dart
_SettingsTile(
  icon: Icons.group_add_outlined,
  title: 'Invite Someone to Recovery',
  subtitle: 'Share the app with someone who might need it',
  onTap: () async {
    await SharePlus.instance.share(ShareParams(
      text: 'I use Steps to Recovery to stay accountable in my sobriety. '
          'It\'s private, works offline, and is completely free. '
          '${AppStoreLinks.shareUrl}',
      subject: 'A recovery app worth trying',
    ));
    analyticsService.trackEvent('invite_shared');
  },
),
```

### Step 10 — `challenges_screen.dart`: Challenge Share Button

On active challenge cards, add `IconButton(Icons.share_outlined)`:
```dart
// Share text for active challenge card
final shareText = 'I\'m doing a ${challenge.durationDays}-day ${challenge.title} in recovery. '
    'One day at a time. ${AppStoreLinks.shareUrl}';
await SharePlus.instance.share(ShareParams(text: shareText, subject: 'Recovery challenge'));
```

---

## Verification Plan

After implementation, verify each feature:

1. **Celebration Screen**:
   - Change sobriety date in test to cross a milestone (e.g., set date 30 days ago)
   - Reload home screen → celebration dialog should appear
   - Dismiss → does NOT appear again on next reload
   - Share → share sheet appears with image card

2. **Visual Share Card**:
   - Tap share in celebration or on sobriety card share button
   - Verify OS share sheet opens with a PNG image attachment
   - Verify image contains milestone text and app URL

3. **Approach Notification**:
   - Set sobriety date 25 days ago
   - Verify notification is scheduled for 5 days before 30-day milestone (i.e., day 25)
   - Use `flutter_local_notifications` test mode or check notification list

4. **Invite Tile**:
   - Navigate to Profile → Support section
   - "Invite Someone to Recovery" tile visible
   - Tap → share sheet opens with invite text + URL

5. **Challenge Share**:
   - Start a challenge
   - Share icon appears on active challenge card
   - Tap → share sheet opens with challenge description + URL

6. **Run existing tests**:
   ```
   flutter test test/home_milestone_share_test.dart
   flutter analyze
   ```

---

## Scope Estimate

| File | New Lines |
|---|---|
| `milestone_service.dart` | ~100 |
| `milestone_celebration_screen.dart` | ~300 |
| `milestone_badge.dart` | ~50 |
| `milestone_share_card.dart` | ~150 |
| `preferences_service.dart` additions | ~20 |
| `notification_service.dart` additions | ~50 |
| `app_constants.dart` additions | ~15 |
| `app_state_service.dart` additions | ~10 |
| `home_screen.dart` modifications | ~50 |
| `profile_screen.dart` modifications | ~25 |
| `challenges_screen.dart` modifications | ~30 |
| **Total** | **~800 lines** |

---

## Privacy Audit

| Feature | Privacy Status |
|---|---|
| Celebration screen | Fully local — no data transmitted |
| Share card | Generated on-device; temp PNG deleted after share; contains only milestone title + app branding — no username, email, or recovery details |
| Approach notifications | Local notification only — no network call |
| Invite to Recovery | Opt-in text share — no tracking, no link personalization |
| Challenge share | Opt-in text share — no tracking |

All features satisfy: offline-first ✅ · privacy-first ✅ · opt-in ✅ · no external SDKs ✅
