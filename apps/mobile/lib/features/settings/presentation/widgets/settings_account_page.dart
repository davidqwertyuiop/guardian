import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'settings_profile_parts.dart';
import 'settings_shell_widgets.dart';

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({
    super.key,
    required this.onBack,
    required this.onOpen,
    required this.onDeleteAccount,
  });

  final VoidCallback onBack;
  final ValueChanged<SettingsPage> onOpen;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Settings', onBack: onBack),
        const SizedBox(height: 16),
        const _InviteFriendsBanner(),
        const SizedBox(height: 30),
        const SectionTitle('ACCOUNT'),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              onTap: () => onOpen(SettingsPage.privacy),
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => onOpen(SettingsPage.terms),
            ),
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => onOpen(SettingsPage.help),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsGroup(
          children: [
            SettingsTile(
              assetIcon: AppAssets.subscriptionIcon,
              title: 'Manage Subscription',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 18),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.delete_outline_rounded,
              title: 'Delete account',
              danger: true,
              onTap: onDeleteAccount,
            ),
          ],
        ),
      ],
    );
  }
}

class _InviteFriendsBanner extends StatelessWidget {
  const _InviteFriendsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9F9F9), Color(0xFFFF3380)],
          stops: [0.5689, 1.0104],
          begin: Alignment(-0.8, -0.6), // roughly 97.02deg
          end: Alignment(0.8, 0.6),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.inviteFriendsIcon,
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 12),
          const Text(
            'Invite friends',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const Spacer(),
          Image.asset(
            AppAssets.flyingRocket,
            width: 60,
            height: 60,
          ),
        ],
      ),
    );
  }
}
