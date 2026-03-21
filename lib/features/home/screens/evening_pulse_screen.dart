import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Evening Pulse screen - Evening reflection and check-in
class EveningPulseScreen extends StatefulWidget {
  const EveningPulseScreen({super.key});

  @override
  State<EveningPulseScreen> createState() => _EveningPulseScreenState();
}

class _EveningPulseScreenState extends State<EveningPulseScreen> {
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  int _selectedMood = 3;
  int _selectedCraving = 0;

  @override
  void dispose() {
    _reflectionController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evening Pulse'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your day?',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Mood selector
            _MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Craving level
            Text(
              'Craving level (0-10)',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _CravingSlider(
              value: _selectedCraving,
              onChanged: (value) => setState(() => _selectedCraving = value),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Text(
              'What are you grateful for today?',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _gratitudeController,
              maxLines: 2,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'I am grateful for...',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            Text(
              'Reflection on the day',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _reflectionController,
              maxLines: 5,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'What went well? What could be better?',
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save check-in
                  Navigator.pop(context);
                },
                child: const Text('Save Reflection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  final int selectedMood;
  final Function(int) onMoodSelected;

  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final mood = index + 1;
        final isSelected = selectedMood == mood;
        
        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: Column(
            children: [
              Container(
                width: AppSpacing.quint,
                height: AppSpacing.quint,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryAmber
                      : AppColors.surfaceInteractive,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getMoodIcon(mood),
                  color: isSelected
                      ? AppColors.textOnDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$mood',
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.primaryAmber
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

class _CravingSlider extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const _CravingSlider({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'None',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '$value',
              style: AppTypography.headlineMedium.copyWith(
                color: value > 7
                    ? AppColors.danger
                    : value > 4
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ),
            Text(
              'Severe',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.primaryAmber,
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
