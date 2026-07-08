import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'top_bar/top_bar_center.dart';
import 'top_bar/top_bar_leading_button.dart';
import 'top_bar/top_bar_sos_button.dart';

class LiveMapTopBar extends StatelessWidget {
  final VoidCallback onSosTap;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isSosActive;
  final bool showCenterIcon;

  const LiveMapTopBar({
    super.key,
    required this.onSosTap,
    this.onNotificationTap,
    this.showBackButton = false,
    this.onBackPressed,
    this.isSosActive = false,
    this.showCenterIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = context.w(40);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TopBarLeadingButton(
            size: buttonSize,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed,
            onNotificationPressed: onNotificationTap,
          ),
          TopBarCenter(showIcon: showCenterIcon),
          TopBarSosButton(
            height: buttonSize,
            onTap: onSosTap,
            isActive: isSosActive,
          ),
        ],
      ),
    );
  }
}
