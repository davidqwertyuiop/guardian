import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'package:guardian/features/family/presentation/widgets/family_circle_view.dart';

class FamilyCircleScreen extends StatelessWidget {
  const FamilyCircleScreen({super.key, this.onNavigationVisibilityChanged});

  final ValueChanged<bool>? onNavigationVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<FamilyCircleBloc>()..add(const FamilyStarted()),
      child: FamilyCircleView(
        onNavigationVisibilityChanged: onNavigationVisibilityChanged,
      ),
    );
  }
}
