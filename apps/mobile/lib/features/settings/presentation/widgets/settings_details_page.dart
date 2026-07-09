import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'settings_shell_widgets.dart';

class SettingsDetailsPage extends StatefulWidget {
  const SettingsDetailsPage({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.onBack,
  });

  final String userName;
  final String avatarUrl;
  final VoidCallback onBack;

  @override
  State<SettingsDetailsPage> createState() => _SettingsDetailsPageState();
}

class _SettingsDetailsPageState extends State<SettingsDetailsPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Personal Details', onBack: widget.onBack),
        const SizedBox(height: 20),
        const Text(
          'Name',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            filled: true,
            fillColor: AppColors.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Phone Number',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: false, // Phone number cannot be edited directly here
          decoration: InputDecoration(
            hintText: 'Phone number (auth bound)',
            filled: true,
            fillColor: AppColors.surface(context).withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: widget.onBack, // Placeholder for actual save action
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
