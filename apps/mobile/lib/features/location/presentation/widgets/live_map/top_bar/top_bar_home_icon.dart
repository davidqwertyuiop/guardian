import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class TopBarHomeIcon extends StatelessWidget {
  final double size;

  const TopBarHomeIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Transform.translate(
        offset: Offset(context.w(24), 0),
        child: Image.asset(
          AppAssets.appCenterHomeIcon,
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
        ),
      ),
    );
  }
}
