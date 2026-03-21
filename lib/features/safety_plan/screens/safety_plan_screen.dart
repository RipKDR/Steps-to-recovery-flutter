import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Safety Plan screen - Personal safety plan builder
class SafetyPlanScreen extends StatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  State<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends State<SafetyPlanScreen> {
  int _currentStep = 0;
  final _warningSignsController = TextEditingController();
  final _copingController = TextEditingController();
  final _supportController = TextEditingController();
  final _professionalController = TextEditingController();
  final _environmentController = TextEditingController();

  final List<String> _warningSigns = [];
  final List<String> _copingStrategies = [];
  final List<String> _supportContacts = [];
  final List<String> _professionalContacts = [];
  final List<String> _safeEnvironments = [];

  @override
  void dispose() {
    _warningSignsController.dispose();
    _copingController.dispose();
    _supportController.dispose();
    _professionalController.dispose();
    _environmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Plan'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: AppColors.surfaceInteractive,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryAmber,
            ),
          ),
          
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                
                return Container(
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
                );
              }),
            ),
          ),
          
          // Content
          Expanded(
            child: _buildStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _WarningSignsStep();
      case 1:
        return _CopingStrategiesStep();
      case 2:
        return _SupportContactsStep();
      case 3:
        return _ProfessionalContactsStep();
      case 4:
        return _SafeEnvironmentsStep();
      default:
        return const SizedBox();
    }
  }
}

class _WarningSignsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Warning Signs',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What thoughts, feelings, or behaviors tell you that you might be at risk?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Add a warning sign...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlaceholderList(items: [
            'Feeling overwhelmed',
            'Isolating from others',
            'Not attending meetings',
          ]),
        ],
      ),
    );
  }
}

class _CopingStrategiesStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coping Strategies',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'What can you do to cope without using?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Add a coping strategy...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlaceholderList(items: [
            'Call my sponsor',
            'Go for a walk',
            'Practice deep breathing',
          ]),
        ],
      ),
    );
  }
}

class _SupportContactsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Contacts',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Who can you call when you\'re struggling?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Add a support contact...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlaceholderList(items: [
            'Sponsor: (555) 123-4567',
            'Friend: (555) 987-6543',
          ]),
        ],
      ),
    );
  }
}

class _ProfessionalContactsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Contacts',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Professional resources and hotlines',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ContactCard(
            name: '988 Suicide & Crisis Lifeline',
            phone: '988',
          ),
          const SizedBox(height: AppSpacing.md),
          _ContactCard(
            name: 'SAMHSA Helpline',
            phone: '1-800-662-4357',
          ),
        ],
      ),
    );
  }
}

class _SafeEnvironmentsStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Safe Environments',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Where can you go to stay safe?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Add a safe environment...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PlaceholderList(items: [
            'Local coffee shop',
            'Community center',
            'Friend\'s house',
          ]),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Complete Safety Plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderList extends StatelessWidget {
  final List<String> items;

  const _PlaceholderList({required this.items});

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
              Text(
                item,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String phone;

  const _ContactCard({
    required this.name,
    required this.phone,
  });

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
          const Icon(
            Icons.phone,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  phone,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primaryAmber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
