import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_assets.dart';

class SosBroadcastHeader extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const SosBroadcastHeader({super.key, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Image.asset(
            AppAssets.sosBroadcastIcon,
            width: 20,
            height: 20,
            errorBuilder: (_, _, _) => const Icon(
              Icons.campaign_rounded,
              color: Color(0xFF3355FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'SOS Broadcasts',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3355FF),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSeeAllTap,
            child: const Text(
              'See all',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF888899),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
