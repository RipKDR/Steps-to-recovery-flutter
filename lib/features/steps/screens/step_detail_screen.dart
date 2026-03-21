import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Step Detail screen - Shows questions for a specific step
class StepDetailScreen extends StatefulWidget {
  final int stepNumber;
  final int? initialQuestion;

  const StepDetailScreen({
    super.key,
    required this.stepNumber,
    this.initialQuestion,
  });

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  late int _currentStepNumber;
  late int _currentQuestionIndex;
  final _answerController = TextEditingController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentStepNumber = widget.stepNumber;
    _currentQuestionIndex = widget.initialQuestion ?? 0;
  }

  @override
  void dispose() {
    _answerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = StepPrompts.getStep(_currentStepNumber);
    if (step == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Step Not Found')),
        body: const Center(child: Text('Invalid step number')),
      );
    }

    final sections = step.sections;
    final totalQuestions = sections.fold<int>(
      0,
      (sum, section) => sum + section.prompts.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Step $_currentStepNumber: ${step.title}'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              context.push(
                '${AppRoutes.steps}/review?stepNumber=$_currentStepNumber',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / totalQuestions,
            backgroundColor: AppColors.surfaceInteractive,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryAmber,
            ),
          ),
          
          // Question counter
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  step.principle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryAmber,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Question and answer
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current question
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCurrentQuestion(step),
                          style: AppTypography.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Answer input
                  Text(
                    'Your Answer',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _answerController,
                    maxLines: 8,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Write your reflection here...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                // Previous button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? _previousQuestion
                        : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Save & Next button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex < totalQuestions - 1
                        ? _saveAndNext
                        : _finishStep,
                    child: Text(
                      _currentQuestionIndex < totalQuestions - 1
                          ? 'Save & Next'
                          : 'Finish',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentQuestion(StepPrompt step) {
    int questionIndex = 0;
    for (final section in step.sections) {
      if (questionIndex + section.prompts.length > _currentQuestionIndex) {
        return section.prompts[_currentQuestionIndex - questionIndex];
      }
      questionIndex += section.prompts.length;
    }
    return step.prompts[_currentQuestionIndex];
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _answerController.clear();
    }
  }

  void _saveAndNext() {
    // Save answer logic here
    if (_currentQuestionIndex < 999) { // Placeholder for total questions
      setState(() {
        _currentQuestionIndex++;
      });
      _answerController.clear();
    }
  }

  void _finishStep() {
    // Save final answer and complete step
    Navigator.pop(context);
  }
}
