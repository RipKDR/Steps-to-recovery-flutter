import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Standardized filter chip with amber selection styling.
/// Replaces inconsistent custom _FilterChip and raw ChoiceChip usage.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 18) : null,
      selectedColor: AppColors.primaryAmber.withAlpha(40),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? AppColors.primaryAmber : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryAmber : AppColors.border,
      ),
      showCheckmark: false,
    );
  }
}
