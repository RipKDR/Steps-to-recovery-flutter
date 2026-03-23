import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Step review with persisted answers and completion state.
class StepReviewScreen extends StatelessWidget {
  const StepReviewScreen({
    super.key,
    required this.stepNumber,
  });

  final int stepNumber;

  @override
  Widget build(BuildContext context) {
    final step = StepPrompts.getStep(stepNumber);
    if (step == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Step Not Found')),
        body: const Center(child: Text('Invalid step number')),
      );
    }

    return AnimatedBuilder(
      animation: DatabaseService(),
      builder: (context, _) {
        return FutureBuilder<List<StepWorkAnswer>>(
          future: DatabaseService().getStepAnswers(stepNumber: stepNumber),
          builder: (context, snapshot) {
            final answers = snapshot.data ?? const <StepWorkAnswer>[];
            final flattened = _flattenQuestions(step);
            final answerMap = <int, StepWorkAnswer>{
              for (final answer in answers) answer.questionNumber: answer,
            };
            final completed = answerMap.values
                .where((answer) => answer.answer?.trim().isNotEmpty == true)
                .length;

            return Scaffold(
              appBar: AppBar(
                title: Text('Review Step $stepNumber'),
                backgroundColor: AppColors.background,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: completed == 0
                        ? null
                        : () => _shareAnswers(step, flattened, answerMap),
                  ),
                ],
              ),
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: AppTypography.headlineSmall),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '$completed of ${flattened.length} prompts answered',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final question = flattened[index];
                          final answer = answerMap[question.questionNumber];
                          return _AnswerCard(
                            questionNumber: question.questionNumber,
                            sectionTitle: question.sectionTitle,
                            question: question.prompt,
                            answer: answer?.answer?.trim().isNotEmpty == true
                                ? answer!.answer!
                                : 'No answer yet.',
                            isComplete: answer?.answer?.trim().isNotEmpty == true,
                            onEdit: () {
                              context.push(
                                '${AppRoutes.stepDetail}?stepNumber=$stepNumber&question=$index',
                              );
                            },
                          );
                        },
                        childCount: flattened.length,
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.steps),
                        child: const Text('Back to Steps'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: completed == flattened.length && flattened.isNotEmpty
                            ? () async {
                                await DatabaseService().saveStepProgress(
                                  StepProgress(
                                    id: '',
                                    userId: DatabaseService().activeUserId ?? '',
                                    stepNumber: stepNumber,
                                    status: StepStatus.completed,
                                    completionPercentage: 1,
                                    completedAt: DateTime.now(),
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                                if (context.mounted) {
                                  context.go(AppRoutes.steps);
                                }
                              }
                            : null,
                        child: const Text('Mark Complete'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareAnswers(
    StepPrompt step,
    List<_StepQuestion> questions,
    Map<int, StepWorkAnswer> answers,
  ) {
    final buffer = StringBuffer('Step ${step.step}: ${step.title}\n\n');
    for (final question in questions) {
      final answer = answers[question.questionNumber]?.answer?.trim();
      if (answer == null || answer.isEmpty) {
        continue;
      }
      buffer
        ..writeln('${question.questionNumber}. ${question.prompt}')
        ..writeln(answer)
        ..writeln();
    }
    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  List<_StepQuestion> _flattenQuestions(StepPrompt step) {
    final items = <_StepQuestion>[];
    var questionNumber = 1;
    for (final section in step.sections) {
      for (final prompt in section.prompts) {
        items.add(
          _StepQuestion(
            questionNumber: questionNumber,
            sectionTitle: section.title,
            prompt: prompt,
          ),
        );
        questionNumber += 1;
      }
    }
    return items;
  }
}

class _StepQuestion {
  const _StepQuestion({
    required this.questionNumber,
    required this.sectionTitle,
    required this.prompt,
  });

  final int questionNumber;
  final String sectionTitle;
  final String prompt;
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.questionNumber,
    required this.sectionTitle,
    required this.question,
    required this.answer,
    required this.isComplete,
    required this.onEdit,
  });

  final int questionNumber;
  final String sectionTitle;
  final String question;
  final String answer;
  final bool isComplete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '$sectionTitle • $questionNumber',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onEdit,
                  child: Text(isComplete ? 'Edit' : 'Answer'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(question, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceInteractive,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isComplete ? AppColors.success : AppColors.border,
                ),
              ),
              child: Text(answer, style: AppTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
