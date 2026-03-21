import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Challenges screen - Recovery challenges
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active challenges
            Text(
              'Active Challenges',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _ChallengeCard(
              title: '30 Day Check-in Streak',
              description: 'Complete daily check-ins for 30 days',
              progress: 0.7,
              daysLeft: 9,
              isActive: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _ChallengeCard(
              title: 'Meeting Explorer',
              description: 'Attend 10 different meetings',
              progress: 0.4,
              daysLeft: 15,
              isActive: true,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Completed challenges
            Text(
              'Completed',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _CompletedChallengeCard(
              title: 'First Week',
              description: 'Complete your first 7 days',
              completedDate: 'Dec 15, 2025',
            ),
            const SizedBox(height: AppSpacing.md),
            _CompletedChallengeCard(
              title: 'Step 1 Complete',
              description: 'Finish all Step 1 questions',
              completedDate: 'Dec 10, 2025',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final int daysLeft;
  final bool isActive;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.daysLeft,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryAmber.withOpacity(0.2)
                        : AppColors.surfaceInteractive,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.local_fire_department
                        : Icons.challenge_outlined,
                    color: isActive
                        ? AppColors.primaryAmber
                        : AppColors.textMuted,
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
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceInteractive,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAmber,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Progress info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).round()}% complete',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '$daysLeft days left',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryAmber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String completedDate;

  const _CompletedChallengeCard({
    required this.title,
    required this.description,
    required this.completedDate,
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
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
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
                    style: AppTypography.titleMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textMuted,
                    ),
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
              completedDate,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
