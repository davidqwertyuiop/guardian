part of '../heading_out_bottom_sheet.dart';

class HeadingOutMaterialDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final Color borderColor;
  final Color textColor;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const HeadingOutMaterialDropdown({super.key, 
    required this.value,
    required this.options,
    required this.borderColor,
    required this.textColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          dropdownColor: isDark ? const Color(0xFF2A2A30) : Colors.white,
          style: _dropdownTextStyle(textColor),
          items: options.map((opt) {
            return DropdownMenuItem<String>(value: opt, child: Text(opt));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
