import 'package:flutter/material.dart';

typedef NotificationTilePalette = ({
  Color accent,
  Color soft,
  IconData leadingIcon,
  IconData statusIcon,
});

NotificationTilePalette notificationTilePalette(String kind, bool isDark) {
  if (kind.startsWith('sos')) {
    return (
      accent: const Color(0xFFFF3B7A),
      soft: const Color(0xFFFF3B7A).withValues(alpha: isDark ? 0.22 : 0.12),
      leadingIcon: Icons.sos_rounded,
      statusIcon: kind == 'sos_cancelled'
          ? Icons.check_rounded
          : Icons.priority_high_rounded,
    );
  }
  if (kind.startsWith('journey')) {
    return (
      accent: const Color(0xFF22C55E),
      soft: const Color(0xFF22C55E).withValues(alpha: isDark ? 0.22 : 0.12),
      leadingIcon: Icons.route_rounded,
      statusIcon: kind == 'journey_stopped'
          ? Icons.check_circle_rounded
          : Icons.navigation_rounded,
    );
  }
  return (
    accent: const Color(0xFF7C60FF),
    soft: const Color(0xFF7C60FF).withValues(alpha: isDark ? 0.22 : 0.12),
    leadingIcon: Icons.notifications_rounded,
    statusIcon: Icons.circle_notifications_rounded,
  );
}
