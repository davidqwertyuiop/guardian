import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class MapDistanceBadge extends StatelessWidget {
  final Map<String, dynamic>? nearestMember;

  const MapDistanceBadge({super.key, this.nearestMember});

  @override
  Widget build(BuildContext context) {
    String text = 'Finding nearby...';
    if (nearestMember != null) {
      final dist = nearestMember!['distance_km'] as double? ?? 0.0;
      final time = nearestMember!['duration_mins'] as int? ?? 0;
      final name = nearestMember!['name'] as String? ?? 'Member';
      text = '$name is ${dist.toStringAsFixed(1)} km away • $time mins';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.worldMap,
            width: 13,
            height: 13,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.public, size: 13, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
