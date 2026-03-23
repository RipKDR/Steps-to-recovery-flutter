import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Premium frosted glass card with subtle blur effect.
/// Use sparingly on key surfaces: home dashboard, milestones, profile header.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppSpacing.radiusXl,
    this.blur = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: reduceMotion
          ? _solidFallback()
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: _glassContainer(),
            ),
    );
  }

  Widget _glassContainer() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.glassBorder,
          width: AppSpacing.dividerThickness,
        ),
      ),
      child: child,
    );
  }

  Widget _solidFallback() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.dividerThickness,
        ),
      ),
      child: child,
    );
  }
}
