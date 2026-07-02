import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

/// iOS-specific floating pill tab bar.
/// Active tab expands dynamically into the gradient purple pill.
class IosTabBar extends StatelessWidget {
  const IosTabBar({
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
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.paddingOf(context).bottom > 0
            ? MediaQuery.paddingOf(context).bottom
            : 20,
      ),
      child: Container(
        height: 70,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tab 0 — Home
            _IosTabItem(
              label: 'Home',
              iconPath: 'assets/icons/android/home-icon.png',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            const SizedBox(width: 10), // Spec: gap 10px
            // Tab 1 — Circle
            _IosTabItem(
              label: 'Circle',
              iconPath: 'assets/icons/android/group-icon.png',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 10), // Spec: gap 10px
            // Tab 2 — Profile
            _IosProfileTab(
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

class _IosTabItem extends StatelessWidget {
  const _IosTabItem({
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

class _IosProfileTab extends StatelessWidget {
  const _IosProfileTab({
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
