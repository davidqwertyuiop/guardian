import 'package:flutter/material.dart';

class LeaveCircleActionButton extends StatelessWidget {
  const LeaveCircleActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF4F4F5),
        foregroundColor: const Color(0xFFFF2D7A),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: const TextStyle(fontFamily: 'Inter')),
    ),
  );
}

class StayCircleActionButton extends StatelessWidget {
  const StayCircleActionButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: const StadiumBorder(),
      ),
      child: const Text('Stay', style: TextStyle(fontFamily: 'Inter')),
    ),
  );
}
