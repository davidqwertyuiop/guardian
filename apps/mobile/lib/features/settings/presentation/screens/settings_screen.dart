import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/features/auth/presentation/screens/login_screen.dart';
import 'package:guardian/core/utils/fade_route.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.outfit())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('Edit Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text('Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text('Security & Privacy', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Logout', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await TokenManager().clearTokens();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(page: const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
