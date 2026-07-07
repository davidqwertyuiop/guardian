import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';

class FamilyDetailsHeader extends StatelessWidget {
  const FamilyDetailsHeader({super.key, required this.state});

  final FamilyCircleState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => context.read<FamilyCircleBloc>().add(
                  const FamilyOverviewRequested(),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Spacer(),
              Text(state.selectedCircleName ?? 'Circle', style: _title(isDark)),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '(${state.currentMembers.length.toString().padLeft(2, '0')}) members',
                style: _body(isDark),
              ),
              if (state.isOwner)
                ElevatedButton(
                  onPressed: () => context.read<FamilyCircleBloc>().add(
                    const FamilyInviteRequested(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Invite user',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFFFFAADE),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _title(bool dark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: dark ? Colors.white : Colors.black,
  );
  TextStyle _body(bool dark) => TextStyle(
    fontFamily: 'Geist',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: dark ? Colors.white : Colors.black,
  );
}
