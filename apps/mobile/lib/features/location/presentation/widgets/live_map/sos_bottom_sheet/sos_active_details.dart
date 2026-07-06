part of '../sos_bottom_sheet.dart';

class SosActiveDetails extends StatelessWidget {
  final String? address;
  final bool isDark;

  const SosActiveDetails({
    super.key,
    required this.address,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          address ?? 'Updating location...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Updated just now.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 18),
        Divider(color: isDark ? Colors.white12 : Colors.black12),
        const SizedBox(height: 12),
        SosVisibilityList(isDark: isDark),
      ],
    );
  }
}
