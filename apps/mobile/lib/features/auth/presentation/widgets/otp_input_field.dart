import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final fillColor = isDark
        ? const Color(0xFF1E1E24)
        : const Color(0xFFF3F3F6);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(controllers.length, (index) {
          return SizedBox(
            width: 48,
            height: 52,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: "—",
                hintStyle: TextStyle(fontFamily: 'Inter', 
                  color: isDark ? Colors.white30 : Colors.black.withAlpha(30),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                // Paste handler
                if (value.length > 1) {
                  final cleanValue = value.replaceAll(
                    RegExp(r'\D'),
                    '',
                  ); // Digits only

                  // Distribute characters to text fields
                  for (
                    int i = 0;
                    i < cleanValue.length && (index + i) < controllers.length;
                    i++
                  ) {
                    controllers[index + i].text = cleanValue[index + i];
                  }

                  // Auto-advance focus to the last filled field or last index
                  final targetIndex = (index + cleanValue.length).clamp(
                    0,
                    controllers.length - 1,
                  );
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
      ),
    );
  }
}
