import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

/// iOS-specific floating pill tab bar.
/// The active tab expands into a gradient purple pill with icon + label.
/// Inactive tabs are circular dark buttons with an icon (or avatar for profile).
class IosTabBar extends StatelessWidget {
  const IosTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Optional network/local avatar for the profile tab (index 2).
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F21),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tab 0 — Home (active = gradient pill with label)
            _IosHomeTab(
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // Tab 1 — Family / Circle
            _IosIconTab(
              icon: Icons.people_rounded,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Tab 2 — Profile (avatar or icon)
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

// ---------------------------------------------------------------------------
// Home tab — gradient pill with "Home" label when active
// ---------------------------------------------------------------------------
class _IosHomeTab extends StatelessWidget {
  const _IosHomeTab({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFB06AFF), Color(0xFF7C60FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : const Color(0xFF2E2E30),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 20,
              color: Colors.white.withOpacity(isActive ? 1.0 : 0.45),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              const Text(
                'Home',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic icon tab for iOS
// ---------------------------------------------------------------------------
class _IosIconTab extends StatelessWidget {
  const _IosIconTab({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.20)
              : const Color(0xFF2E2E30),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive ? AppColors.primary : Colors.white.withOpacity(0.45),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile tab — shows avatar image if available, else person icon
// ---------------------------------------------------------------------------
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          color: const Color(0xFF2E2E30),
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Icon(
                Icons.person_rounded,
                size: 22,
                color:
                    isActive ? AppColors.primary : Colors.white.withOpacity(0.45),
              )
            : null,
      ),
    );
  }
}
