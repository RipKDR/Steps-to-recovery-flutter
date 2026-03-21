import 'package:flutter/material.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Step Review screen - Review all answers for a step
class StepReviewScreen extends StatelessWidget {
  final int stepNumber;

  const StepReviewScreen({
    super.key,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    final step = StepPrompts.getStep(stepNumber);
    if (step == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Step Not Found')),
        body: const Center(child: Text('Invalid step number')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Step $stepNumber'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share with sponsor
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export answers
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sections = step.sections;
                  int questionIndex = 0;
                  
                  for (final section in sections) {
                    if (questionIndex + section.prompts.length > index) {
                      final promptIndex = index - questionIndex;
                      return _AnswerCard(
                        sectionTitle: section.title,
                        question: section.prompts[promptIndex],
                        answer: 'Your answer would appear here...', // Placeholder
                      );
                    }
                    questionIndex += section.prompts.length;
                  }
                  
                  return null;
                },
                childCount: step.prompts.length,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Steps'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Mark as complete
                },
                child: const Text('Mark Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String sectionTitle;
  final String question;
  final String answer;

  const _AnswerCard({
    required this.sectionTitle,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryAmber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                sectionTitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryAmber,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Question
            Text(
              question,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Answer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceInteractive,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                answer,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
