import 'package:flutter/material.dart';

import 'sos_broadcast_entry.dart';

class SosBroadcastSummary extends StatelessWidget {
  final SosBroadcastEntry entry;
  final bool isDark;

  const SosBroadcastSummary({
    super.key,
    required this.entry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.name,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          entry.location,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isDark ? Colors.white60 : const Color(0xFF888899),
          ),
        ),
      ],
    );
  }
}
