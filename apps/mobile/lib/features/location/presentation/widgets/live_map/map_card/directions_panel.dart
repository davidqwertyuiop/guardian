import 'package:flutter/material.dart';

import '../../../../domain/models/live_map_models.dart';
import 'directions_place_text.dart';
import 'route_stats.dart';
import 'start_navigation_button.dart';

class DirectionsPanel extends StatelessWidget {
  final SelectedLivePlace place;
  final double distanceKm;
  final int durationMins;
  final bool isDark;
  final VoidCallback onStartNavigation;

  const DirectionsPanel({
    super.key,
    required this.place,
    required this.distanceKm,
    required this.durationMins,
    required this.isDark,
    required this.onStartNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C22).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DirectionsPlaceText(place: place, isDark: isDark),
          const SizedBox(height: 12),
          RouteStats(
            isDark: isDark,
            distanceKm: distanceKm,
            durationMins: durationMins,
          ),
          const SizedBox(height: 14),
          StartNavigationButton(onPressed: onStartNavigation),
        ],
      ),
    );
  }
}
