import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

Future<void> showPauseLocationDialog(
  BuildContext context, {
  required void Function(DateTime?) onPause,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pause location sharing',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your circle will not see your live location while sharing is paused.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.mutedText(context),
              ),
            ),
            const SizedBox(height: 24),
            _PauseOptionTile(title: 'For 30 minutes', onTap: () {
              Navigator.pop(ctx);
              onPause(DateTime.now().add(const Duration(minutes: 30)));
            }),
            _PauseOptionTile(title: 'For 1 hour', onTap: () {
              Navigator.pop(ctx);
              onPause(DateTime.now().add(const Duration(hours: 1)));
            }),
            _PauseOptionTile(title: 'Custom time...', onTap: () async {
              Navigator.pop(ctx);
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final now = DateTime.now();
                var selected = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                if (selected.isBefore(now)) {
                  selected = selected.add(const Duration(days: 1));
                }
                onPause(selected);
              }
            }),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PauseOptionTile extends StatelessWidget {
  const _PauseOptionTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDeleteAccountDialog(
  BuildContext context, {
  required VoidCallback onDelete,
}) {
  return _showNativeDialog(
    context,
    title: 'Delete your account?',
    message:
        'This will permanently delete:\n→  Your profile and display name\n→  Your location history\n→  Your membership in all circles\n\nThis cannot be undone.',
    primaryLabel: 'Delete my account',
    secondaryLabel: 'Go back',
    primaryDanger: true,
    onPrimary: onDelete,
  );
}

Future<void> _showNativeDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
  required bool primaryDanger,
  required VoidCallback onPrimary,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: primaryDanger,
            onPressed: () {
              Navigator.pop(context);
              onPrimary();
            },
            child: Text(primaryLabel),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(secondaryLabel),
          ),
        ],
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPrimary();
          },
          child: Text(primaryLabel, style: _danger(primaryDanger)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(secondaryLabel),
        ),
      ],
    ),
  );
}

TextStyle _danger(bool danger) =>
    TextStyle(color: danger ? const Color(0xFFFF2D7A) : AppColors.primary);
