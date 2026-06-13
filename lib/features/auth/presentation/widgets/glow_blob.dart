import 'package:flutter/material.dart';

class GlowBlob extends StatelessWidget {
  final Color color;
  final double top;
  final double? left;
  final double? right;
  final double size;

  const GlowBlob({
    super.key,
    required this.color,
    required this.top,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 50,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
