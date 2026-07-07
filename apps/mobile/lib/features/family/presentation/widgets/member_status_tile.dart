import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'member_status_helpers.dart';

class MemberStatusTile extends StatelessWidget {
  const MemberStatusTile({
    super.key,
    required this.member,
    required this.state,
    required this.isDark,
  });

  final Map<String, dynamic> member;
  final FamilyCircleState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final id = member['user_id'] as String;
    final isMe = id == state.currentUserId;
    final loc = state.memberLocations[id];
    final expanded = state.expandedMemberId == id;
    final sharing = loc != null;
    final battery = isMe
        ? state.batteryLevel
        : (loc?['battery_level'] as num?)?.toInt() ?? 0;
    final network = isMe
        ? state.connectivityType
        : (loc?['connectivity_type'] as String?) ?? 'Cellular';
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        key: ValueKey(id),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => context.read<FamilyCircleBloc>().add(
          FamilyMemberExpanded(value ? id : null),
        ),
        title: Text(
          '${member['name'] ?? 'User'}',
          style: memberNameStyle(isDark),
        ),
        subtitle: Text(
          memberJoinedText(member, isMe),
          style: memberSubStyle(isDark),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: sharing ? const Color(0xFF22C55E) : Colors.grey.shade300,
              size: 7,
            ),
            const SizedBox(width: 10),
            Text(
              sharing ? 'Sharing location' : 'Location paused',
              style: memberStatusStyle(sharing),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Column(
              children: [
                memberMetric(
                  'Battery',
                  battery == 0 ? 'Unknown' : '$battery%',
                  isDark,
                ),
                memberMetric('Network', network, isDark),
                if (state.isOwner && !isMe)
                  removeMemberButton(
                    () => context.read<FamilyCircleBloc>().add(
                      FamilyRemoveMemberSubmitted(id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
