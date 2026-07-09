import 'package:flutter/material.dart';

class MemberMapPopupIdentity extends StatelessWidget {
  const MemberMapPopupIdentity({
    super.key,
    required this.name,
    required this.address,
    required this.updatedLabel,
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.foreground,
    required this.subtext,
  });

  final String name;
  final String address;
  final String updatedLabel;
  final String avatarUrl;
  final String fallbackAsset;
  final Color foreground;
  final Color subtext;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PopupAvatar(avatarUrl: avatarUrl, fallbackAsset: fallbackAsset),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$address · $updatedLabel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subtext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupAvatar extends StatelessWidget {
  const _PopupAvatar({required this.avatarUrl, required this.fallbackAsset});

  final String avatarUrl;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFF7BA8), width: 1.4),
      ),
      child: CircleAvatar(
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? ClipOval(child: Image.asset(fallbackAsset))
            : null,
      ),
    );
  }
}
