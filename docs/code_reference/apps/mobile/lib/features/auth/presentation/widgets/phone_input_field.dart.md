# phone_input_field.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/widgets/phone_input_field.dart`
* **Type:** `DART`

---

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StripLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('0')) {
      final newText = newValue.text.substring(1);
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newValue.selection.baseOffset > 0 
              ? newValue.selection.baseOffset - 1 
              : 0,
        ),
      );
    }
    return newValue;
  }
}

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String flag;
  final String dialCode;
  final VoidCallback onTapCountry;

  /// Maximum number of subscriber digits allowed for the selected country.
  /// Enforced via [LengthLimitingTextInputFormatter].
  final int maxDigits;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.flag,
    required this.dialCode,
    required this.onTapCountry,
    required this.maxDigits,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark
        ? const Color(0xFF1E1E22)
        : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : Colors.black;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final typedCount = value.text.length;
        final showCounter = typedCount > 0 && maxDigits <= 15;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onTapCountry,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          dialCode,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.black12,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        StripLeadingZeroFormatter(),
                        LengthLimitingTextInputFormatter(maxDigits),
                      ],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mobile number',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white38 : Colors.grey[400],
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // Animated digit counter badge
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: showCounter
                        ? Container(
                            key: const ValueKey('counter'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typedCount == maxDigits
                                  ? const Color(
                                      0xFF1A73E8,
                                    ).withValues(alpha: 0.12)
                                  : (isDark
                                        ? Colors.white10
                                        : Colors.black.withValues(alpha: 0.06)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$typedCount/$maxDigits',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: typedCount == maxDigits
                                    ? const Color(0xFF1A73E8)
                                    : (isDark
                                          ? Colors.white54
                                          : Colors.black38),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

```
