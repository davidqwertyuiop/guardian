part of '../sos_bottom_sheet.dart';

class SosSheetIcon extends StatelessWidget {
  final SosSheetStatus status;

  const SosSheetIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final asset = switch (status) {
      SosSheetStatus.activating => AppAssets.activatingSosIcon,
      SosSheetStatus.active => AppAssets.sosIcon,
      SosSheetStatus.cancelled => AppAssets.stopBroadcastingIcon,
      SosSheetStatus.failure => AppAssets.sosIcon,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFF2D7A).withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(child: Image.asset(asset, width: 20, height: 20)),
    );
  }
}

class SosSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SosSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
