import 'package:flutter/material.dart';

/// Amber gradient ring badge displaying a milestone [emoji].
class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({super.key, required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
            ),
          ),
        ),
        Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF121212),
          ),
        ),
        Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ],
    );
  }
}
