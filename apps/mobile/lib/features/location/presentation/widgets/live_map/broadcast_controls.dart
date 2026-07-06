import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'broadcast_controls/broadcast_status_banner.dart';
import 'broadcast_controls/stop_broadcast_button.dart';

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
