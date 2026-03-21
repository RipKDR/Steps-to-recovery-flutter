import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Reusable craving level slider widget
class CravingSlider extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final bool showLabels;

  const CravingSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLabels)
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
                  color: _getColorForValue(),
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
          inactiveColor: AppColors.surfaceInteractive,
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }

  Color _getColorForValue() {
    if (value <= 3) return AppColors.success;
    if (value <= 6) return AppColors.warning;
    return AppColors.danger;
  }
}
