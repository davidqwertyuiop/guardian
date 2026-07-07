import 'package:flutter/material.dart';

String memberJoinedText(Map<String, dynamic> member, bool isMe) {
  if (isMe) return member['role'] == 'owner' ? 'You  •  Admin' : 'You';
  final raw = member['joined_at'];
  if (raw is! String) return 'Joined recently';
  final joined = DateTime.tryParse(raw) ?? DateTime.now();
  final days = DateTime.now().difference(joined).inDays;
  if (days == 0) return 'Joined today';
  if (days < 7) return 'Joined $days days ago';
  final weeks = days ~/ 7;
  return 'Joined $weeks week${weeks == 1 ? '' : 's'} ago';
}

Widget memberMetric(String label, String value, bool isDark) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: memberSubStyle(isDark)),
        Text(value, style: memberNameStyle(isDark).copyWith(fontSize: 14)),
      ],
    ),
  );
}

TextStyle memberNameStyle(bool dark) => TextStyle(
  fontFamily: 'Geist',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.32,
  height: 1,
  color: dark ? Colors.white : Colors.black,
);

TextStyle memberSubStyle(bool dark) => TextStyle(
  fontFamily: 'Geist',
  fontSize: 12,
  height: 1,
  color: dark ? Colors.white54 : Colors.black45,
);

TextStyle memberStatusStyle(bool sharing) => TextStyle(
  fontFamily: 'Geist',
  fontSize: 12,
  color: sharing ? const Color(0xFF22C55E) : Colors.grey,
);

Widget removeMemberButton(VoidCallback onPressed) => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
    child: const Text(
      'Remove from circle',
      style: TextStyle(fontFamily: 'Geist', color: Colors.white),
    ),
  ),
);
