import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'settings_shell_widgets.dart';

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({
    super.key,
    required this.onBack,
    this.isTerms = false,
  });

  final VoidCallback onBack;
  final bool isTerms;

  @override
  Widget build(BuildContext context) {
    final pageTitle = isTerms ? 'Terms of Service' : 'Privacy Policy';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: pageTitle, onBack: onBack),
        const SizedBox(height: 20),
        if (isTerms) ..._buildTerms(context) else ..._buildPrivacy(context),
      ],
    );
  }

  List<Widget> _buildPrivacy(BuildContext context) {
    return [
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
      _buildParagraph(
          'We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we\'re collecting it and how it will be used.'),
      _buildParagraph(
          'We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we\'ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.'),
      _buildParagraph(
          'We don\'t share any personally identifying information publicly or with third-parties, except when required to by law.'),
      _buildParagraph(
          'Our website may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.'),
      _buildParagraph(
          'You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.'),
      _buildParagraph(
          'Your continued use of our website will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us.'),
      _buildParagraph('This policy is effective as of 1 August 2024.'),
    ];
  }

  List<Widget> _buildTerms(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Guardian Terms of Service',
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
      const SizedBox(height: 10),
      Text(
        'Last updated: July 9, 2026',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText(context),
        ),
      ),
      const SizedBox(height: 10),
      _buildSectionHeader(context, 'AGREEMENT TO TERMS'),
      _buildParagraph(
          'These Terms and Conditions constitute a legally binding agreement made between you, whether personally or on behalf of an entity (“you”) and Guardian (“we,” “us” or “our”), concerning your access to and use of the guardian.com website as well as any other media form, media channel, mobile website or mobile application related, linked, or otherwise connected thereto (collectively, the “Site”).'),
      _buildParagraph(
          'You agree that by accessing the Site, you have read, understood, and agree to be bound by all of these Terms and Conditions. If you do not agree with all of these Terms and Conditions, then you are expressly prohibited from using the Site and you must discontinue use immediately.'),
      _buildParagraph(
          'Supplemental terms and conditions or documents that may be posted on the Site from time to time are hereby expressly incorporated herein by reference. We reserve the right, in our sole discretion, to make changes or modifications to these Terms and Conditions at any time and for any reason.'),
      _buildParagraph(
          'We will alert you about any changes by updating the “Last updated” date of these Terms and Conditions, and you waive any right to receive specific notice of each such change.'),
      _buildParagraph(
          'It is your responsibility to periodically review these Terms and Conditions to stay informed of updates. You will be subject to, and will be deemed to have been made aware of and to have accepted, the changes in any revised Terms and Conditions by your continued use of the Site after the date such revised Terms and Conditions are posted.'),
      _buildParagraph(
          'The information provided on the Site is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country.'),
      _buildParagraph(
          'Accordingly, those persons who choose to access the Site from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.'),
      _buildParagraph(
          'These terms and conditions were created by Termly’s Terms and Conditions Generator.'),
      _buildParagraph(
          'The Site is intended for users who are at least 13 years of age. All users who are minors in the jurisdiction in which they reside (generally under the age of 18) must have the permission of, and be directly supervised by, their parent or guardian to use the Site. If you are a minor, you must have your parent or guardian read and agree to these Terms and Conditions prior to you using the Site.'),
      
      _buildSectionHeader(context, 'INTELLECTUAL PROPERTY RIGHTS'),
      _buildParagraph(
          'Unless otherwise indicated, the Site is our proprietary property and all source code, databases, functionality, software, website designs, audio, video, text, photographs, and graphics on the Site (collectively, the “Content”) and the trademarks, service marks, and logos contained therein (the “Marks”) are owned or controlled by us or licensed to us, and are protected by copyright and trademark laws and various other intellectual property rights and unfair competition laws of the United States, foreign jurisdictions, and international conventions.'),
      _buildParagraph(
          'The Content and the Marks are provided on the Site “AS IS” for your information and personal use only. Except as expressly provided in these Terms and Conditions, no part of the Site and no Content or Marks may be copied, reproduced, aggregated, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.'),
      _buildParagraph(
          'Provided that you are eligible to use the Site, you are granted a limited license to access and use the Site and to download or print a copy of any portion of the Content to which you have properly gained access solely for your personal, non-commercial use. We reserve all rights not expressly granted to you in and to the Site, the Content and the Marks.'),
      
      _buildSectionHeader(context, 'USER REPRESENTATIONS'),
      _buildParagraph(
          'By using the Site, you represent and warrant that:\n'
          '(1) all registration information you submit will be true, accurate, current, and complete;\n'
          '(2) you will maintain the accuracy of such information and promptly update such registration information as necessary;\n'
          '(3) you have the legal capacity and you agree to comply with these Terms and Conditions;\n'
          '(4) you are not under the age of 13;\n'
          '(5) you are not a minor in the jurisdiction in which you reside, or if a minor, you have received parental permission to use the Site;\n'
          '(6) you will not access the Site through automated or non-human means, whether through a bot, script, or otherwise;\n'
          '(7) you will not use the Site for any illegal or unauthorized purpose;\n'
          '(8) your use of the Site will not violate any applicable law or regulation.'),
      _buildParagraph(
          'If you provide any information that is untrue, inaccurate, not current, or incomplete, we have the right to suspend or terminate your account and refuse any and all current or future use of the Site (or any portion thereof).'),
      
      _buildSectionHeader(context, 'USER REGISTRATION'),
      _buildParagraph(
          'You may be required to register with the Site. You agree to keep your password confidential and will be responsible for all use of your account and password. We reserve the right to remove, reclaim, or change a username you select if we determine, in our sole discretion, that such username is inappropriate, obscene, or otherwise objectionable.'),
      
      _buildSectionHeader(context, 'PROHIBITED ACTIVITIES'),
      _buildParagraph(
          'You may not access or use the Site for any purpose other than that for which we make the Site available. The Site may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us.'),
      _buildParagraph(
          'As a user of the Site, you agree not to:\n'
          '• systematically retrieve data or other content from the Site to create or compile, directly or indirectly, a collection, compilation, database, or directory without written permission from us.\n'
          '• make any unauthorized use of the Site, including collecting usernames and/or email addresses of users by electronic or other means for the purpose of sending unsolicited email, or creating user accounts by automated means or under false pretenses.\n'
          '• use a buying agent or purchasing agent to make purchases on the Site.\n'
          '• use the Site to advertise or offer to sell goods and services.\n'
          '• circumvent, disable, or otherwise interfere with security-related features of the Site, including features that prevent or restrict the use or copying of any Content or enforce limitations on the use of the Site and/or the Content contained therein.\n'
          '• engage in unauthorized framing of or linking to the Site.\n'
          '• trick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passwords;\n'
          '• make improper use of our support services or submit false reports of abuse or misconduct.\n'
          '• engage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots, or similar data gathering and extraction tools.\n'
          '• interfere with, disrupt, or create an undue burden on the Site or the networks or services connected to the Site.\n'
          '• attempt to impersonate another user or person or use the username of another user.\n'
          '• sell or otherwise transfer your profile.\n'
          '• use any information obtained from the Site in order to harass, abuse, or harm another person.\n'
          '• use the Site as part of any effort to compete with us or otherwise use the Site and/or the Content for any revenue-generating endeavor or commercial enterprise.\n'
          '• decipher, decompile, disassemble, or reverse engineer any of the software comprising or in any way making up a part of the Site.\n'
          '• attempt to bypass any measures of the Site designed to prevent or restrict access to the Site, or any portion of the Site.\n'
          '• harass, annoy, intimidate, or threaten any of our employees or agents engaged in providing any portion of the Site to you.\n'
          '• delete the copyright or other proprietary rights notice from any Content.\n'
          '• copy or adapt the Site’s software, including but not limited to Flash, PHP, HTML, JavaScript, or other code.\n'
          '• upload or transmit (or attempt to upload or to transmit) viruses, Trojan horses, or other material, including excessive use of capital letters and spamming (continuous posting of repetitive text), that interferes with any party’s uninterrupted use and enjoyment of the Site or modifies, impairs, disrupts, alters, or interferes with the use, features, functions, operation, or maintenance of the Site.\n'
          '• upload or transmit (or attempt to upload or to transmit) any material that acts as a passive or active information collection or transmission mechanism, including without limitation, clear graphics interchange formats (“gifs”), 1×1 pixels, web bugs, cookies, or other similar devices (sometimes referred to as “spyware” or “passive collection mechanisms” or “pcms”).\n'
          '• except as may be the result of standard search engine or Internet browser usage, use, launch, develop, or distribute any automated system, including without limitation, any spider, robot, cheat utility, scraper, or offline reader that accesses the Site, or using or launching any unauthorized script or other software.\n'
          '• disparage, tarnish, or otherwise harm, in our opinion, us and/or the Site.\n'
          '• use the Site in a manner inconsistent with any applicable laws or regulations.'),
      
      _buildSectionHeader(context, 'USER GENERATED CONTRIBUTIONS'),
      _buildParagraph(
          'The Site may invite you to chat, contribute to, or participate in blogs, message boards, online forums, and other functionality, and may provide you with the opportunity to create, submit, post, display, transmit, perform, publish, distribute, or broadcast content and materials to us or on the Site, including but not limited to text, writings, video, audio, photographs, graphics, comments, suggestions, or personal information or other material (collectively, “Contributions”).'),
      _buildParagraph(
          'Contributions may be viewable by other users of the Site and through third-party websites. As such, any Contributions you transmit may be treated as non-confidential and non-proprietary. When you create or make available any Contributions, you thereby represent and warrant that:\n'
          '• the creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights, including but not limited to the copyright, patent, trademark, trade secret, or moral rights of any third party.\n'
          '• you are the creator and owner of or have the necessary licenses, rights, consents, releases, and permissions to use and to authorize us, the Site, and other users of the Site to use your Contributions in any manner contemplated by the Site and these Terms and Conditions.\n'
          '• you have the written consent, release, and/or permission of each and every identifiable individual person in your Contributions to use the name or likeness of each and every such identifiable individual person to enable inclusion and use of your Contributions in any manner contemplated by the Site and these Terms and Conditions.\n'
          '• your Contributions are not false, inaccurate, or misleading.\n'
          '• your Contributions are not unsolicited or unauthorized advertising, promotional materials, pyramid schemes, chain letters, spam, mass mailings, or other forms of solicitation.\n'
          '• your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable (as determined by us).\n'
          '• your Contributions do not ridicule, mock, disparage, intimidate, or abuse anyone.\n'
          '• your Contributions do not advocate the violent overthrow of any government or incite, encourage, or threaten physical harm against another.\n'
          '• your Contributions do not violate any applicable law, regulation, or rule.\n'
          '• your Contributions do not violate the privacy or publicity rights of any third party.\n'
          '• your Contributions do not contain any material that solicits personal information from anyone under the age of 18 or exploits people under the age of 18 in a sexual or violent manner.\n'
          '• your Contributions do not violate any federal or state law concerning child pornography, or otherwise intended to protect the health or well-being of minors;\n'
          '• your Contributions do not include any offensive comments that are connected to race, national origin, gender, sexual preference, or physical handicap.\n'
          '• your Contributions do not otherwise violate, or link to material that violates, any provision of these Terms and Conditions, or any applicable law or regulation.'),
      _buildParagraph(
          'Any use of the Site in violation of the foregoing violates these Terms and Conditions and may result in, among other things, termination or suspension of your rights to use the Site.'),
      
      _buildSectionHeader(context, 'CONTRIBUTION LICENSE'),
      _buildParagraph(
          'By posting your Contributions to any part of the Site or making Contributions accessible to the Site by linking your account from the Site to any of your social networking accounts, you automatically grant, and you represent and warrant that you have the right to grant, to us an unrestricted, unlimited, irrevocable, perpetual, non-exclusive, transferable, royalty-free, fully-paid, worldwide right, and license to host, use, copy, reproduce, disclose, sell, resell, publish, broadcast, retitle, archive, store, cache, publicly perform, publicly display, reformat, translate, transmit, excerpt (in whole or in part), and distribute such Contributions (including, without limitation, your image and voice) for any purpose, commercial, advertising, or otherwise, and to prepare derivative works of, or incorporate into other works, such Contributions, and grant and authorize sublicenses of the foregoing. The use and distribution may occur in any media formats and through any media channels.'),
    ];
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.text(context),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
