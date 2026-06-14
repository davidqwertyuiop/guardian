import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class AvatarCluster extends StatelessWidget {
  const AvatarCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Scale the cluster to screen size
    final clusterW = size.width * 0.65;
    final clusterH = clusterW * 0.70;
    final avatarTopSize = clusterW * 0.34;
    final avatarSideSize = clusterW * 0.30;

    final sideBorderColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE2E2E8);

    return SizedBox(
      height: clusterH + 32, // extra space for badge
      width: clusterW,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Avatar
          Positioned(
            left: 0,
            bottom: 20,
            child: _buildAvatar(
              imagePath: AppAssets.avatarLeft,
              size: avatarSideSize,
              borderColor: sideBorderColor,
            ),
          ),

          // Right Avatar
          Positioned(
            right: 0,
            bottom: 24,
            child: _buildAvatar(
              imagePath: AppAssets.avatarRight,
              size: avatarSideSize,
              borderColor: sideBorderColor,
            ),
          ),

          // Top Center Avatar (largest, in front)
          Positioned(
            top: 0,
            child: _buildAvatar(
              imagePath: AppAssets.avatarTop,
              size: avatarTopSize,
              borderColor: Colors.white,
            ),
          ),

          // Location badge beneath top avatar
          Positioned(
            top: avatarTopSize * 0.78,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E22).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1.0,
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
                    "mabushi, FCT",
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

  Widget _buildAvatar({
    required String imagePath,
    required double size,
    required Color borderColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary.withValues(alpha: 0.2),
              child: Icon(
                Icons.person_outline,
                size: size * 0.5,
                color: Colors.white70,
              ),
            );
          },
        ),
      ),
    );
  }
}
