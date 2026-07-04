import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onSosTap;
  const TopBar({super.key, required this.onSosTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Notification button (phbell) specs:
    // width: 40, height: 40, padding: 6.4px, gap: 8px
    final double bellSize = context.w(40);
    final double bellPadding = context.w(6.4);

    // Center icon specs:
    // width: 40, height: 40
    final double centerIconSize = context.w(40);

    // SOS button specs:
    // width: 83, height: 40, padding-top/bottom: 4, padding-left/right: 11, gap: 10
    final double sosHeight = context.w(40);
    final double sosPaddingHorizontal = context.w(11);
    final double sosPaddingVertical = context.w(4);
    final double sosGap = context.w(10);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bell icon — circular grey pill
          Container(
            width: bellSize,
            height: bellSize,
            padding: EdgeInsets.all(bellPadding),
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
          ),

          // Centre: Guardian home icon
          Image.asset(
            AppAssets.appHomeIcon,
            width: centerIconSize,
            height: centerIconSize,
            errorBuilder: (_, _, _) => Container(
              width: centerIconSize,
              height: centerIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF28243D)
                    : const Color(0xFFE5DEFF),
              ),
              child: Icon(
                Icons.map_rounded,
                color: isDark
                    ? const Color(0xFF8F76FF)
                    : const Color(0xFF7C60FF),
                size: context.w(22),
              ),
            ),
          ),

          // SOS and grid combined pill
          GestureDetector(
            onTap: onSosTap,
            child: Container(
              height: sosHeight,
              padding: EdgeInsets.symmetric(
                horizontal: sosPaddingHorizontal,
                vertical: sosPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E24)
                    : const Color(0xFFF2F2F5),
                borderRadius: BorderRadius.circular(200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF3380),
                    ),
                  ),
                  SizedBox(width: sosGap),
                  Container(
                    width: context.w(28),
                    height: context.w(28),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3380),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: context.w(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
