import 'package:flutter/material.dart';
import 'member_map_popup_actions.dart';
import 'member_map_popup_identity.dart';
import 'member_map_popup_status.dart';

class MemberMapPopupContent extends StatelessWidget {
  const MemberMapPopupContent({
    super.key,
    required this.name,
    required this.address,
    required this.updatedLabel,
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.foreground,
    required this.subtext,
    required this.showSosBanner,
    required this.sosBannerText,
    required this.batteryLabel,
    required this.connectivityLabel,
    required this.statusLabel,
    required this.onCall,
    required this.onViewOnMap,
    required this.onClose,
    required this.isDark,
  });

  final String name;
  final String address;
  final String updatedLabel;
  final String avatarUrl;
  final String fallbackAsset;
  final Color foreground;
  final Color subtext;
  final bool showSosBanner;
  final String sosBannerText;
  final String batteryLabel;
  final String connectivityLabel;
  final String statusLabel;
  final VoidCallback onCall;
  final VoidCallback onViewOnMap;
  final VoidCallback onClose;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MemberMapPopupIdentity(
          name: name,
          address: address,
          updatedLabel: updatedLabel,
          avatarUrl: avatarUrl,
          fallbackAsset: fallbackAsset,
          foreground: foreground,
          subtext: subtext,
        ),
        MemberMapPopupStatus(
          showSosBanner: showSosBanner,
          sosBannerText: sosBannerText,
          batteryLabel: batteryLabel,
          connectivityLabel: connectivityLabel,
          statusLabel: statusLabel,
        ),
        const Spacer(),
        MemberMapPopupActions(
          name: name,
          onCall: onCall,
          onViewOnMap: onViewOnMap,
          onClose: onClose,
          isDark: isDark,
          foreground: foreground,
        ),
      ],
    );
  }
}
