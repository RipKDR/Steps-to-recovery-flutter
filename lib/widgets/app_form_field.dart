import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

/// Standardized form field with label, consistent spacing, and styling.
/// Replaces repetitive label + TextField / TextFormField groups.
class AppFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final int maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;

  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          ),
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
        ),
      ],
    );
  }
}
