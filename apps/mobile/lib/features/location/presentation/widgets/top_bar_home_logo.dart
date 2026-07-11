import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

class TopBarHomeLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const TopBarHomeLogo({
    super.key,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appHomeIcon,
      width: size,
      height: size,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF28243D) : const Color(0xFFE5DEFF),
        ),
        child: Icon(
          Icons.map_rounded,
          color: isDark ? const Color(0xFF8F76FF) : const Color(0xFF7C60FF),
          size: context.w(22),
        ),
      ),
    );
  }
}
