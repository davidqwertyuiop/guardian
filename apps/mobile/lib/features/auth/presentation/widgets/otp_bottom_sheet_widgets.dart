
import 'package:flutter/material.dart';

import 'package:guardian/export.dart';
class OtpBottomSheetHeader extends StatelessWidget {
  const OtpBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor, size: 22),
          onPressed: () => context.read<AuthBloc>().add(const NavigateBack()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        IconButton(
          icon: Icon(Icons.close, color: iconColor, size: 22),
          onPressed: () => context.read<AuthBloc>().add(const NavigateToWelcome()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class OtpBottomSheetSubtitle extends StatelessWidget {
  final String maskedPhone;
  const OtpBottomSheetSubtitle({super.key, required this.maskedPhone});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: "We sent a 6-digit code to $maskedPhone. ",
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: AdaptiveLayout.sp(context, 13),
          color: AppColors.greyText,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => context.read<AuthBloc>().add(const NavigateBack()),
              child: Text(
                "Edit",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AdaptiveLayout.sp(context, 13),
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpTimerText extends StatelessWidget {
  final int seconds;
  final VoidCallback? onResend;

  const OtpTimerText({super.key, required this.seconds, this.onResend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: seconds == 0 ? onResend : null,
      child: Text(
        seconds > 0
            ? "Resend code in 0:${seconds.toString().padLeft(2, '0')}"
            : "Resend code",
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: AdaptiveLayout.sp(context, 14),
          color: seconds > 0 ? AppColors.greyText : AppColors.primary,
          fontWeight: seconds > 0 ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }
}

String maskPhone(String dial, String phone) {
  if (phone.length < 4) return '$dial $phone';
  return '$dial ${phone.substring(0, 3)} *** **${phone.substring(phone.length - 2)}';
}
