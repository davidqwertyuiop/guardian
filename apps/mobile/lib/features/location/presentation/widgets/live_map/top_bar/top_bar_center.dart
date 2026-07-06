import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

import 'top_bar_home_icon.dart';

class TopBarCenter extends StatelessWidget {
  final bool showIcon;

  const TopBarCenter({super.key, required this.showIcon});

  @override
  Widget build(BuildContext context) {
    if (!showIcon) return SizedBox(width: context.w(40));

    return TopBarHomeIcon(size: context.w(40));
  }
}
