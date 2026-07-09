import 'package:flutter/material.dart';

class MemberMapPopupStatPill extends StatelessWidget {
  const MemberMapPopupStatPill({
    super.key,
    required this.icon,
    required this.label,
    this.dotColor,
  });

  final IconData icon;
  final String label;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFFDCEEFF)
        : const Color(0xFF04324F);
    final foreground = isDark ? const Color(0xFF04324F) : Colors.white;
    return Container(
      width: 93,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: foreground, size: 18),
          if (dotColor != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
