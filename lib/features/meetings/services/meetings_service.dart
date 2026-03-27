import 'package:flutter/material.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';

/// Meetings service with stats and 90-in-90 challenge tracking
class MeetingsService extends ChangeNotifier {
  static final MeetingsService _instance = MeetingsService._internal();
  factory MeetingsService() => _instance;
  MeetingsService._internal();

  final DatabaseService _database = DatabaseService();

  /// Get meetings attended in last 90 days
  Future<List<Meeting>> getRecentMeetings({int days = 90}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final meetings = await _database.getMeetings(
      startDate: startDate,
      endDate: now,
    );
    return meetings.where((m) => m.dateTime != null).toList();
  }

  Future<NinetyInNinetyProgress> get90In90Progress() async {
    final recentMeetings = await getRecentMeetings(days: 90);
    final uniqueDates = recentMeetings
        .map((m) => DateTime(
              m.dateTime!.year,
              m.dateTime!.month,
              m.dateTime!.day,
            ))
        .toSet()
        .length;

    return NinetyInNinetyProgress(
      meetingsAttended: uniqueDates,
      goal: 90,
      daysRemaining: 90 - uniqueDates,
      percentage: (uniqueDates / 90).clamp(0.0, 1.0),
    );
  }

  /// Get meeting attendance stats
  Future<MeetingStats> getStats() async {
    final allMeetings = await _database.getMeetings();
    final now = DateTime.now();

    // Total attended (meetings with future dates are not attended)
    final attended = allMeetings
        .where((m) => m.dateTime != null && m.dateTime!.isBefore(now))
        .length;

    // This week
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = allMeetings
        .where((m) =>
            m.dateTime != null &&
            m.dateTime!.isAfter(weekAgo) &&
            m.dateTime!.isBefore(now))
        .length;

    // This month
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    final thisMonth = allMeetings
        .where((m) =>
            m.dateTime != null &&
            m.dateTime!.isAfter(monthAgo) &&
            m.dateTime!.isBefore(now))
        .length;

    // Favorite meetings
    final favorites = allMeetings.where((m) => m.isFavorite).length;

    // Meeting types breakdown
    final typeCounts = <String, int>{};
    for (final meeting in allMeetings.where((m) => m.dateTime != null)) {
      final type = meeting.meetingType;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Longest streak
    final streak = await _calculateAttendanceStreak();

    return MeetingStats(
      totalAttended: attended,
      thisWeek: thisWeek,
      thisMonth: thisMonth,
      favoritesCount: favorites,
      typeBreakdown: typeCounts,
      longestStreak: streak,
    );
  }

  /// Calculate current attendance streak
  Future<int> _calculateAttendanceStreak() async {
    final meetings = await getRecentMeetings(days: 365);
    if (meetings.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get unique dates sorted descending
    final uniqueDates = meetings
        .map((m) => DateTime(
              m.dateTime!.year,
              m.dateTime!.month,
              m.dateTime!.day,
            ))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    // Check if there's a meeting today or yesterday
    if (uniqueDates.isEmpty) return 0;

    final mostRecent = uniqueDates.first;
    final daysDiff = today.difference(mostRecent).inDays;

    if (daysDiff > 1) return 0; // Streak broken

    // Count consecutive days
    int streak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      final prevDate = uniqueDates[i - 1];
      final currDate = uniqueDates[i];
      if (prevDate.difference(currDate).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get meeting type achievements
  Future<List<MeetingAchievement>> getAchievements() async {
    final stats = await getStats();
    final progress = await get90In90Progress();
    final achievements = <MeetingAchievement>[];

    // 90-in-90 progress
    if (progress.meetingsAttended >= 30) {
      achievements.add(MeetingAchievement(
        id: '90-in-90-30',
        title: '30 Days Strong',
        description: 'Attended 30 meetings',
        icon: Icons.local_fire_department,
        progress: 30,
        total: 90,
        unlocked: progress.meetingsAttended >= 30,
      ));
    }

    if (progress.meetingsAttended >= 60) {
      achievements.add(const MeetingAchievement(
        id: '90-in-90-60',
        title: '60 Days Commitment',
        description: 'Attended 60 meetings',
        icon: Icons.workspace_premium,
        progress: 60,
        total: 90,
        unlocked: true,
      ));
    }

    if (progress.meetingsAttended >= 90) {
      achievements.add(const MeetingAchievement(
        id: '90-in-90-complete',
        title: '90-in-90 Complete!',
        description: '90 meetings in 90 days',
        icon: Icons.emoji_events,
        progress: 90,
        total: 90,
        unlocked: true,
      ));
    }

    // Meeting streak achievements
    if (stats.longestStreak >= 7) {
      achievements.add(MeetingAchievement(
        id: 'streak-7',
        title: 'Week Warrior',
        description: '7 day attendance streak',
        icon: Icons.local_fire_department,
        progress: stats.longestStreak,
        total: 7,
        unlocked: true,
      ));
    }

    if (stats.longestStreak >= 30) {
      achievements.add(MeetingAchievement(
        id: 'streak-30',
        title: 'Monthly Master',
        description: '30 day attendance streak',
        icon: Icons.stars,
        progress: stats.longestStreak,
        total: 30,
        unlocked: true,
      ));
    }

    // Total meetings achievements
    if (stats.totalAttended >= 50) {
      achievements.add(MeetingAchievement(
        id: 'total-50',
        title: 'Dedicated Member',
        description: '50 meetings attended',
        icon: Icons.workspace_premium,
        progress: stats.totalAttended,
        total: 50,
        unlocked: true,
      ));
    }

    if (stats.totalAttended >= 100) {
      achievements.add(MeetingAchievement(
        id: 'total-100',
        title: 'Century Club',
        description: '100 meetings attended',
        icon: Icons.emoji_events,
        progress: stats.totalAttended,
        total: 100,
        unlocked: true,
      ));
    }

    return achievements;
  }
}

/// 90-in-90 progress tracker
class NinetyInNinetyProgress {
  final int meetingsAttended;
  final int goal;
  final int daysRemaining;
  final double percentage;

  const NinetyInNinetyProgress({
    required this.meetingsAttended,
    required this.goal,
    required this.daysRemaining,
    required this.percentage,
  });

  String get progressText => '$meetingsAttended / $goal meetings';
  String get percentageText => '${(percentage * 100).toStringAsFixed(1)}%';
}

/// Meeting attendance statistics
class MeetingStats {
  final int totalAttended;
  final int thisWeek;
  final int thisMonth;
  final int favoritesCount;
  final Map<String, int> typeBreakdown;
  final int longestStreak;

  const MeetingStats({
    required this.totalAttended,
    required this.thisWeek,
    required this.thisMonth,
    required this.favoritesCount,
    required this.typeBreakdown,
    required this.longestStreak,
  });
}

/// Meeting achievement badge
class MeetingAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int progress;
  final int total;
  final bool unlocked;

  const MeetingAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.total,
    required this.unlocked,
  });

  double get progressPercentage => progress / total;
}
