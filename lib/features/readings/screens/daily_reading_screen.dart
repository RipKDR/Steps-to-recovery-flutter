import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Daily Reading screen
class DailyReadingScreen extends StatelessWidget {
  const DailyReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reading'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryAmber,
                    size: AppSpacing.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _formatDate(DateTime.now()),
                    style: AppTypography.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Reading title
            Text(
              'Just for Today',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Reading content
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Just for today I will be happy. This assumes to be true what Abraham Lincoln said, that "Most folks are about as happy as they make up their minds to be."',
                    style: AppTypography.bodyLarge.copyWith(
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Just for today I will adjust myself to what is, and not try to adjust what is to me.',
                    style: AppTypography.bodyLarge.copyWith(
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Just for today I will exercise my soul in three respects: I will do somebody a good turn, and not get found out.',
                    style: AppTypography.bodyLarge.copyWith(
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Reflection prompt
            Text(
              'Reflection',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceInteractive,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(
                'What does "adjusting yourself to what is" mean to you in your recovery journey today?',
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Previous day
                    },
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Write reflection
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Reflect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      foregroundColor: AppColors.textOnDark,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Next day
                    },
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
