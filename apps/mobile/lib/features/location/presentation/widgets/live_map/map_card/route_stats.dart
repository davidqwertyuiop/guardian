import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class RouteStats extends StatelessWidget {
  final bool isDark;
  final double distanceKm;
  final int durationMins;

  const RouteStats({
    super.key,
    required this.isDark,
    required this.distanceKm,
    required this.durationMins,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RouteStatIcon(
          isDark: isDark,
          icon: Icons.directions_car_rounded,
          label: '${distanceKm.toStringAsFixed(1)} km',
        ),
        const SizedBox(width: 24),
        RouteStatIcon(
          isDark: isDark,
          icon: Icons.access_time_filled_rounded,
          label: '$durationMins mins',
        ),
      ],
    );
  }
}

class RouteStatIcon extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;

  const RouteStatIcon({
    super.key,
    required this.isDark,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
