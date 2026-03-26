import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/haptic_feedback_service.dart';

/// Reusable stat card widget
/// Uses gray by default, amber only for streaks/milestones (color restraint)
/// Features AnimatedScale touch feedback and 12dp consistent radius
class StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  final bool isPrimary; // If true, uses amber; otherwise gray

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
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
    // Use amber only for primary/streak cards, gray otherwise
    final cardColor = widget.isPrimary
        ? (widget.color ?? AppColors.primaryAmber)
        : (widget.color ?? AppColors.textSecondary);

    if (reduceMotion) {
      return _buildCard(cardColor);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _controller.value,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
        child: _buildCard(cardColor),
      ),
    );
  }

  Widget _buildCard(Color cardColor) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: AppColors.iconBackgroundAlpha),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: cardColor.withValues(alpha: AppColors.iconBorderAlpha),
                    width: AppSpacing.dividerThickness,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: cardColor,
                  size: AppSpacing.iconLg,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.value,
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
