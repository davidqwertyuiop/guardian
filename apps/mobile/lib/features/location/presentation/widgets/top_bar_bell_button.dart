import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

class TopBarBellButton extends StatelessWidget {
  final double size;
  final double padding;
  final bool isDark;

  const TopBarBellButton({
    super.key,
    required this.size,
    required this.padding,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF2F2F5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          AppAssets.phBell,
          errorBuilder: (_, _, _) => Icon(
            Icons.notifications_none_rounded,
            size: context.w(20),
            color: isDark ? Colors.white70 : const Color(0xFF555566),
          ),
        ),
      ),
    );
  }
}
