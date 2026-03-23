import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

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

            return Scaffold(
              appBar: AppBar(
                title: const Text('12 Steps'),
                backgroundColor: AppColors.background,
              ),
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final step = StepPrompts.all[index];
                          return _StepCard(
                            step: step,
                            progress: progressByStep[step.step],
                            onTap: () {
                              context.push(
                                '${AppRoutes.steps}/detail?stepNumber=${step.step}',
                              );
                            },
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
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
                      style: AppTypography.labelSmall.copyWith(color: statusColor),
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
    );
  }
}
