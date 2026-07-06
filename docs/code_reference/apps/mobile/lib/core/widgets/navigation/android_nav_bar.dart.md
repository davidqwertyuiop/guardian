# android_nav_bar.dart

* **File Path:** `apps/mobile/lib/core/widgets/navigation/android_nav_bar.dart`
* **Type:** `DART`

---

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';

/// Android navigation bar — floating glassmorphism capsule.
/// Active tab expands to a gradient pill with label; inactive tabs show circular icon.
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Squared edges
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000), // #00000040
                  blurRadius: 6.1,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Squared edges
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x99000000), // #00000099
                    borderRadius: BorderRadius.circular(20), // Squared edges
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tab 0 — Home
                      _NavItem(
                        label: 'Home',
                        iconPath: AppAssets.appHomeIcon,
                        fallbackIcon: Icons.home_rounded,
                        isActive: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      const SizedBox(width: 8),
                      // Tab 1 — Circle
                      _NavItem(
                        label: 'Circle',
                        iconPath: AppAssets.appCirclesIcon,
                        fallbackIcon: Icons.people_rounded,
                        isActive: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),
                      const SizedBox(width: 8),
                      // Tab 2 — Profile
                      _ProfileNavItem(
                        isActive: currentIndex == 2,
                        onTap: () => onTap(2),
                        imageUrl: profileImageUrl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Standard Nav Item ────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.fallbackIcon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String iconPath;
  final IconData fallbackIcon;
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
        height: 48,
        width: isActive ? 116 : 48,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 0,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: AppColors.navBarGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(40),
          border: isActive
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  color: Colors.white,
                  errorBuilder: (_, _, _) =>
                      Icon(fallbackIcon, size: 22, color: Colors.white),
                ),
                if (isActive) ...[
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

// ─── Profile Nav Item ─────────────────────────────────────────────────────────

class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
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
        height: 48,
        width: isActive ? 116 : 48,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 0,
          vertical: 0,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: AppColors.navBarGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(40),
          border: isActive
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _AvatarCircle(imageUrl: imageUrl, isActive: isActive),
                if (isActive) ...[
                  const SizedBox(width: 7),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.imageUrl, required this.isActive});
  final String? imageUrl;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: isActive ? 0.9 : 0.4),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _defaultAvatar(),
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() => Container(
    color: AppColors.primary.withValues(alpha: 0.3),
    child: const Icon(Icons.person, size: 16, color: Colors.white),
  );
}

```
