import 'package:flutter/material.dart';
import 'member_map_popup_button.dart';

class MemberMapPopupActions extends StatelessWidget {
  const MemberMapPopupActions({
    super.key,
    required this.name,
    required this.onCall,
    required this.onViewOnMap,
    required this.onClose,
    required this.isDark,
    required this.foreground,
  });

  final String name;
  final VoidCallback onCall;
  final VoidCallback onViewOnMap;
  final VoidCallback onClose;
  final bool isDark;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PopupButton(
          label: 'Call $name Now',
          filled: true,
          onTap: onCall,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        PopupButton(
          label: 'View on map',
          filled: false,
          onTap: onViewOnMap,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F1F3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close_rounded, color: foreground, size: 22),
          ),
        ),
      ],
    );
  }
}
