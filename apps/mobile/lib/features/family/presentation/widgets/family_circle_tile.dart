import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'member_avatar_stack.dart';

class FamilyCircleTile extends StatelessWidget {
  const FamilyCircleTile({
    super.key,
    required this.circle,
    required this.members,
    required this.isDark,
  });

  final Map<String, dynamic> circle;
  final List<Map<String, dynamic>> members;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<FamilyCircleBloc>().add(FamilyCircleSelected(circle)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            MemberAvatarStack(members),
            const SizedBox(width: 18),
            Expanded(
              child: _CircleCopy(
                circle: circle,
                members: members,
                isDark: isDark,
              ),
            ),
            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}

class _CircleCopy extends StatelessWidget {
  const _CircleCopy({
    required this.circle,
    required this.members,
    required this.isDark,
  });

  final Map<String, dynamic> circle;
  final List<Map<String, dynamic>> members;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${members.length} members',
          style: TextStyle(fontFamily: 'Inter', color: Colors.grey.shade500),
        ),
        Text(
          '${circle['name'] ?? 'Unnamed Circle'}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
