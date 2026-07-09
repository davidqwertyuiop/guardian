import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'member_map_popup_stat_pill.dart';

class MemberMapPopupStatus extends StatelessWidget {
  const MemberMapPopupStatus({
    super.key,
    required this.showSosBanner,
    required this.sosBannerText,
    required this.batteryLabel,
    required this.connectivityLabel,
    required this.statusLabel,
  });

  final bool showSosBanner;
  final String sosBannerText;
  final String batteryLabel;
  final String connectivityLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSosBanner) ...[
          const SizedBox(height: 24),
          _SosBanner(text: sosBannerText),
        ],
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MemberMapPopupStatPill(
                icon: Icons.battery_full_rounded,
                label: batteryLabel,
              ),
              const SizedBox(width: 10),
              MemberMapPopupStatPill(
                icon: Icons.wifi_rounded,
                label: connectivityLabel,
              ),
              const SizedBox(width: 10),
              MemberMapPopupStatPill(
                icon: Icons.podcasts_rounded,
                label: statusLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SosBanner extends StatelessWidget {
  const _SosBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.isDark(context)
        ? const Color(0xFFFF7BA8).withValues(alpha: 0.45)
        : const Color(0xFFE8E8ED);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 230,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: Color(0xFFFF3380),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF3380),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
