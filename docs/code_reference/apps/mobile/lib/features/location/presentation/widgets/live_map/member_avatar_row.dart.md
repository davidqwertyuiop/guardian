# member_avatar_row.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/live_map/member_avatar_row.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class MemberAvatarRow extends StatelessWidget {
  final List<dynamic> members;
  const MemberAvatarRow({super.key, required this.members});

  static const _fallbackColors = [
    Color(0xFFF48FB1), // pink / floral
    Color(0xFF1565C0), // blue flag
  ];

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayCount = members.length.clamp(1, 4);
    final double avatarSize = context.w(32);
    final double overlap = context.w(10);

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (displayCount - 1) * (avatarSize - overlap),
      child: Stack(
        children: List.generate(displayCount, (i) {
          final String? url =
              (members[i] as Map<String, dynamic>)['avatar_url'] as String?;
          final bool hasUrl = url != null && url.isNotEmpty;
          final String fallbackAsset = i < _fallbackAssets.length
              ? _fallbackAssets[i]
              : _fallbackAssets[0];
          final Color fallbackColor = i < _fallbackColors.length
              ? _fallbackColors[i]
              : _fallbackColors[0];

          return Positioned(
            left: i * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fallbackColor,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: hasUrl
                      ? NetworkImage(url) as ImageProvider
                      : AssetImage(fallbackAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

```
