part of '../heading_out_bottom_sheet.dart';

class HeadingOutIosDropdown extends StatelessWidget {
  final String value;
  final Color borderColor;
  final Color textColor;
  final bool isDark;
  final VoidCallback onTap;

  const HeadingOutIosDropdown({super.key, 
    required this.value,
    required this.borderColor,
    required this.textColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HeadingOutDropdownText(value: value, color: textColor),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
