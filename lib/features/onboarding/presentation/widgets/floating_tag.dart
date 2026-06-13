import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingTag extends StatelessWidget {
  final String text;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double rotation;
  final double fontSize;

  const FloatingTag({
    super.key,
    required this.text,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.rotation,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
