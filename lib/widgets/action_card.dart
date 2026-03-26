import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/haptic_feedback_service.dart';

/// Reusable action card widget
/// Uses gray by default, amber only for primary actions (color restraint)
/// Features AnimatedScale touch feedback and 12dp consistent radius
class ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isPrimary; // If true, uses amber; otherwise gray

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
    _triggerHaptic();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _triggerHaptic() {
    HapticFeedbackService().lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Use amber only for primary actions, gray otherwise
    final color = widget.isPrimary
        ? (widget.iconColor ?? AppColors.primaryAmber)
        : (widget.iconColor ?? AppColors.textSecondary);

    if (reduceMotion) {
      return _buildCard(color);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _controller.value,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
        child: _buildCard(color),
      ),
    );
  }

  Widget _buildCard(Color color) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: AppColors.iconBackgroundAlpha),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: color.withValues(alpha: AppColors.iconBorderAlpha),
                    width: AppSpacing.dividerThickness,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: color,
                  size: AppSpacing.iconLg,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
