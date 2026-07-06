import 'package:flutter/material.dart';

class MapControlsColumn extends StatelessWidget {
  final bool isDark;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onChangeMapType;
  final VoidCallback onRecenter;
  final String mapTypeLabel;

  const MapControlsColumn({
    super.key,
    required this.isDark,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onChangeMapType,
    required this.onRecenter,
    required this.mapTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MapControlButton(
          isDark: isDark,
          icon: Icons.add_rounded,
          onTap: onZoomIn,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: 10),
        MapControlButton(
          isDark: isDark,
          icon: Icons.remove_rounded,
          onTap: onZoomOut,
          tooltip: 'Zoom out',
        ),
        const SizedBox(height: 10),
        MapControlButton(
          isDark: isDark,
          icon: Icons.layers_rounded,
          onTap: onChangeMapType,
          tooltip: mapTypeLabel,
        ),
        const SizedBox(height: 10),
        MapControlButton(
          isDark: isDark,
          icon: Icons.my_location_rounded,
          onTap: onRecenter,
          tooltip: 'My location',
        ),
      ],
    );
  }
}

class MapControlButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const MapControlButton({
    super.key,
    required this.isDark,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black87),
        onPressed: onTap,
      ),
    );
  }
}
