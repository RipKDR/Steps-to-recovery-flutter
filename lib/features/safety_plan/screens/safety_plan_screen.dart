import 'package:flutter/material.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/loading_state.dart';

/// Safety Plan screen - Personal safety plan builder
class SafetyPlanScreen extends StatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  State<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends State<SafetyPlanScreen> {
  final _warningSignsController = TextEditingController();
  final _copingController = TextEditingController();
  final _supportController = TextEditingController();
  final _professionalController = TextEditingController();
  final _environmentController = TextEditingController();

  late Future<void> _loadFuture;
  String? _planId;
  bool _saving = false;
  int _currentStep = 0;

  final _stepTitles = const [
    'Warning Signs',
    'Coping Strategies',
    'Support Contacts',
    'Professional Contacts',
    'Safe Environments',
  ];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadPlan();
  }

  @override
  void dispose() {
    _warningSignsController.dispose();
    _copingController.dispose();
    _supportController.dispose();
    _professionalController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    final database = DatabaseService();
    final currentUser = await database.getCurrentUser();
    if (currentUser == null) {
      return;
    }

    final plan = await database.getSafetyPlan(currentUser.id);
    if (plan == null) {
      return;
    }

    _planId = plan.id;
    _warningSignsController.text = _joinEntries(plan.warningSigns);
    _copingController.text = _joinEntries(plan.copingStrategies);
    _supportController.text = _joinEntries(plan.supportContacts);
    _professionalController.text = _joinEntries(plan.professionalContacts);
    _environmentController.text = _joinEntries(plan.safeEnvironments);
  }

  Future<void> _savePlan({bool showFeedback = true}) async {
    final database = DatabaseService();
    final currentUser = await database.getCurrentUser();
    if (currentUser == null) {
      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save your safety plan.')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final saved = await database.saveSafetyPlan(
        SafetyPlan(
          id: _planId ?? '',
          userId: currentUser.id,
          warningSigns: _splitEntries(_warningSignsController.text),
          copingStrategies: _splitEntries(_copingController.text),
          supportContacts: _splitEntries(_supportController.text),
          professionalContacts: _splitEntries(_professionalController.text),
          safeEnvironments: _splitEntries(_environmentController.text),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _planId = saved.id;
      if (mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safety plan saved locally')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _goToStep(int step) async {
    await _savePlan(showFeedback: false);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentStep = step.clamp(0, _stepTitles.length - 1);
    });
  }

  Future<void> _nextStep() async {
    if (_currentStep < _stepTitles.length - 1) {
      await _goToStep(_currentStep + 1);
      return;
    }

    await _savePlan(showFeedback: true);
    if (!mounted) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep == 0) {
      return;
    }
    await _goToStep(_currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: LoadingState(message: 'Loading safety plan...'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Safety Plan'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                tooltip: 'Save plan',
                icon: const Icon(Icons.save_outlined),
                onPressed: _saving ? null : () => _savePlan(showFeedback: true),
              ),
            ],
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStep + 1) / _stepTitles.length,
                backgroundColor: AppColors.surfaceInteractive,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAmber,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_stepTitles.length, (index) {
                    final isActive = index == _currentStep;
                    final isCompleted = index < _currentStep;
                    final statusLabel = isCompleted
                        ? 'completed'
                        : isActive
                            ? 'current'
                            : 'upcoming';

                    return Semantics(
                      label: 'Step ${index + 1}: ${_stepTitles[index]}, $statusLabel',
                      child: Container(
                        width: AppSpacing.xl,
                        height: AppSpacing.xl,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryAmber
                              : isCompleted
                                  ? AppColors.success
                                  : AppColors.surfaceInteractive,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  size: AppSpacing.iconSm,
                                  color: AppColors.textOnDark,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isActive
                                        ? AppColors.textOnDark
                                        : AppColors.textMuted,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _stepTitles[_currentStep],
                    style: AppTypography.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildStep(),
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
                      child: Semantics(
                        button: true,
                        label: 'Go to previous step',
                        child: OutlinedButton(
                          onPressed: _currentStep == 0 ? null : _previousStep,
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Semantics(
                        button: true,
                        label: _currentStep < _stepTitles.length - 1
                            ? 'Save and go to next step'
                            : 'Complete safety plan',
                        child: ElevatedButton(
                          onPressed: _saving ? null : _nextStep,
                          child: Text(
                            _currentStep < _stepTitles.length - 1
                                ? 'Save & Next'
                                : 'Complete Safety Plan',
                          ),
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

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _TextEntryStep(
          key: const ValueKey('warningSigns'),
          title: 'Warning Signs',
          description:
              'What thoughts, feelings, or behaviors tell you that you might be at risk?',
          controller: _warningSignsController,
          hintText: 'Enter one warning sign per line',
          suggestions: const [
            'Feeling overwhelmed',
            'Isolating from others',
            'Skipping meetings',
          ],
        );
      case 1:
        return _TextEntryStep(
          key: const ValueKey('copingStrategies'),
          title: 'Coping Strategies',
          description: 'What can you do to cope without using?',
          controller: _copingController,
          hintText: 'Enter one coping strategy per line',
          suggestions: const [
            'Call my sponsor',
            'Go for a walk',
            'Practice deep breathing',
          ],
        );
      case 2:
        return _TextEntryStep(
          key: const ValueKey('supportContacts'),
          title: 'Support Contacts',
          description: 'Who can you call when you are struggling?',
          controller: _supportController,
          hintText: 'Enter one support contact per line',
          suggestions: const [
            'Sponsor: (555) 123-4567',
            'Friend: (555) 987-6543',
          ],
        );
      case 3:
        return _TextEntryStep(
          key: const ValueKey('professionalContacts'),
          title: 'Professional Contacts',
          description: 'Professional resources and hotlines to keep nearby.',
          controller: _professionalController,
          hintText: 'Enter one professional contact per line',
          suggestions: const [
            '988 Suicide & Crisis Lifeline - 988',
            'SAMHSA Helpline - 1-800-662-4357',
          ],
        );
      case 4:
      default:
        return _TextEntryStep(
          key: const ValueKey('safeEnvironments'),
          title: 'Safe Environments',
          description: 'Where can you go to stay safe and grounded?',
          controller: _environmentController,
          hintText: 'Enter one safe environment per line',
          suggestions: const [
            'Local coffee shop',
            'Community center',
            'Friend\'s house',
          ],
          showCompleteButton: true,
        );
    }
  }

  List<String> _splitEntries(String value) {
    return value
        .split(RegExp(r'[\n,;]'))
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  String _joinEntries(List<String> entries) {
    return entries.join('\n');
  }
}

class _TextEntryStep extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final List<String> suggestions;
  final bool showCompleteButton;

  const _TextEntryStep({
    super.key,
    required this.title,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.suggestions,
    this.showCompleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
            ),
            maxLines: 5,
            minLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SuggestionList(
            items: suggestions,
          ),
          if (showCompleteButton) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Changes are saved locally as you move between steps.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<String> items;

  const _SuggestionList({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: AppSpacing.iconSm,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: AppTypography.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
