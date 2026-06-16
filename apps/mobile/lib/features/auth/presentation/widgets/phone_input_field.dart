import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String flag;
  final String dialCode;
  final VoidCallback onTapCountry;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.flag,
    required this.dialCode,
    required this.onTapCountry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F6);
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
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
                  style: TextStyle(fontFamily: 'Inter', 
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontFamily: 'Inter', 
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: "Mobile number",
                hintStyle: TextStyle(fontFamily: 'Inter', 
                  color: isDark ? Colors.white38 : Colors.grey[400],
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
