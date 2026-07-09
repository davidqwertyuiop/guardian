import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'settings_profile_parts.dart';
import 'settings_shell_widgets.dart';

class SettingsHelpPage extends StatelessWidget {
  const SettingsHelpPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Help & Support', onBack: onBack),
        const SizedBox(height: 10),
        Text(
          'How can we help you today?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search for help...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: AppColors.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 30),
        const SectionTitle('CONTACT US'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'guardian@email.com',
                onTap: () {
                  // mailto:guardian@email.com
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Live Chat',
                subtitle: 'Usually replies in 5m',
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const SectionTitle('FREQUENTLY ASKED QUESTIONS'),
        const SizedBox(height: 10),
        const _FaqItem(
          question: 'How do I add a new device?',
          answer: 'To add a new device, simply download the Guardian app on your new device and log in using your phone number. Your new device will be automatically linked to your account.',
        ),
        const _FaqItem(
          question: 'How do I turn off location sharing?',
          answer: 'You can pause your location from the main map view by tapping the pause icon, or toggle it entirely off in the Location Sharing settings.',
        ),
        const _FaqItem(
          question: 'What is an SOS alert?',
          answer: 'An SOS alert instantly notifies all members of your active circle with your exact location and an emergency flag.',
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: const Color(0xFF6B7280),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
