import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Morning Intention screen - Set daily intention and mood
class MorningIntentionScreen extends StatefulWidget {
  const MorningIntentionScreen({super.key});

  @override
  State<MorningIntentionScreen> createState() => _MorningIntentionScreenState();
}

class _MorningIntentionScreenState extends State<MorningIntentionScreen> {
  final _intentionController = TextEditingController();
  int _selectedMood = 3;

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Intention'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling this morning?',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Mood selector
            _MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Text(
              'What is your intention for today?',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _intentionController,
              maxLines: 4,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Today, I intend to...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
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
                child: const Text('Save Intention'),
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
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryAmber
                        : AppColors.border,
                  ),
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
                _getMoodLabel(mood),
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

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Rough';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Amazing';
      default:
        return '';
    }
  }
}
