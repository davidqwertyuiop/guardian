import 'package:flutter/material.dart';
import 'package:guardian/core/utils/responsive_scale.dart';
import 'top_bar_bell_button.dart';
import 'top_bar_home_logo.dart';
import 'top_bar_sos_pill.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onSosTap;
  const TopBar({super.key, required this.onSosTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double bellSize = context.w(40);
    final double bellPadding = context.w(6.4);
    final double centerIconSize = context.w(90);
    final double sosHeight = context.w(40);
    final double sosPaddingHorizontal = context.w(11);
    final double sosPaddingVertical = context.w(4);
    final double sosGap = context.w(10);

    final double maxBarHeight = bellSize > sosHeight ? bellSize : sosHeight;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: SizedBox(
        height: maxBarHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bell notification icon (far left)
            Align(
              alignment: Alignment.centerLeft,
              child: TopBarBellButton(
                size: bellSize,
                padding: bellPadding,
                isDark: isDark,
              ),
            ),
            
            // Home logo icon (center)
            Align(
              alignment: Alignment.center,
              child: TopBarHomeLogo(
                size: centerIconSize,
                isDark: isDark,
              ),
            ),
            
            // SOS and grid control widget (far right)
            Align(
              alignment: Alignment.centerRight,
              child: TopBarSosPill(
                height: sosHeight,
                paddingHorizontal: sosPaddingHorizontal,
                paddingVertical: sosPaddingVertical,
                gap: sosGap,
                isDark: isDark,
                onTap: onSosTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
