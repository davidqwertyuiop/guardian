import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'package:guardian/features/notifications/presentation/bloc/notification_bloc.dart';

class TopBarLeadingButton extends StatelessWidget {
  const TopBarLeadingButton({
    super.key, required this.size, required this.showBackButton,
    this.onBackPressed, this.onNotificationPressed,
  });

  final double size; final bool showBackButton;
  final VoidCallback? onBackPressed, onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C24);
    final surfaceColor = isDark ? const Color(0xFF23232A) : Colors.white;
    return GestureDetector(
      onTap: showBackButton ? onBackPressed : onNotificationPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
          if (!showBackButton)
            Positioned(
              top: -2,
              right: -2,
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state.unreadCount <= 0) return const SizedBox.shrink();
                  final text = state.unreadCount > 9
                      ? '9+'
                      : '${state.unreadCount}';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C60FF),
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
