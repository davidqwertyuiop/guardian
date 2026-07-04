import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';

import 'package:intl/intl.dart';

class SosBroadcastsSection extends StatelessWidget {
  final List<dynamic> broadcasts;
  final VoidCallback? onSeeAllTap;

  const SosBroadcastsSection({
    super.key,
    required this.broadcasts,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Image.asset(
                AppAssets.sosBroadcastIcon,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF3355FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'SOS Broadcasts',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3355FF),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAllTap,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Date group label
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
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

        // Broadcast list
        if (broadcasts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'No SOS broadcasts in this circle.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF888899),
              ),
            ),
          )
        else
          ...List.generate(broadcasts.length, (i) {
            final b = broadcasts[i];
            
            // Expected backend fields: user_name, last_known_location, created_at
            final name = b['user_name'] as String? ?? 'Unknown Member';
            final loc = b['last_known_location'] as String? ?? 'Unknown Location';
            
            String dateStr = 'Unknown';
            String timeStr = 'Unknown';
            final createdAt = b['created_at'] as String?;
            if (createdAt != null) {
              try {
                final dt = DateTime.parse(createdAt).toLocal();
                dateStr = DateFormat('MM/dd/yyyy').format(dt);
                timeStr = DateFormat('h:mma').format(dt);
              } catch (_) {}
            }

            return _BroadcastTile(
              name: name,
              location: loc,
              date: dateStr,
              time: timeStr,
              avatarIndex: i,
            );
          }),
      ],
    );
  }
}

class _BroadcastTile extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String time;
  final int avatarIndex;

  const _BroadcastTile({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.avatarIndex,
  });

  static const _avatarAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final asset = avatarIndex < _avatarAssets.length
        ? _avatarAssets[avatarIndex]
        : _avatarAssets[0];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Row(
        children: [
          // Circular avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF888899),
                  ),
                ),
              ],
            ),
          ),

          // Date + time (right-aligned)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
