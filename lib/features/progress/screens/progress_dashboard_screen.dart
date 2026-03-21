import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/recovery_content.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Progress Dashboard screen - Shows recovery progress and insights
class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  late final Future<_ProgressSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  Future<_ProgressSnapshot> _loadSnapshot() async {
    final database = DatabaseService();
    final stats = await database.getStats();
    final checkIns = await database.getCheckIns(limit: 30);
    final achievements = await database.getAchievements();
    final stepProgress = await database.getStepProgress();
    final meetings = await database.getMeetings();
    final sobrietyDate = AppStateService.instance.sobrietyDate;

    final daysSober = sobrietyDate == null
        ? 0
        : DateTime.now().difference(sobrietyDate).inDays;

    return _ProgressSnapshot(
      stats: stats,
      checkIns: checkIns,
      achievements: achievements,
      stepProgress: stepProgress,
      meetings: meetings,
      daysSober: daysSober,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<_ProgressSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ??
              const _ProgressSnapshot(
                stats: {},
                checkIns: [],
                achievements: [],
                stepProgress: [],
                meetings: [],
                daysSober: 0,
              );

          final nextMilestone = nextMilestoneForDays(data.daysSober);
          final achievedMilestones = achievedMilestonesForDays(data.daysSober);
          final moodValues = data.checkIns
              .where((checkIn) => checkIn.mood != null)
              .map((checkIn) => checkIn.mood!)
              .toList();
          final averageMood = moodValues.isEmpty
              ? null
              : moodValues.reduce((a, b) => a + b) / moodValues.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SobrietyCard(daysSober: data.daysSober, nextMilestone: nextMilestone),
                const SizedBox(height: AppSpacing.xl),
                Text('Snapshot', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Check-ins',
                        value: '${data.stats['checkIns'] ?? data.checkIns.length}',
                        icon: Icons.track_changes,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Journal',
                        value: '${data.stats['journalEntries'] ?? 0}',
                        icon: Icons.edit,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Steps',
                        value: '${data.stepProgress.where((item) => item.status == StepStatus.completed).length}/12',
                        icon: Icons.stairs,
                        color: AppColors.primaryAmber,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        title: 'Meetings',
                        value: '${data.stats['meetings'] ?? data.meetings.length}',
                        icon: Icons.people,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Mood Trends', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                _MoodTrendCard(
                  averageMood: averageMood,
                  checkIns: data.checkIns,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Milestones', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                if (achievedMilestones.isEmpty)
                  _EmptyMilestoneState(
                    title: 'No milestones yet',
                    description:
                        'Start with a clean day and the milestones will follow.',
                    actionLabel: 'Do a check-in',
                    onTap: () => context.push('/home/morning-intention'),
                  )
                else
                  Column(
                    children: achievedMilestones
                        .map(
                          (milestone) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _MilestoneCard(
                              milestone: milestone,
                              achieved: true,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                if (nextMilestone != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _MilestoneCard(
                    milestone: nextMilestone,
                    achieved: false,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text('Recent Achievements', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                if (data.achievements.isEmpty)
                  _EmptyMilestoneState(
                    title: 'No achievements yet',
                    description:
                        'Your first completed check-in, journal entry, or step answer will show up here.',
                    actionLabel: 'Open journal',
                    onTap: () => context.push('/journal'),
                  )
                else
                  Column(
                    children: data.achievements
                        .map(
                          (achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _AchievementCard(
                              title: achievement.achievementKey,
                              description: achievement.type.name,
                              icon: Icons.emoji_events,
                              date: achievement.earnedAt.toLocal().toIso8601String().split('T').first,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: AppSpacing.xl),
                Text('Next Steps', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                _NextStepCard(
                  title: 'Step work',
                  description: 'Continue your current step and review your answers.',
                  actionLabel: 'Open steps',
                  onTap: () => context.go('/steps'),
                ),
                const SizedBox(height: AppSpacing.md),
                _NextStepCard(
                  title: 'Daily reading',
                  description: 'Reflect on today\'s reading and write it down.',
                  actionLabel: 'Open reading',
                  onTap: () => context.go('/home/daily-reading'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressSnapshot {
  final Map<String, int> stats;
  final List<DailyCheckIn> checkIns;
  final List<Achievement> achievements;
  final List<StepProgress> stepProgress;
  final List<Meeting> meetings;
  final int daysSober;

  const _ProgressSnapshot({
    required this.stats,
    required this.checkIns,
    required this.achievements,
    required this.stepProgress,
    required this.meetings,
    required this.daysSober,
  });
}

class _SobrietyCard extends StatelessWidget {
  final int daysSober;
  final TimeMilestoneContent? nextMilestone;

  const _SobrietyCard({
    required this.daysSober,
    required this.nextMilestone,
  });

  @override
  Widget build(BuildContext context) {
    final milestone = nextMilestone;
    final subtitle = milestone == null
        ? 'You have reached the current milestone range.'
        : 'Next milestone: ${milestone.title}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobriety Counter',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$daysSober days',
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodTrendCard extends StatelessWidget {
  final double? averageMood;
  final List<DailyCheckIn> checkIns;

  const _MoodTrendCard({
    required this.averageMood,
    required this.checkIns,
  });

  @override
  Widget build(BuildContext context) {
    if (checkIns.isEmpty) {
      return _EmptyMilestoneState(
        title: 'No check-in data yet',
        description:
            'Morning and evening check-ins will build your mood trend automatically.',
        actionLabel: 'Do morning check-in',
        onTap: () => context.push('/home/morning-intention'),
      );
    }

    final recent = checkIns.take(7).toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            averageMood == null
                ? 'Mood is not tracked yet'
                : 'Average mood: ${averageMood!.toStringAsFixed(1)} / 5',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          ...recent.map(
            (checkIn) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${checkIn.checkInType.displayName} - mood ${checkIn.mood ?? 0}',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
          Icon(icon, size: AppSpacing.iconLg, color: color),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String date;

  const _AchievementCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryAmber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryAmber,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final TimeMilestoneContent milestone;
  final bool achieved;

  const _MilestoneCard({
    required this.milestone,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    final background = achieved
        ? AppColors.success.withValues(alpha: 0.15)
        : AppColors.surfaceCard;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: achieved ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(milestone.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  milestone.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            achieved ? Icons.check_circle : Icons.flag_outlined,
            color: achieved ? AppColors.success : AppColors.primaryAmber,
          ),
        ],
      ),
    );
  }
}

class _EmptyMilestoneState extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  const _EmptyMilestoneState({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  const _NextStepCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: AppTypography.titleMedium),
        subtitle: Text(description),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(actionLabel),
        ),
      ),
    );
  }
}
