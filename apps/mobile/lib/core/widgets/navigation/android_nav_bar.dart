import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

/// Android-specific floating pill navigation bar.
/// Matches the custom dark capsule design with 3 tabs and gradient highlights.
class AndroidNavBar extends StatelessWidget {
  const AndroidNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF333333), // Dark grey bar as in design image
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tab 0 — Home
            _AndroidTabItem(
              label: 'Home',
              iconPath: 'assets/icons/android/home-icon.png',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // Tab 1 — Circle
            _AndroidTabItem(
              label: 'Circle',
              iconPath: 'assets/icons/android/group-icon.png',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Tab 2 — Profile
            _AndroidProfileTab(
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
              imageUrl: profileImageUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidTabItem extends StatelessWidget {
  const _AndroidTabItem({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 50, // Spec: height 50
        width: isActive ? 103 : 50, // Spec: width 103 for active, circular 50 for inactive
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), // Spec: padding
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: AppColors.navBarGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : const Color(0xFF444446),
          borderRadius: BorderRadius.circular(40), // Spec: border-radius 40
          border: !isActive
              ? Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1)
              : null,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: isActive ? 71 : 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  color: Colors.white,
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AndroidProfileTab extends StatelessWidget {
  const _AndroidProfileTab({
    required this.isActive,
    required this.onTap,
    this.imageUrl,
  });

  final bool isActive;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 50, // Spec: height 50
        width: isActive ? 103 : 50, // Spec: width 103 for active, circular 50 for inactive
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), // Spec: padding
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: AppColors.navBarGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : const Color(0xFF444446),
          borderRadius: BorderRadius.circular(40), // Spec: border-radius 40
          border: !isActive
              ? Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1)
              : null,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: isActive ? 71 : 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl!,
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/android/profile.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
