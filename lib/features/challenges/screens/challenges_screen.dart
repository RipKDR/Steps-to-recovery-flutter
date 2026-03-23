import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/recovery_content.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_utils.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_state.dart';

/// Challenges screen - Recovery challenges
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  late final Future<List<Challenge>> _challengeFuture;

  @override
  void initState() {
    super.initState();
    _challengeFuture = DatabaseService().getChallenges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _challengeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }

          final challenges = snapshot.data ?? const <Challenge>[];
          final active = challenges.where((item) => item.isActive).toList();
          final completed = challenges.where((item) => item.isCompleted).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Challenges',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                if (active.isEmpty)
                  EmptyState(
                    icon: Icons.local_fire_department,
                    title: 'No active challenges yet',
                    message:
                        'Choose a recovery challenge to build consistency in journaling, meetings, or step work.',
                  )
                else
                  Column(
                    children: active
                        .map(
                          (challenge) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _ChallengeCard(
                              title: challenge.title,
                              description: challenge.description,
                              progress: _progressForChallenge(challenge),
                              daysLeft: _daysLeft(challenge),
                              isActive: true,
                              reward: '${challenge.durationDays} day challenge',
                              onShare: () async {
                                final shareText =
                                    "I'm doing a ${challenge.durationDays}-day "
                                    '${challenge.title} challenge in my recovery. '
                                    'One day at a time. '
                                    '${AppStoreLinks.shareUrl}';
                                await SharePlus.instance.share(ShareParams(
                                  text: shareText,
                                  subject: 'Recovery Challenge',
                                ));
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Starter Templates',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...challengeTemplates.map(
                  (template) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _TemplateCard(template: template),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Completed',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                if (completed.isEmpty)
                  EmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'No completed challenges yet',
                    message:
                        'Finished challenges will show up here once the local database starts recording progress.',
                  )
                else
                  Column(
                    children: completed
                        .map(
                          (challenge) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _CompletedChallengeCard(
                              title: challenge.title,
                              description: challenge.description,
                              completedDate: challenge.endDate != null ? AppUtils.formatDate(challenge.endDate!) : 'completed',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'When It Gets Hard',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...copingStrategies.map(
                  (strategy) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _StrategyCard(text: strategy),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Crisis Resources',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...crisisResources.map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CrisisResourceCard(resource: resource),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _progressForChallenge(Challenge challenge) {
    if (challenge.isCompleted) {
      return 1.0;
    }

    final endDate = challenge.endDate;
    if (endDate == null) {
      return 0.1;
    }

    final total = endDate.difference(challenge.startDate).inSeconds;
    if (total <= 0) {
      return 0.1;
    }

    final elapsed = DateTime.now()
        .difference(challenge.startDate)
        .inSeconds
        .clamp(0, total);
    return ((elapsed / total).clamp(0.05, 0.99)).toDouble();
  }

  int _daysLeft(Challenge challenge) {
    if (challenge.endDate == null) {
      return challenge.durationDays;
    }
    final remaining = challenge.endDate!.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final int daysLeft;
  final bool isActive;
  final String reward;
  final VoidCallback? onShare;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.daysLeft,
    required this.isActive,
    required this.reward,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title challenge, ${(progress * 100).round()}% complete, $daysLeft days left',
      child: Card(
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
                          ? AppColors.primaryAmber.withValues(alpha: 0.2)
                          : AppColors.surfaceInteractive,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.local_fire_department
                          : Icons.emoji_events_outlined,
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
                  if (onShare != null)
                    Semantics(
                      label: 'Share $title challenge',
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined),
                        tooltip: 'Share this challenge',
                        color: AppColors.textMuted,
                        onPressed: onShare,
                      ),
                    ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              reward,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ChallengeTemplateContent template;

  const _TemplateCard({required this.template});

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
                    color: AppColors.surfaceInteractive,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.playlist_add_check,
                    color: AppColors.primaryAmber,
                    size: AppSpacing.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.title, style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        template.difficulty,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              template.description,
              style: AppTypography.bodyMedium.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoChip(label: '${template.target} target'),
                _InfoChip(label: '${template.duration} days'),
                _InfoChip(label: template.reward),
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
                color: AppColors.success.withValues(alpha: 0.2),
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

class _StrategyCard extends StatelessWidget {
  final String text;

  const _StrategyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa, color: AppColors.primaryAmber, size: AppSpacing.iconSm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CrisisResourceCard extends StatelessWidget {
  final CrisisResourceContent resource;

  const _CrisisResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(resource.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title, style: AppTypography.bodyMedium),
                Text(
                  resource.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            resource.phone,
            style: AppTypography.labelMedium.copyWith(
              color: resource.isEmergency ? AppColors.danger : AppColors.primaryAmber,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceInteractive,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
