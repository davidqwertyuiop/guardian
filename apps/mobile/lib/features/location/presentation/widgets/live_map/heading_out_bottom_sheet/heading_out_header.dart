part of '../heading_out_bottom_sheet.dart';

class HeadingOutHeader extends StatelessWidget {
  final bool isDark;
  final Color textColor;

  const HeadingOutHeader({super.key, required this.isDark, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF2F2F7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close, size: 20, color: textColor),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                "I'm heading out",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Broadcast",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}
