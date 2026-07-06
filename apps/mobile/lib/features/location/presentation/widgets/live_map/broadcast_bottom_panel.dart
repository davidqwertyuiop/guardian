import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'broadcast_circle_card.dart';
import 'broadcast_controls.dart';

class BroadcastBottomPanel extends StatelessWidget {
  final JourneyState journeyState;
  final String circleName;
  final List<dynamic> members;
  final double height;
  final ValueChanged<double> onDragDelta;
  final VoidCallback onStopPressed;
  final VoidCallback onSeeMore;

  const BroadcastBottomPanel({
    super.key,
    required this.journeyState,
    required this.circleName,
    required this.members,
    required this.height,
    required this.onDragDelta,
    required this.onStopPressed,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF111116) : Colors.white;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) => onDragDelta(details.delta.dy),
            child: Padding(
              padding: EdgeInsets.only(
                top: context.w(10),
                bottom: context.w(8),
              ),
              child: Container(
                width: context.w(48),
                height: context.w(5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BroadcastControls(
                    journeyState: journeyState,
                    onStopPressed: onStopPressed,
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                  ),
                  const SizedBox(height: 14),
                  BroadcastCircleCard(
                    circleName: circleName,
                    members: members,
                    onSeeMore: onSeeMore,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
