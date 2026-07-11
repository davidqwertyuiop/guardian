import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';
import '../bloc/settings_state.dart';
import 'settings_shell_widgets.dart';

class SettingsDevicesPage extends StatelessWidget {
  const SettingsDevicesPage({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRevoke,
  });

  final SettingsState state;
  final VoidCallback onBack;
  final ValueChanged<String> onRevoke;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        SettingsHeader(title: 'Devices', onBack: onBack),
        if (state.status == SettingsStatus.loading)
          const Center(child: CircularProgressIndicator()),
        if (state.sessions.isEmpty && state.status != SettingsStatus.loading)
          Text('No active device sessions found.', style: _muted(context)),
        for (final raw in state.sessions) _device(context, raw),
      ],
    );
  }

  Widget _device(BuildContext context, dynamic raw) {
    final session = raw is Map ? raw : const {};
    final platform = session['platform']?.toString().toLowerCase() ?? '';
    final hash = session['id']?.toString() ?? '';
    final model = session['device_model']?.toString() ?? '';
    final deviceName = session['device_name']?.toString() ?? 'Device';
    final lastActiveStr = session['last_active_at']?.toString() ?? '';

    final isActive = hash.isNotEmpty && hash == state.currentRefreshToken;

    int minutesAgo = 0;
    if (lastActiveStr.isNotEmpty) {
      try {
        final lastActive = DateTime.parse(lastActiveStr).toUtc();
        final now = DateTime.now().toUtc();
        minutesAgo = now.difference(lastActive).inMinutes;
        if (minutesAgo < 0) minutesAgo = 0;
      } catch (_) {}
    }

    final String timeAgoText;
    if (minutesAgo < 1) {
      timeAgoText = 'just now';
    } else if (minutesAgo < 60) {
      timeAgoText = '$minutesAgo ${minutesAgo == 1 ? "minute" : "minutes"} ago';
    } else if (minutesAgo < 1440) {
      final hours = minutesAgo ~/ 60;
      timeAgoText = '$hours ${hours == 1 ? "hour" : "hours"} ago';
    } else {
      final days = minutesAgo ~/ 1440;
      timeAgoText = '$days ${days == 1 ? "day" : "days"} ago';
    }

    final bool isSessionActive = (hash.isNotEmpty && hash == state.currentRefreshToken) || (minutesAgo <= 15);

    final statusText = isSessionActive
        ? 'active • updated $timeAgoText'
        : 'inactive • last logged in $timeAgoText';
    final statusColor = isSessionActive ? const Color(0xFF22C55E) : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        minLeadingWidth: 12,
        leading: Icon(
          platform == 'ios'
              ? Icons.phone_iphone_rounded
              : Icons.phone_android_rounded,
          size: 20,
          color: AppColors.text(context),
        ),
        title: Text(
          deviceName,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (model.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                model,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: statusColor,
                  size: 7,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: isActive ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: hash.isEmpty ? null : () => onRevoke(hash),
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF2D7A)),
        ),
      ),
    );
  }

  TextStyle _muted(BuildContext context) =>
      TextStyle(fontFamily: 'Inter', color: AppColors.mutedText(context));
}
