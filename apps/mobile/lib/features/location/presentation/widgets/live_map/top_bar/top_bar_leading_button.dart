import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class TopBarLeadingButton extends StatelessWidget {
  final double size;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const TopBarLeadingButton({
    super.key,
    required this.size,
    required this.showBackButton,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C24);
    final surfaceColor = isDark ? const Color(0xFF23232A) : Colors.white;

    return GestureDetector(
      onTap: showBackButton ? onBackPressed : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: surfaceColor,
          shape: BoxShape.circle,
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
          child: showBackButton
              ? Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: context.w(18),
                  color: iconColor,
                )
              : Image.asset(
                  AppAssets.phBell,
                  width: context.w(20),
                  height: context.w(20),
                  color: iconColor,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.notifications_none_rounded,
                    size: context.w(20),
                    color: iconColor,
                  ),
                ),
        ),
      ),
    );
  }
}
