import 'package:flutter/material.dart';

class BroadcastCountdownText extends StatelessWidget {
  final String text;

  const BroadcastCountdownText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Broadcasting - $text',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
        color: Colors.white,
      ),
    );
  }
}
