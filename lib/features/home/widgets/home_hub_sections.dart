import 'package:flutter/material.dart';

import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/home_hub_models.dart';
import 'home_hub_inputs.dart';

class RecoveryHeroCard extends StatelessWidget {
  const RecoveryHeroCard({
    super.key,
    required this.snapshot,
    required this.recommendation,
    required this.onShareMilestone,
    this.semanticsKey,
  });

  final HomeHubSnapshot snapshot;
  final HomeActionRecommendation recommendation;
  final VoidCallback? onShareMilestone;
  final Key? semanticsKey;

  @override
  Widget build(BuildContext context) {
    final sobrietyDays = AppStateService.instance.sobrietyDays;
    final unreadAchievementsLabel = snapshot.unreadAchievements > 0
        ? '${snapshot.unreadAchievements} achievement${snapshot.unreadAchievements == 1 ? '' : 's'} waiting.'
        : 'No unread achievements.';
    final milestoneLabel =
        snapshot.user?.sobrietyMilestone ?? 'Recovery starts now';

    return Semantics(
      container: true,
      label:
          'Recovery overview. Welcome back, ${AppStateService.instance.userLabel}. Recovery day $sobrietyDays. Milestone $milestoneLabel. ${recommendation.heroTitle}. $unreadAchievementsLabel',
      child: Container(
        key: semanticsKey,
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF201307), AppColors.surfaceElevated],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${AppStateService.instance.userLabel}',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recovery day',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$sobrietyDays',
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.primaryAmberLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(milestoneLabel, style: AppTypography.labelMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(recommendation.heroTitle, style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              recommendation.heroSubtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (snapshot.unreadAchievements > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${snapshot.unreadAchievements} achievement${snapshot.unreadAchievements == 1 ? '' : 's'} waiting',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryAmberLight,
                ),
              ),
            ],
            if (snapshot.featuredShareContent != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onShareMilestone,
                icon: const Icon(Icons.share_outlined),
                label: Text(snapshot.featuredShareContent!.buttonLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: AppColors.textPrimary.withValues(alpha: 0.32),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DailyActionCard extends StatelessWidget {
  const DailyActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    required this.detail,
    required this.highlight,
    required this.completeBody,
    required this.incompleteBody,
    required this.onOpenFull,
    required this.openButtonKey,
    this.semanticsKey,
  });

  final String title;
  final String description;
  final IconData icon;
  final DailyCardStatus status;
  final String detail;
  final bool highlight;
  final String completeBody;
  final Widget incompleteBody;
  final VoidCallback onOpenFull;
  final Key openButtonKey;
  final Key? semanticsKey;

  @override
  Widget build(BuildContext context) {
    final isComplete = status == DailyCardStatus.doneToday;
    final semanticsSummary = isComplete ? completeBody : detail;

    return Semantics(
      container: true,
      label:
          '$title. ${status.label}. $description. ${semanticsSummary.trim()}',
      child: Container(
        key: semanticsKey,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: highlight ? AppColors.surfaceElevated : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: highlight ? AppColors.primaryAmber : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSpacing.quad,
                  height: AppSpacing.quad,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Icon(icon, color: AppColors.primaryAmber),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleLarge),
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
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (isComplete)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(completeBody, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    key: openButtonKey,
                    onPressed: onOpenFull,
                    child: const Text('Open full check-in'),
                  ),
                ],
              )
            else
              incompleteBody,
          ],
        ),
      ),
    );
  }
}

class SupportSummaryPanel extends StatelessWidget {
  const SupportSummaryPanel({
    super.key,
    required this.snapshot,
    this.semanticsKey,
  });

  final HomeHubSnapshot snapshot;
  final Key? semanticsKey;

  @override
  Widget build(BuildContext context) {
    final sponsorLabel = snapshot.sponsor?.name ?? 'Sponsor not added';
    final programLabel =
        AppStateService.instance.programType ?? 'Program not set';
    final milestonesLabel = snapshot.unreadAchievements > 0
        ? '${snapshot.unreadAchievements} waiting'
        : 'Quiet today';

    return Semantics(
      container: true,
      label:
          'Steady supports. Sponsor: $sponsorLabel. Program: $programLabel. Milestones: $milestonesLabel.',
      child: Container(
        key: semanticsKey,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Steady supports', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Keep the practical stuff close so the daily flow stays clear.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _SupportMetric(
                    key: const Key('home-support-sponsor'),
                    label: 'Sponsor',
                    value: sponsorLabel,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SupportMetric(label: 'Program', value: programLabel),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SupportMetric(
                    label: 'Milestones',
                    value: milestonesLabel,
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

class SupportSheetAction extends StatelessWidget {
  const SupportSheetAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      minVerticalPadding: AppSpacing.xs,
      leading: Container(
        width: AppSpacing.quad,
        height: AppSpacing.quad,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Icon(icon, color: AppColors.primaryAmber),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _SupportMetric extends StatelessWidget {
  const _SupportMetric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
