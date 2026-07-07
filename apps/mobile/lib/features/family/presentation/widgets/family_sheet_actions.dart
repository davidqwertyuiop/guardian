import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';
import 'join_create_circle_dialog.dart';
import 'leave_circle_sheet.dart';

Future<void> showJoinOrCreateCircleDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<FamilyCircleBloc>(),
      child: const JoinCreateCircleDialog(),
    ),
  );
}

Future<void> confirmLeaveCircle(BuildContext context, String id, String name) {
  final sheet = LeaveCircleSheet(circleName: name, circleId: id);
  final child = BlocProvider.value(
    value: context.read<FamilyCircleBloc>(),
    child: Material(type: MaterialType.transparency, child: sheet),
  );
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showCupertinoModalPopup(context: context, builder: (_) => child);
  }
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => child,
  );
}

Future<void> confirmDeleteCircle(BuildContext context, String id) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete circle'),
      content: const Text('This removes the circle for every member.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<FamilyCircleBloc>().add(FamilyDeleteSubmitted(id));
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
