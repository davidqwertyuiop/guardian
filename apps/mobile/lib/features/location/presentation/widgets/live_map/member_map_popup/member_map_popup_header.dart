import 'package:flutter/material.dart';
import 'package:guardian/features/family/presentation/widgets/family_back_button.dart';

class MemberMapPopupHeader extends StatelessWidget {
  const MemberMapPopupHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FamilyBackButton(onPressed: onBack),
      ),
    );
  }
}
