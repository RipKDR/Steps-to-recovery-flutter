import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Steps Overview screen - Shows all 12 steps with progress
class StepsOverviewScreen extends StatelessWidget {
  const StepsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}

class _StepCard extends StatelessWidget {
  final StepPrompt step;
  final VoidCallback onTap;

  const _StepCard({
    required this.step,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Step number badge
              Container(
                width: AppSpacing.quint,
                height: AppSpacing.quint,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
              
              // Step info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: AppTypography.titleMedium,
                    ),
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
                  ],
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
