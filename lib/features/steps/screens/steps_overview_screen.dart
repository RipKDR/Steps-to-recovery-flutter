import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/glass_card.dart';

/// Steps overview with real progress from local step answers.
class StepsOverviewScreen extends StatelessWidget {
  const StepsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DatabaseService(),
      builder: (context, _) {
        return FutureBuilder<List<StepProgress>>(
          future: DatabaseService().getStepProgress(),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? const <StepProgress>[];
            final progressByStep = <int, StepProgress>{
              for (final item in progress) item.stepNumber: item,
            };

            final completedCount = progress
                .where((p) => p.status == StepStatus.completed)
                .length;
            final totalSteps = StepPrompts.all.length;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('12 Steps'),
                backgroundColor: AppColors.background,
              ),
              body: CustomScrollView(
                slivers: [
                  // Progress header card
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step $completedCount of $totalSteps',
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              completedCount == totalSteps
                                  ? 'All steps completed'
                                  : '${totalSteps - completedCount} steps remaining',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                              child: LinearProgressIndicator(
                                value: totalSteps > 0
                                    ? completedCount / totalSteps
                                    : 0.0,
                                minHeight: 6,
                                backgroundColor: AppColors.surfaceInteractive,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryAmber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.97, 0.97)),
                    ),
                  ),
                  // Step cards list
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final step = StepPrompts.all[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 24.0,
                              child: FadeInAnimation(
                                child: _StepCard(
                                  step: step,
                                  progress: progressByStep[step.step],
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.push(
                                      '${AppRoutes.steps}/detail?stepNumber=${step.step}',
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: StepPrompts.all.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.progress,
    required this.onTap,
  });

  final StepPrompt step;
  final StepProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = progress?.status ?? StepStatus.notStarted;
    final completion = progress?.completionPercentage ?? 0.0;

    final statusColor = switch (status) {
      StepStatus.completed => AppColors.success,
      StepStatus.inProgress => AppColors.primaryAmber,
      StepStatus.notStarted => AppColors.textMuted,
    };

    // Left border color and optional background tint per status
    final leftBorderColor = switch (status) {
      StepStatus.completed => AppColors.success,
      StepStatus.inProgress => AppColors.primaryAmber,
      StepStatus.notStarted => AppColors.border,
    };

    final backgroundTint = switch (status) {
      StepStatus.inProgress =>
        AppColors.primaryAmber.withValues(alpha: 0.04),
      _ => AppColors.surfaceCard,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border(
          left: BorderSide(color: leftBorderColor, width: 3),
          top: BorderSide(color: AppColors.border, width: 0.5),
          right: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.quint,
                  height: AppSpacing.quint,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      '${step.step}',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        step.principle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryAmber,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        step.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        child: LinearProgressIndicator(
                          value: completion,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceInteractive,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${status.displayName} • ${(completion * 100).round()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
