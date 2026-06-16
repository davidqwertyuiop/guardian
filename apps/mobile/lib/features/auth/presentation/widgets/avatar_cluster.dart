import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import 'avatar_item.dart';

class AvatarCluster extends StatelessWidget {
  const AvatarCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final clusterW = size.width * 0.65;
    final clusterH = clusterW * 0.70;
    final topSize = clusterW * 0.34;
    final sideSize = clusterW * 0.30;
    final sideColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE2E2E8);

    return SizedBox(
      height: clusterH + 32,
      width: clusterW,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            bottom: 20,
            child: AvatarItem(
              imagePath: AppAssets.avatarLeft,
              size: sideSize,
              borderColor: sideColor,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 24,
            child: AvatarItem(
              imagePath: AppAssets.avatarRight,
              size: sideSize,
              borderColor: sideColor,
            ),
          ),
          Positioned(
            top: 0,
            child: AvatarItem(
              imagePath: AppAssets.avatarTop,
              size: topSize,
              borderColor: Colors.white,
            ),
          ),
          Positioned(
            top: topSize * 0.78,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E22).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Mabushi, FCT",
                    style: GoogleFonts.inter(
                      fontSize: size.width * 0.03,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.95)
                          : Colors.black87,
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
