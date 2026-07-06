import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';

import 'sos_broadcast_entry.dart';
import 'sos_broadcast_summary.dart';
import 'sos_broadcast_timestamp.dart';

class SosBroadcastTile extends StatelessWidget {
  final SosBroadcastEntry entry;
  final int avatarIndex;
  final bool isLast;

  const SosBroadcastTile({
    super.key,
    required this.entry,
    required this.avatarIndex,
    required this.isLast,
  });

  static const _avatarAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          _BroadcastAvatar(
            avatarIndex: avatarIndex,
            avatarUrl: entry.avatarUrl,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SosBroadcastSummary(entry: entry, isDark: isDark),
          ),
          SosBroadcastTimestamp(entry: entry, isDark: isDark),
        ],
      ),
    );
  }
}

class _BroadcastAvatar extends StatelessWidget {
  final int avatarIndex;
  final String? avatarUrl;
  final bool isDark;

  const _BroadcastAvatar({
    required this.avatarIndex,
    required this.avatarUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final asset = avatarIndex < SosBroadcastTile._avatarAssets.length
        ? SosBroadcastTile._avatarAssets[avatarIndex]
        : SosBroadcastTile._avatarAssets[0];

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white12 : Colors.grey.shade200,
        image: DecorationImage(
          image: avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : AssetImage(asset) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
