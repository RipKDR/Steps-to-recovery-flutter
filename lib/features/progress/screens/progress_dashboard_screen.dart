import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Progress Dashboard screen - Shows recovery progress and insights
class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sobriety counter
            _SobrietyCard(),
            const SizedBox(height: AppSpacing.xl),
            
            // Mood chart placeholder
            Text(
              'Mood Trends',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _MoodChartPlaceholder(),
            const SizedBox(height: AppSpacing.xl),
            
            // Stats grid
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Check-ins',
                  value: '24',
                  icon: Icons.track_changes,
                  color: AppColors.info,
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(
                  title: 'Journal',
                  value: '12',
                  icon: Icons.edit,
                  color: AppColors.success,
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Steps Done',
                  value: '3/12',
                  icon: Icons.stairs,
                  color: AppColors.primaryAmber,
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _StatCard(
                  title: 'Meetings',
                  value: '8',
                  icon: Icons.people,
                  color: AppColors.info,
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Recent achievements
            Text(
              'Recent Achievements',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _AchievementCard(
              title: '7 Day Streak',
              description: 'Completed 7 days of check-ins',
              icon: Icons.local_fire_department,
              date: '2 days ago',
            ),
            const SizedBox(height: AppSpacing.md),
            _AchievementCard(
              title: 'First Step',
              description: 'Completed Step 1 work',
              icon: Icons.stairs,
              date: '5 days ago',
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Commitment calendar placeholder
            Text(
              'Commitment Calendar',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _CalendarPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _SobrietyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            '30 days',
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '1 month clean',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textOnDark.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: AppSpacing.iconXxl,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Mood trends will appear here',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
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
          Icon(
            icon,
            size: AppSpacing.iconLg,
            color: color,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.headlineMedium,
          ),
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
                color: AppColors.primaryAmber.withOpacity(0.2),
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
                  Text(
                    title,
                    style: AppTypography.titleMedium,
                  ),
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

class _CalendarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_month,
              size: AppSpacing.iconXxl,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Commitment calendar coming soon',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
