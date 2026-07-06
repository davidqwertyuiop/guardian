import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'broadcast_countdown_text.dart';
import 'broadcast_pulse_dot.dart';

class BroadcastStatusBanner extends StatefulWidget {
  final JourneyState journeyState;

  const BroadcastStatusBanner({super.key, required this.journeyState});

  @override
  State<BroadcastStatusBanner> createState() => _BroadcastStatusBannerState();
}

class _BroadcastStatusBannerState extends State<BroadcastStatusBanner>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _pulseOpacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant BroadcastStatusBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journeyState.startTime != widget.journeyState.startTime ||
        oldWidget.journeyState.durationMinutes !=
            widget.journeyState.durationMinutes) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF99000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BroadcastPulseDot(opacity: _pulseOpacity),
          const SizedBox(width: 8),
          Flexible(child: BroadcastCountdownText(text: _remainingText())),
        ],
      ),
    );
  }

  String _remainingText() {
    final now = DateTime.now();
    final start = widget.journeyState.startTime ?? now;
    final duration = widget.journeyState.durationMinutes ?? 30;
    final remaining = start.add(Duration(minutes: duration)).difference(now);
    if (remaining.isNegative || remaining.inSeconds <= 0) return 'completed';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} min remaining';
  }
}
