import '../constants/app_constants.dart';
import '../models/database_models.dart';
import 'notification_service.dart';
import 'preferences_service.dart';

/// Milestone notification ID map: sobriety days -> (notif id, display title)
const _milestoneNotifMap = {
  7: (id: NotificationIds.milestoneApproachBase + 1, title: '1 Week'),
  30: (id: NotificationIds.milestoneApproachBase + 2, title: '1 Month'),
  90: (id: NotificationIds.milestoneApproachBase + 3, title: '90 Days'),
  365: (id: NotificationIds.milestoneApproachBase + 4, title: '1 Year'),
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

  /// Returns the first achievement in [achievements] whose celebration
  /// has not yet been shown to the user.
  Future<Achievement?> shouldShowCelebration(
    List<Achievement> achievements,
  ) async {
    final prefs = PreferencesService();
    for (final achievement in achievements) {
      final shown =
          await prefs.hasMilestoneCelebrationShown(achievement.achievementKey);
      if (!shown) return achievement;
    }
    return null;
  }
}
