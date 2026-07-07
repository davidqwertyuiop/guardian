import 'package:flutter/material.dart';
import 'package:guardian/core/constants/app_colors.dart';

class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack(this.members, {super.key});

  final List<Map<String, dynamic>> members;

  @override
  Widget build(BuildContext context) {
    final unique = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final member in members) {
      final key = '${member['user_id'] ?? member['id'] ?? member['name']}';
      if (seen.add(key)) unique.add(member);
    }
    final shown = unique.take(3).toList();
    return SizedBox(
      width: 72,
      height: 58,
      child: Stack(
        children: [
          if (shown.isEmpty)
            Positioned(bottom: 0, left: 0, child: _avatar('U', null, 34)),
          if (shown.isNotEmpty)
            Positioned(
              top: 0,
              right: 14,
              child: _avatar(
                '${shown[0]['name'] ?? 'U'}',
                shown[0]['avatar_url'] as String?,
                36,
              ),
            ),
          if (shown.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              child: _avatar(
                '${shown[1]['name'] ?? 'U'}',
                shown[1]['avatar_url'] as String?,
                30,
              ),
            ),
          if (shown.length > 2)
            Positioned(
              bottom: 0,
              left: 26,
              child: _avatar(
                '${shown[2]['name'] ?? 'U'}',
                shown[2]['avatar_url'] as String?,
                30,
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatar(String name, String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(name),
              )
            : _fallback(name),
      ),
    );
  }

  Widget _fallback(String name) => Center(
    child: Text(
      name.isEmpty ? '?' : name[0].toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
