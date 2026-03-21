import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Before You Use screen - 5-minute intervention when craving hits
class BeforeYouUseScreen extends StatefulWidget {
  const BeforeYouUseScreen({super.key});

  @override
  State<BeforeYouUseScreen> createState() => _BeforeYouUseScreenState();
}

class _BeforeYouUseScreenState extends State<BeforeYouUseScreen> {
  int _secondsRemaining = 300; // 5 minutes
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Before You Use'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.warning,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Warning message
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Text(
                  'Take 5 minutes before making any decisions. A craving is like a wave - it will pass.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Timer display
            Semantics(
              label: 'Timer: $minutes minutes and $seconds seconds remaining',
              liveRegion: true,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.warning,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          minutes.toString().padLeft(2, '0'),
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.warning,
                            fontSize: 64,
                          ),
                        ),
                        Text(
                          ':',
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          seconds.toString().padLeft(2, '0'),
                          style: AppTypography.displayLarge.copyWith(
                            color: AppColors.warning,
                            fontSize: 64,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Breathing guide
            if (_isRunning) ...[
              Text(
                'Breathe slowly and deeply',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _BreathingCircle(),
            ],

            const Spacer(),

            // Control buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('I\'m Okay'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? _pause : _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: AppColors.textOnDark,
                    ),
                    child: Text(_isRunning ? 'Pause' : 'Start Timer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Semantics(
                button: true,
                label: 'Call for help',
                child: ElevatedButton(
                  onPressed: () {
                    // Call for help
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.textOnDark,
                  ),
                  child: const Text('Call for Help'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _pause();
      }
    });
  }

  void _pause() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }
}

class _BreathingCircle extends StatefulWidget {
  const _BreathingCircle();

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = 'Breathe In';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = 'Breathe Out');
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = 'Breathe In');
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

    if (reduceMotion) {
      return Semantics(
        liveRegion: true,
        label: 'Breathing guide: $_instruction',
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primaryAmber.withValues(alpha: 0.3),
                AppColors.primaryAmber.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(
            child: Text(
              _instruction,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primaryAmber,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      label: 'Breathing guide: $_instruction',
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 150 * _animation.value,
            height: 150 * _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryAmber.withValues(alpha: 0.3 * _animation.value),
                  AppColors.primaryAmber.withValues(alpha: 0.1 * _animation.value),
                ],
              ),
            ),
            child: Center(
              child: Text(
                _instruction,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryAmber,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
