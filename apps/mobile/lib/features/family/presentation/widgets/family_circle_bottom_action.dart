import 'package:flutter/material.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_state.dart';
import 'family_sheet_actions.dart';

class FamilyCircleBottomAction extends StatelessWidget {
  const FamilyCircleBottomAction({super.key, required this.state});

  final FamilyCircleState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => state.isOwner
              ? confirmDeleteCircle(context, state.selectedCircleId!)
              : confirmLeaveCircle(
                  context,
                  state.selectedCircleId!,
                  state.selectedCircleName ?? 'circle',
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: state.isOwner
                ? const Color(0xFFEFEFF2)
                : Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            state.isOwner ? 'Delete circle' : 'Leave this circle',
            style: TextStyle(
              fontFamily: 'Inter',
              color: state.isOwner ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
