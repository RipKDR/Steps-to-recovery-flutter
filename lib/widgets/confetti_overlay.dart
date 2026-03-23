import 'dart:math';

import 'package:flutter/material.dart';

/// A confetti celebration overlay for recovery milestones.
///
/// Usage:
/// ```dart
/// final controller = ConfettiController();
/// ConfettiOverlay(controller: controller, child: myWidget);
/// controller.fire(); // trigger celebration
/// ```
class ConfettiController extends ChangeNotifier {
  bool _active = false;
  bool get active => _active;

  void fire() {
    _active = true;
    notifyListeners();
  }

  void stop() {
    _active = false;
    notifyListeners();
  }
}

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  final ConfettiController controller;
  final Widget child;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.controller.stop();
        }
      });

    widget.controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (widget.controller.active) {
      _spawnParticles();
      _animController.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const colors = [
      Color(0xFFFFB300), // amber
      Color(0xFFFFC107), // amber light
      Color(0xFFFF8F00), // amber dark
      Color(0xFFFFD54F), // amber accent
      Color(0xFFFFE082), // amber 200
    ];
    for (var i = 0; i < 60; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.4,
        vy: _random.nextDouble() * 0.6 + 0.3,
        size: _random.nextDouble() * 6 + 3,
        color: colors[_random.nextInt(colors.length)],
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4,
      ));
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Stack(
      children: [
        widget.child,
        if (widget.controller.active && !reduceMotion)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _animController.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;

  const _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final x = (p.x + p.vx * progress) * size.width;
      final y = (p.y + p.vy * progress) * size.height;
      final rot = p.rotation + p.rotationSpeed * progress;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
