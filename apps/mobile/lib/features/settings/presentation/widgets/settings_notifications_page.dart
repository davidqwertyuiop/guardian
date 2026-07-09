import 'package:flutter/material.dart';
import '../bloc/settings_state.dart';
import 'settings_shell_widgets.dart';

class SettingsNotificationsPage extends StatelessWidget {
  const SettingsNotificationsPage({
    super.key,
    required this.state,
    required this.onBack,
    required this.onChanged,
  });

  final SettingsState state;
  final VoidCallback onBack;
  final void Function(bool location, bool sos, bool broadcast, bool newMember)
      onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Notifications', onBack: onBack),
        _toggle(
          context,
          'SOS alerts',
          state.notifySos,
          (value) => onChanged(
              state.locationEnabled, value, state.notifyBroadcast, state.notifyNewMember),
        ),
        const SizedBox(height: 6),
        _toggle(
          context,
          'Broadcast alerts',
          state.notifyBroadcast,
          (value) => onChanged(
              state.locationEnabled, state.notifySos, value, state.notifyNewMember),
        ),
        const SizedBox(height: 6),
        _toggle(
          context,
          'New member joined',
          state.notifyNewMember,
          (value) => onChanged(
              state.locationEnabled, state.notifySos, state.notifyBroadcast, value),
        ),
      ],
    );
  }

  Widget _toggle(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      SettingsTile(
        icon: Icons.notifications_none_rounded,
        title: title,
        trailing: SmallSwitch(value: value, onChanged: onChanged),
      );
}
