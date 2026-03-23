import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Craving Surf screen - Guided breathing exercise for riding out cravings
class CravingSurfScreen extends StatefulWidget {
  const CravingSurfScreen({super.key});

  @override
  State<CravingSurfScreen> createState() => _CravingSurfScreenState();
}

class _CravingSurfScreenState extends State<CravingSurfScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = 'Breathe In';
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.lightImpact();
        setState(() {
          _instruction = 'Breathe Out';
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        HapticFeedback.lightImpact();
        setState(() {
          _instruction = 'Breathe In';
          _breathCount++;
        });
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Craving Surf'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Instruction
            Semantics(
              header: true,
              child: Text(
                'Ride the wave',
                style: AppTypography.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cravings are like waves - they build, peak, and pass',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Animated wave
            Expanded(
              child: Center(
                child: reduceMotion
                    ? _buildStaticBreathingCircle()
                    : _buildAnimatedBreathingCircle(),
              ),
            ),

            // Tips
            Semantics(
              label: 'Reminders: This feeling will pass. You have survived every craving before. Focus on your breath. Reach out if you need support.',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remember:',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _TipRow(tip: 'This feeling will pass'),
                    const _TipRow(tip: 'You\'ve survived every craving before'),
                    const _TipRow(tip: 'Focus on your breath'),
                    const _TipRow(tip: 'Reach out if you need support'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('I Feel Better'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticBreathingCircle() {
    return Semantics(
      liveRegion: true,
      label: 'Breathing guide: $_instruction. Breath count: $_breathCount',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryAmber.withValues(alpha: 0.4),
                  AppColors.primaryAmber.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Text(
                _instruction,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primaryAmber,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Breath $_breathCount',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBreathingCircle() {
    return Semantics(
      liveRegion: true,
      label: 'Breathing guide: $_instruction. Breath count: $_breathCount',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200 * _animation.value,
                height: 200 * _animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryAmber.withValues(alpha: 0.4),
                      AppColors.primaryAmber.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _instruction,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Breath $_breathCount',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String tip;

  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(
              Icons.check_circle,
              size: AppSpacing.iconSm,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
