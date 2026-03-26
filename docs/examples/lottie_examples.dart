// Example: Using Lottie for animations
// Perfect for milestone celebrations, achievements, and loading states

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Celebration animation widget
/// 
/// Usage:
/// ```dart
/// CelebrationAnimation(animationType: CelebrationType.milestone)
/// ```
class CelebrationAnimation extends StatefulWidget {
  final CelebrationType animationType;
  final double width;
  final double height;
  final bool repeat;

  const CelebrationAnimation({
    super.key,
    required this.animationType,
    this.width = 200,
    this.height = 200,
    this.repeat = false,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _getAnimationPath(),
      width: widget.width,
      height: widget.height,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
      },
    );
  }

  String _getAnimationPath() {
    switch (widget.animationType) {
      case CelebrationType.milestone:
        return 'assets/animations/milestone.json';
      case CelebrationType.achievement:
        return 'assets/animations/achievement.json';
      case CelebrationType.success:
        return 'assets/animations/success.json';
      case CelebrationType.loading:
        return 'assets/animations/loading.json';
      case CelebrationType.confetti:
        return 'assets/animations/confetti.json';
    }
  }
}

/// Types of celebration animations
enum CelebrationType {
  milestone,    // Sobriety milestones (30, 60, 90 days)
  achievement,  // Step completions, challenges
  success,      // General success feedback
  loading,      // Loading states
  confetti,     // Celebration overlay
}

/// Reusable success animation overlay
class SuccessOverlay extends StatelessWidget {
  final VoidCallback? onComplete;

  const SuccessOverlay({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dim background
        Container(
          color: Colors.black54,
        ),
        // Animation
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/success.json',
              width: 250,
              height: 250,
              repeat: false,
              onLoaded: (composition) {
                // Auto-dismiss after animation completes
                Future.delayed(composition.duration, () {
                  if (onComplete != null) {
                    onComplete!();
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Great job! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Loading indicator with Lottie
class LottieLoadingIndicator extends StatelessWidget {
  final String? message;

  const LottieLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/loading.json',
          width: 150,
          height: 150,
          repeat: true,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }
}

// Example usage in a screen:
//
// // Show celebration for milestone
// showDialog(
//   context: context,
//   barrierDismissible: false,
//   builder: (context) => SuccessOverlay(
//     onComplete: () => Navigator.of(context).pop(),
//   ),
// );
//
// // Use in a list for achievements
// ListView.builder(
//   itemCount: achievements.length,
//   itemBuilder: (context, index) {
//     return AchievementCard(
//       achievement: achievements[index],
//       onAnimationComplete: () {
//         // Trigger next animation
//       },
//     );
//   },
// );
