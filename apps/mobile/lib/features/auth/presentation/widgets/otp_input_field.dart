import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpInputField extends StatelessWidget {
  /// A single [TextEditingController] that Pinput owns.
  final TextEditingController controller;
  final FocusNode focusNode;

  /// Called with the joined 4-digit string when all digits are entered.
  final ValueChanged<String>? onCompleted;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fillColor =
        isDark ? const Color(0xFF1E1E24) : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : Colors.black;
    final focusBorderColor =
        isDark ? Colors.white38 : const Color(0xFF1A73E8);

    final defaultTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: focusBorderColor, width: 1.5),
      borderRadius: BorderRadius.circular(14),
    );

    final submittedTheme = defaultTheme.copyWith(
      decoration: defaultTheme.decoration?.copyWith(
        color: fillColor,
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFD0D0D8),
          width: 1,
        ),
      ),
    );

    return Pinput(
      length: 4,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: submittedTheme,
      showCursor: true,
      cursor: Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: isDark ? Colors.white54 : const Color(0xFF1A73E8),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      obscureText: true,
      obscuringWidget: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: isDark ? Colors.white70 : Colors.black87,
          shape: BoxShape.circle,
        ),
      ),
      pinputAutovalidateMode: PinputAutovalidateMode.disabled,
      closeKeyboardWhenCompleted: true,
      onCompleted: onCompleted,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
    );
  }
}
