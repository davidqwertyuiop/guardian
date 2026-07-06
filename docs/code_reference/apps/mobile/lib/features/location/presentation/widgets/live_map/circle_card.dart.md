# circle_card.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/live_map/circle_card.dart`
* **Type:** `DART`

---

```dart
import 'member_avatar_row.dart';
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class CircleCard extends StatelessWidget {
  final String circleName;
  final List<dynamic> members;
  final bool isLoading;
  const CircleCard({
    super.key,
    required this.circleName,
    required this.members,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = members.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final outerBg = isDark ? const Color(0xFF131317) : const Color(0xFFF2F2F7);
    final innerBg = isDark ? const Color(0xFF22222A) : const Color(0xFFE5E5EA);

    final double gridHeight = context.w(155.94);
    final double tileWidth = context.w(78.47);
    final double tileHeight = context.w(73.97);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Container(
        height: context.w(168),
        padding: EdgeInsets.all(context.w(6)),
        decoration: BoxDecoration(
          color: outerBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: count label + circle name + circular member avatars
            Expanded(
              child: Container(
                height: gridHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.w(12),
                ),
                decoration: BoxDecoration(
                  color: innerBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoading && members.isEmpty ? 'Fetching...' : '$count members',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: context.sp(12),
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF7E7F9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          circleName.isNotEmpty ? circleName : (isLoading ? "Loading..." : "No Circle"),
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: context.sp(20),
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1C1C24),
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                    // Overlapping circular member avatars
                    MemberAvatarRow(members: members),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10), // gap: 10px
            // Right column: 2x2 grid of inner slots (rounded square tiles)
            SizedBox(
              width: tileWidth * 2 + 8, // two columns + 8px gap
              height: gridHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _slot(context, 0, tileWidth, tileHeight, innerBg),
                      _slot(context, 1, tileWidth, tileHeight, innerBg),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _slot(context, 2, tileWidth, tileHeight, innerBg),
                      _slot(context, 3, tileWidth, tileHeight, innerBg),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(
    BuildContext context,
    int index,
    double width,
    double height,
    Color placeholderColor,
  ) {
    final bool hasMember = index < members.length;

    if (!hasMember) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: placeholderColor,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final m = members[index] as Map<String, dynamic>;
    final url = m['avatar_url'] as String? ?? '';

    final List<String> fallbackAssets = [
      AppAssets.avatarTop,
      AppAssets.avatarLeft,
      AppAssets.avatarRight,
    ];
    final fallback = index < fallbackAssets.length
        ? fallbackAssets[index]
        : fallbackAssets[0];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: placeholderColor,
        borderRadius: BorderRadius.circular(12),
        image: url.isNotEmpty
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : DecorationImage(image: AssetImage(fallback), fit: BoxFit.cover),
      ),
    );
  }
}

```
