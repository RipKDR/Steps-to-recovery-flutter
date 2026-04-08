import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../services/meetings_service.dart';

/// Meetings Stats Screen - 90-in-90 tracker and attendance stats
class MeetingsStatsScreen extends StatefulWidget {
  const MeetingsStatsScreen({super.key});

  @override
  State<MeetingsStatsScreen> createState() => _MeetingsStatsScreenState();
}

class _MeetingsStatsScreenState extends State<MeetingsStatsScreen> {
  late final Future<_StatsSnapshot> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<_StatsSnapshot> _loadStats() async {
    final service = MeetingsService();
    final stats = await service.getStats();
    final progress = await service.get90In90Progress();
    final achievements = await service.getAchievements();
    return _StatsSnapshot(
      stats: stats,
      progress: progress,
      achievements: achievements,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Stats'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<_StatsSnapshot>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data ??
              const _StatsSnapshot(
                stats: MeetingStats(
                  totalAttended: 0,
                  thisWeek: 0,
                  thisMonth: 0,
                  favoritesCount: 0,
                  typeBreakdown: {},
                  longestStreak: 0,
                ),
                progress: NinetyInNinetyProgress(
                  meetingsAttended: 0,
                  goal: 90,
                  daysRemaining: 90,
                  percentage: 0,
                ),
                achievements: [],
              );

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _statsFuture = _loadStats());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 90-in-90 Progress Card
                  _build90In90Card(data.progress),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick Stats
                  Text(
                    'Attendance Overview',
                    style: AppTypography.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'This Week',
                          value: data.stats.thisWeek.toString(),
                          icon: Icons.calendar_today,
                          color: AppColors.success,
                        )
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          title: 'This Month',
                          value: data.stats.thisMonth.toString(),
                          icon: Icons.calendar_month,
                          color: AppColors.info,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: data.stats.totalAttended.toString(),
                          icon: Icons.event_repeat,
                          color: AppColors.primaryAmber,
                        )
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          title: 'Streak',
                          value: '${data.stats.longestStreak}d',
                          icon: Icons.local_fire_department,
                          color: AppColors.danger,
                        )
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Meeting Types
                  if (data.stats.typeBreakdown.isNotEmpty) ...[
                    Text('Meeting Types', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: data.stats.typeBreakdown.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: AppTypography.bodyMedium,
                                ),
                                Text(
                                  '${entry.value} meetings',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primaryAmber,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Achievements
                  Text('Achievements', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  if (data.achievements.isEmpty)
                    _buildEmptyAchievements()
                  else
                    ...data.achievements.map((achievement) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AchievementCard(achievement: achievement)
                      );
                    }),

                  const SizedBox(height: AppSpacing.xl),

                  // Actions
                  ElevatedButton.icon(
                    onPressed: () => context.push('/meetings'),
                    icon: const Icon(Icons.add),
                    label: const Text('Find a Meeting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      foregroundColor: AppColors.textOnDark,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _build90In90Card(NinetyInNinetyProgress progress) {
    final isComplete = progress.meetingsAttended >= 90;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [
                  AppColors.success.withValues(alpha: 0.3),
                  AppColors.success.withValues(alpha: 0.1),
                ]
              : [
                  AppColors.primaryAmber.withValues(alpha: 0.3),
                  AppColors.primaryAmber.withValues(alpha: 0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isComplete ? AppColors.success : AppColors.primaryAmber,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.emoji_events : Icons.local_fire_department,
                color: isComplete ? AppColors.success : AppColors.primaryAmber,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? '90-in-90 Complete!' : '90-in-90 Challenge',
                      style: AppTypography.titleLarge.copyWith(
                        color: isComplete
                            ? AppColors.success
                            : AppColors.primaryAmber,
                      ),
                    ),
                    Text(
                      isComplete
                          ? 'Congratulations on your commitment!'
                          : '${progress.daysRemaining} days remaining',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 12,
            percent: progress.percentage,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  progress.meetingsAttended.toString(),
                  style: AppTypography.displayLarge.copyWith(
                    color: isComplete
                        ? AppColors.success
                        : AppColors.primaryAmber,
                  ),
                ),
                Text(
                  '/ 90',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            progressColor: isComplete
                ? AppColors.success
                : AppColors.primaryAmber,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            progress.progressText,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No achievements yet',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Attend meetings to unlock badges',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget for displaying meeting statistics
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Achievement card widget for displaying meeting achievements
class AchievementCard extends StatelessWidget {
  final MeetingAchievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.unlocked;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isUnlocked ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.border,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? AppColors.success : AppColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isUnlocked ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  achievement.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!isUnlocked)
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryAmber,
                    ),
                    minHeight: 6,
                  ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: AppColors.success)
          else
            Text(
              '${achievement.progress}/${achievement.total}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsSnapshot {
  final MeetingStats stats;
  final NinetyInNinetyProgress progress;
  final List<MeetingAchievement> achievements;

  const _StatsSnapshot({
    required this.stats,
    required this.progress,
    required this.achievements,
  });
}
