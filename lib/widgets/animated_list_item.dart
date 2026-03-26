import 'package:flutter/material.dart';

/// A reusable widget that provides staggered fade-in and slide animations
/// for list items. Each item animates in with a delay based on its index.
///
/// Respects [MediaQuery.disableAnimations] - shows content instantly if
/// the user has requested reduced motion.
class AnimatedListItem extends StatefulWidget {
  /// The index of this item in the list (used to calculate stagger delay).
  final int index;

  /// The delay in milliseconds between each item's animation start.
  /// Default is 50ms for a smooth, premium feel.
  final int staggerDelay;

  /// The child widget to animate.
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    this.staggerDelay = 50,
    required this.child,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Delay animation based on index for stagger effect
    Future.delayed(
      Duration(milliseconds: widget.index * widget.staggerDelay),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Respect user's accessibility preference for reduced motion
    if (reduceMotion) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
