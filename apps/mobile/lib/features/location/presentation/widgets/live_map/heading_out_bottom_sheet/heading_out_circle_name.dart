part of '../heading_out_bottom_sheet.dart';

class HeadingOutCircleName extends StatelessWidget {
  final String name;
  final bool isDark;
  final bool isSelected;

  const HeadingOutCircleName({super.key, 
    required this.name,
    required this.isDark,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name.isNotEmpty ? name : "My Circle",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              height: 1.2,
            ),
          ),
        ),
        if (isSelected)
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFBB86FC),
            size: 20,
          ),
      ],
    );
  }
}
