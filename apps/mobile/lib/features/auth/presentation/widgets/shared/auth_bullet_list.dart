import 'package:flutter/material.dart';
import 'package:guardian/core/utils/adaptive_layout.dart';

class AuthBulletList extends StatelessWidget {
  final List<String> bulletPoints;

  const AuthBulletList({super.key, required this.bulletPoints});

  @override
  Widget build(BuildContext context) {
    if (bulletPoints.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bulletPoints
          .map(
            (point) => Padding(
              padding: EdgeInsets.only(bottom: AdaptiveLayout.h(context, 12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '→ ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: AdaptiveLayout.sp(context, 16),
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: AdaptiveLayout.sp(context, 16),
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
