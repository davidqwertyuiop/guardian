import 'package:flutter/material.dart';

import 'sos_broadcast_empty.dart';
import 'sos_broadcast_entry.dart';
import 'sos_broadcast_header.dart';
import 'sos_broadcast_tile.dart';

class SosBroadcastCard extends StatelessWidget {
  final List<SosBroadcastEntry> entries;
  final VoidCallback? onSeeAllTap;

  const SosBroadcastCard({super.key, required this.entries, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181D) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE9E9F1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SosBroadcastHeader(onSeeAllTap: onSeeAllTap),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.only(left: 14, bottom: 10),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (entries.isEmpty)
                const SosBroadcastEmpty()
              else
                ...List.generate(entries.length, (index) {
                  return SosBroadcastTile(
                    entry: entries[index],
                    avatarIndex: index,
                    isLast: index == entries.length - 1,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
