import 'package:flutter/material.dart';

import 'sos_broadcast_entry.dart';

class SosBroadcastTimestamp extends StatelessWidget {
  final SosBroadcastEntry entry;
  final bool isDark;

  const SosBroadcastTimestamp({
    super.key,
    required this.entry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white54 : const Color(0xFF888899);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          entry.date,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          entry.time,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: textColor),
        ),
      ],
    );
  }
}
