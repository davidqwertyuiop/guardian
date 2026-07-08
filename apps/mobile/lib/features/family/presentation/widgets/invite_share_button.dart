import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:share_plus/share_plus.dart';

class InviteShareButton extends StatelessWidget {
  const InviteShareButton({
    super.key,
    required this.label,
    required this.shareText,
  });

  final String label;
  final String shareText;

  @override
  Widget build(BuildContext context) {
    final isWhatsApp = label == 'WhatsApp';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.black;
    final background = isDark
        ? const Color(0xFF232328)
        : const Color(0xFFEFEFF2);
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: shareText.isEmpty
            ? null
            : () => SharePlus.instance.share(
                ShareParams(text: 'Join my Guardian circle! $shareText'),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.82),
          disabledForegroundColor: foreground.withValues(alpha: 0.70),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const StadiumBorder(),
        ),
        icon: isWhatsApp
            ? Image.asset(AppAssets.whatsappIcon, width: 18, height: 18)
            : const Icon(Icons.north_east_rounded, size: 17),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
