import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/step_prompts.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Sequential step work with persisted answers.
class StepDetailScreen extends StatefulWidget {
  const StepDetailScreen({
    super.key,
    required this.stepNumber,
    this.initialQuestion,
  });

  final int stepNumber;
  final int? initialQuestion;

  @override
  State<StepDetailScreen> createState() => _StepDetailScreenState();
}

class _StepDetailScreenState extends State<StepDetailScreen> {
  final _answerController = TextEditingController();
  late final List<_StepQuestion> _questions;
  late int _currentQuestionIndex;
  bool _isSaving = false;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final step = StepPrompts.getStep(widget.stepNumber);
    _questions = step == null ? const <_StepQuestion>[] : _flattenQuestions(step);
    _currentQuestionIndex = widget.initialQuestion?.clamp(0, _questions.length - 1) ?? 0;
    _loadFuture = _loadCurrentAnswer();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentAnswer() async {
    if (_questions.isEmpty) {
      return;
    }
    final answer = await DatabaseService().getStepAnswer(
      stepNumber: widget.stepNumber,
      questionNumber: _questions[_currentQuestionIndex].questionNumber,
    );
    if (!mounted) {
      return;
    }
    _answerController.text = answer?.answer ?? '';
  }

  Future<void> _goToQuestion(int nextIndex) async {
    setState(() {
      _currentQuestionIndex = nextIndex;
      _answerController.clear();
    });
    await _loadCurrentAnswer();
  }

  Future<void> _saveCurrentAnswer() async {
    final question = _questions[_currentQuestionIndex];
    setState(() => _isSaving = true);
    try {
      await DatabaseService().saveStepAnswer(
        StepWorkAnswer(
          id: '',
          userId: DatabaseService().activeUserId ?? '',
          stepNumber: widget.stepNumber,
          questionNumber: question.questionNumber,
          answer: _answerController.text.trim(),
          isComplete: _answerController.text.trim().isNotEmpty,
          completedAt: _answerController.text.trim().isNotEmpty ? DateTime.now() : null,
          syncStatus: SyncStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveAndNext() async {
    await _saveCurrentAnswer();
    if (_currentQuestionIndex < _questions.length - 1) {
      await _goToQuestion(_currentQuestionIndex + 1);
      return;
    }
    if (mounted) {
      unawaited(context.push('${AppRoutes.steps}/review?stepNumber=${widget.stepNumber}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = StepPrompts.getStep(widget.stepNumber);
    if (step == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Step Not Found')),
        body: const Center(child: Text('Invalid step number')),
      );
    }

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        final question = _questions[_currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('Step ${widget.stepNumber}: ${step.title}'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.assignment),
                onPressed: () {
                  context.push(
                    '${AppRoutes.steps}/review?stepNumber=${widget.stepNumber}',
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: AppColors.surfaceInteractive,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAmber),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      question.sectionTitle,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            Text(question.prompt, style: AppTypography.titleLarge),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              step.principle,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Your Answer', style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _answerController,
                        maxLines: 10,
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentQuestionIndex > 0
                            ? () => _goToQuestion(_currentQuestionIndex - 1)
                            : null,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndNext,
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1
                              ? (_isSaving ? 'Saving...' : 'Save & Next')
                              : (_isSaving ? 'Saving...' : 'Review Step'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
