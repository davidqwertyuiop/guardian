import 'package:flutter/material.dart';

class BroadcastPulseDot extends StatelessWidget {
  final Animation<double> opacity;

  const BroadcastPulseDot({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF00FF66),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
