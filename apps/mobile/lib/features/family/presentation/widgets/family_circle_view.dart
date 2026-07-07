import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'family_details_view.dart';
import 'family_invite_view.dart';
import 'family_overview_view.dart';
import 'family_sheet_actions.dart';

class FamilyCircleView extends StatelessWidget {
  const FamilyCircleView({super.key, this.onNavigationVisibilityChanged});

  final ValueChanged<bool>? onNavigationVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyCircleBloc, FamilyCircleState>(
      listenWhen: (previous, current) =>
          previous.mode != current.mode ||
          previous.errorMessage != current.errorMessage ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        onNavigationVisibilityChanged?.call(
          state.mode == FamilyViewMode.overview,
        );
        final message = state.errorMessage ?? state.actionMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          if (state.actionMessage != null) {
            context.read<FamilyCircleBloc>().add(const FamilyStarted());
          }
        }
      },
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF080808)
              : const Color(0xFFF7F7FA),
          body: switch (state.mode) {
            FamilyViewMode.overview => FamilyOverviewView(
              state: state,
              onJoinPressed: () => showJoinOrCreateCircleDialog(context),
            ),
            FamilyViewMode.details => FamilyDetailsView(state: state),
            FamilyViewMode.invite => FamilyInviteView(state: state),
          },
        );
      },
    );
  }
}
