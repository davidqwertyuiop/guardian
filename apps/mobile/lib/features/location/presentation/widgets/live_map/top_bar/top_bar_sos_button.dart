import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'top_bar_sos_text.dart';

class TopBarSosButton extends StatelessWidget {
  final double height;
  final VoidCallback onTap;
  final bool isActive;

  const TopBarSosButton({
    super.key,
    required this.height,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF23232A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: context.w(16), right: context.w(6)),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TopBarSosText(isActive: isActive),
              const SizedBox(width: 10),
              Container(
                width: height - 12,
                height: height - 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3380),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: context.w(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
