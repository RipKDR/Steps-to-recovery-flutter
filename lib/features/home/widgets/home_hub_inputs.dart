import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../models/home_hub_models.dart';

class InlineMoodSelector extends StatelessWidget {
  const InlineMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
  });

  final int selectedMood;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const moods = <MapEntry<int, String>>[
      MapEntry(1, 'Rough'),
      MapEntry(2, 'Okay'),
      MapEntry(3, 'Steady'),
      MapEntry(4, 'Good'),
      MapEntry(5, 'Strong'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in moods)
          ChoiceChip(
            label: Text(entry.value),
            selected: selectedMood == entry.key,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: AppColors.primaryAmber,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: selectedMood == entry.key
                  ? AppColors.textOnDark
                  : AppColors.textPrimary,
            ),
            side: BorderSide(
              color: selectedMood == entry.key
                  ? AppColors.primaryAmber
                  : AppColors.border,
            ),
          ),
      ],
    );
  }
}

class InlineCravingControl extends StatelessWidget {
  const InlineCravingControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Craving',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '$value/10',
              style: AppTypography.titleMedium.copyWith(
                color: value >= 7
                    ? AppColors.dangerLight
                    : value >= 4
                    ? AppColors.warning
                    : AppColors.successLight,
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
          onChanged: (nextValue) => onChanged(nextValue.round()),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final DailyCardStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color backgroundColor;
    late final Color foregroundColor;

    switch (status) {
      case DailyCardStatus.nextUp:
        backgroundColor = AppColors.primaryAmber;
        foregroundColor = AppColors.textOnDark;
      case DailyCardStatus.laterToday:
        backgroundColor = AppColors.surfaceInteractive;
        foregroundColor = AppColors.textSecondary;
      case DailyCardStatus.doneToday:
        backgroundColor = AppColors.success.withValues(alpha: 0.18);
        foregroundColor = AppColors.successLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelMedium.copyWith(color: foregroundColor),
      ),
    );
  }
}

extension DailyCardStatusLabel on DailyCardStatus {
  String get label {
    switch (this) {
      case DailyCardStatus.nextUp:
        return 'Next up';
      case DailyCardStatus.laterToday:
        return 'Later today';
      case DailyCardStatus.doneToday:
        return 'Done today';
    }
  }
}

String moodLabel(int mood) {
  switch (mood) {
    case 1:
      return 'Rough';
    case 2:
      return 'Okay';
    case 3:
      return 'Steady';
    case 4:
      return 'Good';
    case 5:
      return 'Strong';
    default:
      return 'Steady';
  }
}
