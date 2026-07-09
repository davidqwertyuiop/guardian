import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import '../bloc/settings_state.dart';
import 'settings_confirmations.dart';
import 'settings_shell_widgets.dart';

class SettingsLocationPage extends StatelessWidget {
  const SettingsLocationPage({
    super.key,
    required this.state,
    required this.onBack,
    required this.onChanged,
  });

  final SettingsState state;
  final VoidCallback onBack;
  final void Function(bool location, bool sos, bool broadcast, bool newMember,
      [DateTime? locationPausedUntil]) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Location', onBack: onBack),
        SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.near_me_outlined,
              title: 'Sharing with Circle',
              trailing: SmallSwitch(
                value: state.locationEnabled,
                onChanged: (value) => onChanged(value, state.notifySos,
                    state.notifyBroadcast, state.notifyNewMember),
              ),
            ),
            SettingsTile(
              icon: Icons.pause_circle_outline_rounded,
              title: 'Pause sharing',
              onTap: state.locationEnabled
                  ? () => showPauseLocationDialog(
                        context,
                        onPause: (pausedUntil) => onChanged(false, state.notifySos,
                            state.notifyBroadcast, state.notifyNewMember, pausedUntil),
                      )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Your circle can only see your live location while sharing is enabled.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.mutedText(context),
          ),
        ),
      ],
    );
  }
}
