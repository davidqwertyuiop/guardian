import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class BroadcastControls extends StatelessWidget {
  final JourneyState journeyState;
  final VoidCallback onStopPressed;
  final EdgeInsetsGeometry padding;

  const BroadcastControls({
    super.key,
    required this.journeyState,
    required this.onStopPressed,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BroadcastStatusBanner(journeyState: journeyState),
          const SizedBox(height: 12),
          StopBroadcastButton(onPressed: onStopPressed),
        ],
      ),
    );
  }
}

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
          FadeTransition(
            opacity: _pulseOpacity,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF00FF66),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Broadcasting - ${_remainingText()}',
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
            ),
          ),
        ],
      ),
    );
  }

  String _remainingText() {
    final now = DateTime.now();
    final start = widget.journeyState.startTime ?? now;
    final duration = widget.journeyState.durationMinutes ?? 30;
    final endsAt = start.add(Duration(minutes: duration));
    final remaining = endsAt.difference(now);

    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return 'completed';
    }

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    if (minutes >= 1) {
      return '$minutes:${seconds.toString().padLeft(2, '0')} min remaining';
    }
    return '0:${seconds.toString().padLeft(2, '0')} min remaining';
  }
}

class StopBroadcastButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StopBroadcastButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'Stop',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
