import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpInputField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpInputField({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final fillColor = isDark ? const Color(0xFF222228) : const Color(0xFFF3F3F6);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(controllers.length, (index) {
        return SizedBox(
          width: 44,
          height: 52,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            // To support pasting multiple digits, we handle splitting programmatically and don't restrict maxLength to 1
            maxLength: null,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: fillColor,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF7C60FF),
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              // Paste handler
              if (value.length > 1) {
                final cleanValue = value.replaceAll(RegExp(r'\D'), ''); // Digits only
                
                // Distribute characters to text fields
                for (int i = 0; i < cleanValue.length && (index + i) < controllers.length; i++) {
                  controllers[index + i].text = cleanValue[index + i];
                }
                
                // Auto-advance focus to the last filled field or last index
                final targetIndex = (index + cleanValue.length).clamp(0, controllers.length - 1);
                focusNodes[targetIndex].requestFocus();
                return;
              }

              // Normal single-character navigation
              if (value.isNotEmpty) {
                if (index < controllers.length - 1) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  focusNodes[index].unfocus();
                }
              } else {
                if (index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              }
            },
          ),
        );
      }),
    );
  }
}
