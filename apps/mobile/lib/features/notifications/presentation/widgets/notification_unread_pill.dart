import 'package:flutter/material.dart';

class NotificationUnreadPill extends StatelessWidget {
  const NotificationUnreadPill({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count == 0
        ? 'No new notifications'
        : '$count new notifications';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7C60FF).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          color: Color(0xFF7C60FF),
        ),
      ),
    );
  }
}
