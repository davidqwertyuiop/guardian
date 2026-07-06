# avatar_cluster.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/avatar_cluster.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import 'avatar_item.dart';

class AvatarCluster extends StatelessWidget {
  const AvatarCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Exact sizing and offsets matching the design reference image
    const double containerW = 220.0;
    const double containerH = 180.0;

    const double leftAvatarSize = 108.0;
    const double topAvatarSize = 74.0;
    const double rightAvatarSize = 82.0;

    final sideColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE2E2E8);

    return SizedBox(
      height: containerH,
      width: containerW,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Right Avatar ( Bald woman, microphone, blue top ) - Background
          Positioned(
            right: 20,
            bottom: 30,
            child: AvatarItem(
              imagePath: AppAssets.avatarLeft,
              size: rightAvatarSize,
              borderColor: sideColor,
            ),
          ),
          // 2. Top Avatar ( Person in parka hood ) - Middle
          Positioned(
            left: 64,
            top: 4,
            child: AvatarItem(
              imagePath: AppAssets.avatarRight,
              size: topAvatarSize,
              borderColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            ),
          ),
          // 3. Left Avatar ( Curly hair, green top ) - Foreground (Largest)
          Positioned(
            left: 0,
            bottom: 10,
            child: AvatarItem(
              imagePath: AppAssets.avatarTop,
              size: leftAvatarSize,
              borderColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            ),
          ),
          // 4. Rotated glassmorphic badge "mabushi, FCT" (lowercase) - Foreground Overlay
          Positioned(
            left: 48,
            top: 58,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "mabushi, FCT",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```
