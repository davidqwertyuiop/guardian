# circle_card.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/circle_card.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';

class CircleCard extends StatelessWidget {
  final String circleName;
  final List<dynamic> members;
  const CircleCard({
    super.key,
    required this.circleName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final count = members.isNotEmpty ? members.length : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 168,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white, // Outer container background
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left column: count label + circle name + circular member avatars
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count members',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF999AB0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      circleName.isNotEmpty
                          ? circleName
                          : "No One in the circle",
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Overlapping circular member avatars
                    _MemberAvatarRow(members: members),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right column: 2x2 square avatar grid
            _AvatarGrid(members: members),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatarRow extends StatelessWidget {
  final List<dynamic> members;
  const _MemberAvatarRow({required this.members});

  static const _fallbackColors = [
    Color(0xFF2D7D32), // green (Nigerian flag)
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
    final displayCount = members.isEmpty ? 3 : members.length.clamp(1, 4);
    const avatarSize = 32.0;
    const overlap = 10.0;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (displayCount - 1) * (avatarSize - overlap),
      child: Stack(
        children: List.generate(displayCount, (i) {
          final String? url = members.isEmpty
              ? null
              : (members[i] as Map<String, dynamic>)['avatar_url'] as String?;

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

class _AvatarGrid extends StatelessWidget {
  final List<dynamic> members;
  const _AvatarGrid({required this.members});

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 167 / 158,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _slot(0)),
                const SizedBox(width: 10),
                Expanded(child: _slot(1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _slot(2)),
                const SizedBox(width: 10),
                Expanded(child: _slot(3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(int index) {
    final bool hasMember = index < members.length;
    if (!hasMember) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFF2),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final m = members[index] as Map<String, dynamic>;
    final url = m['avatar_url'] as String? ?? '';
    final fallback = index < _fallbackAssets.length
        ? _fallbackAssets[index]
        : _fallbackAssets[0];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
        image: DecorationImage(
          image: url.isNotEmpty
              ? NetworkImage(url) as ImageProvider
              : AssetImage(fallback),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

```
