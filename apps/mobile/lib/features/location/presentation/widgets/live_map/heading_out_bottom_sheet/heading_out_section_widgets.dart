part of '../heading_out_bottom_sheet.dart';

class HeadingOutFormSection extends StatelessWidget {
  final String label;
  final Color textColor;
  final Widget child;

  const HeadingOutFormSection({super.key, 
    required this.label,
    required this.textColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class HeadingOutNotice extends StatelessWidget {
  final bool isDark;

  const HeadingOutNotice({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Your circle will be notified when you start and when you arrive.",
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }
}
