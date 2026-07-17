import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardian/features/home/presentation/bloc/home_event.dart';
import 'package:guardian/features/home/presentation/bloc/home_state.dart';
import 'package:guardian/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:guardian/features/settings/presentation/bloc/settings_event.dart';
import 'package:guardian/features/settings/presentation/bloc/settings_state.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/settings_screen.dart';
import 'settings_profile_parts.dart';
import 'settings_shell_widgets.dart';

class SettingsProfileView extends StatelessWidget {
  const SettingsProfileView({
    super.key,
    required this.homeState,
    required this.onOpen,
    required this.onLogout,
  });

  final HomeState homeState;
  final ValueChanged<SettingsPage> onOpen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (prev, curr) =>
          // Upload just finished
          (prev.avatarUploading &&
              !curr.avatarUploading &&
              curr.newAvatarUrl.isNotEmpty) ||
          // New distinct URL
          (curr.newAvatarUrl.isNotEmpty &&
              curr.newAvatarUrl != prev.newAvatarUrl) ||
          // Error
          (curr.status == SettingsStatus.failure &&
              curr.errorMessage != prev.errorMessage),
      listener: (context, state) async {
        if (state.status == SettingsStatus.failure &&
            state.errorMessage.isNotEmpty) {
          toastification.show(
            context: context,
            title: Text(state.errorMessage),
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
        if (state.newAvatarUrl.isNotEmpty) {
          // iOS can retain the old decoded image as a live cache entry even
          // after the URL changes. Remove both providers before publishing the
          // new URL so every avatar consumer receives fresh image bytes.
          if (homeState.avatarUrl.isNotEmpty) {
            await NetworkImage(homeState.avatarUrl).evict();
          }
          await NetworkImage(state.newAvatarUrl).evict();
          if (!context.mounted) return;
          context.read<HomeBloc>().add(UpdateAvatarUrl(state.newAvatarUrl));
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              Text('Profile', style: _title(context)),
              const SizedBox(height: 22),
              ProfileHero(
                homeState: homeState,
                avatarUploading: settingsState.avatarUploading,
                phone: settingsState.phone,
                onEditAvatar: () => _pickAndUpload(context),
              ),
              const SizedBox(height: 30),
              const SectionTitle('PERSONALIZE'),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Personal Details',
                    onTap: () => onOpen(SettingsPage.details),
                  ),
                  SettingsTile(
                    icon: Icons.near_me_outlined,
                    title: 'Location Sharing',
                    onTap: () => onOpen(SettingsPage.location),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => onOpen(SettingsPage.notifications),
                  ),
                  SettingsTile(
                    icon: Icons.devices_rounded,
                    title: 'Devices',
                    onTap: () => onOpen(SettingsPage.devices),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () => onOpen(SettingsPage.account),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const SectionTitle('NEED HELP?'),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Frequently Asked Questions',
                    onTap: () => onOpen(SettingsPage.help),
                  ),
                  SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact us',
                    onTap: () => onOpen(SettingsPage.help),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    danger: true,
                    onTap: onLogout,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!context.mounted) return;
    context.read<SettingsBloc>().add(UploadAvatarRequested(File(picked.path)));
  }

  TextStyle _title(BuildContext context) => TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.text(context),
  );
}
