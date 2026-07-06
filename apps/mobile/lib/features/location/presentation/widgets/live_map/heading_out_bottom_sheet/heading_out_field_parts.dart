part of '../heading_out_bottom_sheet.dart';

class HeadingOutDropdownText extends StatelessWidget {
  final String value;
  final Color color;

  const HeadingOutDropdownText({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(value, style: _dropdownTextStyle(color));
  }
}

class HeadingOutCustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final bool isDark;

  const HeadingOutCustomField({super.key, 
    required this.controller,
    required this.hintText,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
        enabledBorder: _border(borderColor),
        focusedBorder: _border(AppColors.primary),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}

TextStyle _dropdownTextStyle(Color color) {
  return TextStyle(
    fontFamily: 'Inter',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
