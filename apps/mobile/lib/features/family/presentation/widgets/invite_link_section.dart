import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class InviteLinkSection extends StatelessWidget {
  const InviteLinkSection({
    super.key,
    required this.link,
    required this.shareText,
  });

  final String? link;
  final String shareText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                link ?? 'Preparing invite link...',
                const Color(0xFF1EA1FF),
                Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: link == null ? null : () => _copy(context, link!),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text(
                'Copy link',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _shareButton('WhatsApp')),
            const SizedBox(width: 10),
            Expanded(child: _shareButton('Other')),
          ],
        ),
      ],
    );
  }

  Widget _shareButton(String label) {
    return ElevatedButton(
      onPressed: shareText.isEmpty
          ? null
          : () => SharePlus.instance.share(
              ShareParams(text: 'Join my Guardian circle! $shareText'),
            ),
      child: Text(label),
    );
  }

  Widget _field(String text, Color bg, Color fg) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Inter',
        color: fg,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied.')));
  }
}
