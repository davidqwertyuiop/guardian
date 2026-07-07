import 'package:flutter/material.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'family_circle_bottom_action.dart';
import 'family_details_header.dart';
import 'member_status_tile.dart';

class FamilyDetailsView extends StatelessWidget {
  const FamilyDetailsView({super.key, required this.state});

  final FamilyCircleState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FamilyDetailsHeader(state: state),
          const SizedBox(height: 20),
          Expanded(
            child: state.status == FamilyStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.currentMembers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => MemberStatusTile(
                      member: state.currentMembers[index],
                      state: state,
                      isDark: isDark,
                    ),
                  ),
          ),
          FamilyCircleBottomAction(state: state),
        ],
      ),
    );
  }
}
