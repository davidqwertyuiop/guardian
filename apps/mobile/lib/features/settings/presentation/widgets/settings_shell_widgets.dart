import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/features/family/presentation/widgets/family_back_button.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          if (onBack != null)
            FamilyBackButton(onPressed: onBack!)
          else
            const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text(context),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.icon,
    this.assetIcon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final IconData? icon;
  final String? assetIcon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFFF2D7A) : AppColors.text(context);
    
    Widget leadingWidget;
    if (assetIcon != null) {
      leadingWidget = Image.asset(
        assetIcon!,
        width: 17,
        height: 17,
        color: color,
      );
    } else if (icon != null) {
      leadingWidget = Icon(icon!, size: 17, color: color);
    } else {
      leadingWidget = const SizedBox(width: 17, height: 17);
    }

    return Material(
      color: Colors.transparent,
      child: ListTile(
        minLeadingWidth: 12,
        leading: leadingWidget,
        title: Text(title, style: _style(color)),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              )
            : null,
        trailing: trailing ?? Icon(Icons.chevron_right, color: color, size: 18),
        onTap: onTap,
      ),
    );
  }

  TextStyle _style(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: color,
  );
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items,
      ),
    );
  }
}

class SmallSwitch extends StatelessWidget {
  const SmallSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor = const Color(0xFF22C55E),
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeTrackColor;

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate an adaptive scale factor
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // Base width in Figma was 375 (standard iPhone design width)
    // We scale the switch up on larger screens, but put bounds on it
    // so it doesn't get ridiculously small on tiny phones or huge on tablets.
    final scaleFactor = (screenWidth / 375.0).clamp(0.85, 1.5);
    
    // Figma spec was 24 x 13.5
    final targetWidth = 24.0 * scaleFactor;
    final targetHeight = 13.5 * scaleFactor;

    return SizedBox(
      width: targetWidth,
      height: targetHeight,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          activeTrackColor: activeTrackColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
