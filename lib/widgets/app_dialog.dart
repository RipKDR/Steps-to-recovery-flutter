import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Show a styled dialog with consistent Material 3 theming.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: content,
      actions: actions,
    ),
  );
}

/// Show a simple confirm/cancel dialog.
/// Returns true if confirmed, false/null if cancelled.
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDangerous = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDangerous
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Show a styled bottom sheet with consistent theming.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
        ),
        child: child,
      ),
    ),
  );
}
