import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'settings_shell_widgets.dart';

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Privacy Policy', onBack: onBack),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Guardian Privacy Policy',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v 1.0',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildParagraph(
            'Your privacy is important to us. It is Guardian\'s policy to respect your privacy regarding any information we may collect from you across our website, and other sites we own and operate.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we\'re collecting it and how it will be used.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we\'ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'We don\'t share any personally identifying information publicly or with third-parties, except when required to by law.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'Our website may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.'),
        const SizedBox(height: 16),
        _buildParagraph(
            'Your continued use of our website will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us.'),
        const SizedBox(height: 16),
        _buildParagraph('This policy is effective as of 1 August 2024.'),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
