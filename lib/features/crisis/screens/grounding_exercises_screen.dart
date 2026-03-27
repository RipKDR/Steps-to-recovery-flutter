import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Grounding exercises for crisis moments
/// Uses the 5-4-3-2-1 technique and breathing exercises
class GroundingExercisesScreen extends StatefulWidget {
  const GroundingExercisesScreen({super.key});

  @override
  State<GroundingExercisesScreen> createState() =>
      _GroundingExercisesScreenState();
}

class _GroundingExercisesScreenState extends State<GroundingExercisesScreen>
    with SingleTickerProviderStateMixin {
  int _currentExercise = 0;
  bool _isInProgress = false;
  int _breathCount = 0;
  Timer? _breathTimer;
  bool _isInhaling = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  final List<_GroundingExercise> _exercises = [
    const _GroundingExercise(
      title: '5-4-3-2-1 Technique',
      description:
          'Notice 5 things you see, 4 things you feel, 3 things you hear, 2 things you smell, and 1 thing you taste.',
      icon: Icons.visibility_outlined,
      duration: Duration(minutes: 2),
      steps: [
        'Take a deep breath and look around',
        'Name 5 things you can SEE',
        'Name 4 things you can FEEL (touch)',
        'Name 3 things you can HEAR',
        'Name 2 things you can SMELL',
        'Name 1 thing you can TASTE',
        'Notice how you feel now',
      ],
    ),
    const _GroundingExercise(
      title: 'Box Breathing',
      description:
          'Breathe in for 4, hold for 4, breathe out for 4, hold for 4. Repeat.',
      icon: Icons.air,
      duration: Duration(minutes: 3),
      steps: [
        'Breathe IN through your nose for 4 counts',
        'HOLD your breath for 4 counts',
        'Breathe OUT through your mouth for 4 counts',
        'HOLD empty lungs for 4 counts',
        'Repeat until you feel calmer',
      ],
    ),
    const _GroundingExercise(
      title: 'Body Scan',
      description:
          'Progressively relax each part of your body from head to toe.',
      icon: Icons.accessibility_new_outlined,
      duration: Duration(minutes: 5),
      steps: [
        'Close your eyes and take 3 deep breaths',
        'Focus on your forehead - release any tension',
        'Relax your jaw and neck',
        'Drop your shoulders away from your ears',
        'Relax your arms and hands',
        'Release tension in your chest and stomach',
        'Relax your legs and feet',
        'Notice your whole body feeling heavy and relaxed',
      ],
    ),
    const _GroundingExercise(
      title: 'Safe Place Visualization',
      description: 'Imagine a place where you feel completely safe and calm.',
      icon: Icons.home_outlined,
      duration: Duration(minutes: 4),
      steps: [
        'Close your eyes and breathe deeply',
        'Imagine a place where you feel safe',
        'What do you SEE around you?',
        'What do you HEAR in this place?',
        'What do you FEEL (temperature, textures)?',
        'What do you SMELL in this place?',
        'Notice the feeling of safety in your body',
        'Know you can return here anytime',
      ],
    ),
  ];

  void _startExercise(int index) {
    setState(() {
      _currentExercise = index;
      _isInProgress = true;
    });

    if (index == 1) {
      // Box breathing
      _startBreathingTimer();
      _animationController.repeat(reverse: true);
    }
  }

  void _startBreathingTimer() {
    _breathCount = 0;
    _isInhaling = true;

    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _breathCount++;
        if (_breathCount >= 4) {
          _breathCount = 0;
          _isInhaling = !_isInhaling;
        }
      });
    });
  }

  void _stopExercise() {
    _breathTimer?.cancel();
    _animationController.stop();
    setState(() {
      _isInProgress = false;
      _currentExercise = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInProgress) {
      return _buildExerciseView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grounding Exercises'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.info),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Use these exercises when you feel overwhelmed or triggered. They help bring you back to the present moment.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Choose an Exercise', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          ..._exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ExerciseCard(
                exercise: exercise,
                onTap: () => _startExercise(index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseView() {
    final exercise = _exercises[_currentExercise];

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.title),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _stopExercise,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (_currentExercise == 1) ...[
                // Box breathing visualization
                Expanded(
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isInhaling
                                ? [
                                    AppColors.primaryAmber.withValues(
                                      alpha: 0.3,
                                    ),
                                    AppColors.primaryAmber.withValues(
                                      alpha: 0.6,
                                    ),
                                  ]
                                : [
                                    AppColors.info.withValues(alpha: 0.3),
                                    AppColors.info.withValues(alpha: 0.6),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isInhaling ? 'Breathe In' : 'Breathe Out',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.textOnDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
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
                    Text(exercise.description, style: AppTypography.bodyLarge),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Steps:', style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    ...exercise.steps.asMap().entries.map((entry) {
                      final stepIndex = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryAmber,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${stepIndex + 1}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                step,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _stopExercise,
                  icon: const Icon(Icons.check),
                  label: const Text('I feel grounded'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroundingExercise {
  final String title;
  final String description;
  final IconData icon;
  final Duration duration;
  final List<String> steps;

  const _GroundingExercise({
    required this.title,
    required this.description,
    required this.icon,
    required this.duration,
    required this.steps,
  });
}

class _ExerciseCard extends StatelessWidget {
  final _GroundingExercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  exercise.icon,
                  color: AppColors.primaryAmber,
                  size: AppSpacing.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.title, style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      exercise.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '~${exercise.duration.inMinutes} min',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
