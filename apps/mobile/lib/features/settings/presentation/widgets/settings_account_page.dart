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
        const _InviteFriendsBanner(),
        const SizedBox(height: 30),
        const SectionTitle('ACCOUNT'),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => onOpen(SettingsPage.privacy),
        ),
        const SizedBox(height: 6),
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms of Services',
          onTap: () => onOpen(SettingsPage.privacy),
        ),
        const SizedBox(height: 6),
        SettingsTile(
          icon: Icons.support_agent_rounded,
          title: 'Help & Support',
          onTap: () => onOpen(SettingsPage.help),
        ),
        const SizedBox(height: 6),
        SettingsTile(
          icon: Icons.workspace_premium_outlined,
          title: 'Manage Subscription',
          onTap: () {},
        ),
        const SizedBox(height: 6),
        SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Delete account',
          danger: true,
          onTap: onDeleteAccount,
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
      padding: const EdgeInsets.all(20),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invite friends',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Invite people to download\nand join the application',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
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
