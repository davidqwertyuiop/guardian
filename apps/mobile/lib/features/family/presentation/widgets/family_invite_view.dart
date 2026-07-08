import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'invite_code_section.dart';
import 'invite_link_section.dart';

class FamilyInviteView extends StatelessWidget {
  const FamilyInviteView({super.key, required this.state});

  final FamilyCircleState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final link = state.inviteLink;
    final code = state.inviteCode;
    final shareText = [if (code != null) 'Code: $code', ?link].join(' ');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.read<FamilyCircleBloc>().add(const FamilyDetailsRequested());
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 350) {
            context.read<FamilyCircleBloc>().add(
              const FamilyDetailsRequested(),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 54, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                  child: Image.asset(AppAssets.inviteIcon),
                ),
                const SizedBox(height: 18),
                Text('Invite to your circle', style: _title(fg)),
                const SizedBox(height: 8),
                Text(
                  'Share this link with anyone you want to add.',
                  style: _muted(isDark),
                ),
                const SizedBox(height: 18),
                InviteLinkSection(link: link, shareText: shareText),
                const SizedBox(height: 36),
                InviteCodeSection(code: code, isDark: isDark, foreground: fg),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.read<FamilyCircleBloc>().add(
                      const FamilyDetailsRequested(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _title(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color,
  );
  TextStyle _muted(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    color: isDark ? Colors.white54 : Colors.black45,
  );
}
