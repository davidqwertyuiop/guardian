import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class TopBarSosText extends StatelessWidget {
  final bool isActive;

  const TopBarSosText({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (isActive) return const _BlinkingSosText();
    return const _SosText();
  }
}

class _BlinkingSosText extends StatefulWidget {
  const _BlinkingSosText();

  @override
  State<_BlinkingSosText> createState() => _BlinkingSosTextState();
}

class _BlinkingSosTextState extends State<_BlinkingSosText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.42,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: const _SosText());
  }
}

class _SosText extends StatelessWidget {
  const _SosText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'SOS',
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: context.sp(14),
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFF3380),
        letterSpacing: 0.5,
      ),
    );
  }
}
