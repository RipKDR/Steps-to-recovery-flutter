import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/haptic_feedback_service.dart';

/// Reusable mood rating widget
/// Features haptic feedback on selection for tactile response
class MoodRating extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;
  final bool showLabels;

  const MoodRating({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final mood = index + 1;
        final isSelected = selectedMood == mood;

        return Semantics(
          button: true,
          label: 'Mood ${_getMoodLabel(mood)}',
          selected: isSelected,
          child: InkWell(
            onTap: () {
              onMoodSelected(mood);
              // Trigger haptic feedback on mood selection
              HapticFeedbackService().selectionClick();
            },
            customBorder: const CircleBorder(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                    size: AppSpacing.iconMd,
                  ),
                ),
                if (showLabels) ...[
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
              ],
            ),
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
