import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'member_map_popup/member_map_popup_content.dart';
import 'member_map_popup/member_map_popup_header.dart';

class MemberMapPopup extends StatelessWidget {
  const MemberMapPopup({
    super.key,
    required this.name,
    required this.address,
    required this.updatedLabel,
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.batteryLabel,
    required this.connectivityLabel,
    required this.statusLabel,
    required this.showSosBanner,
    required this.sosBannerText,
    required this.onBack,
    required this.onClose,
    required this.onCall,
    required this.onViewOnMap,
  });

  final String name;
  final String address;
  final String updatedLabel;
  final String avatarUrl;
  final String fallbackAsset;
  final String batteryLabel;
  final String connectivityLabel;
  final String statusLabel;
  final bool showSosBanner;
  final String sosBannerText;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final VoidCallback onCall;
  final VoidCallback onViewOnMap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF141414);
    final subtext = isDark ? Colors.white70 : const Color(0xFF8C8C92);

    return Material(
      color: const Color(0xFFFF2F83),
      child: SafeArea(
        child: Column(
          children: [
            MemberMapPopupHeader(onBack: onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 336,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.64,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: MemberMapPopupContent(
                    name: name,
                    address: address,
                    updatedLabel: updatedLabel,
                    avatarUrl: avatarUrl,
                    fallbackAsset: fallbackAsset,
                    foreground: foreground,
                    subtext: subtext,
                    showSosBanner: showSosBanner,
                    sosBannerText: sosBannerText,
                    batteryLabel: batteryLabel,
                    connectivityLabel: connectivityLabel,
                    statusLabel: statusLabel,
                    onCall: onCall,
                    onViewOnMap: onViewOnMap,
                    onClose: onClose,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
