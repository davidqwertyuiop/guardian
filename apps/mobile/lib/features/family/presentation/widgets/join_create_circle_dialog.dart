import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_bloc.dart';
import 'package:guardian/features/family/presentation/bloc/family_circle_event.dart';

class JoinCreateCircleDialog extends StatefulWidget {
  const JoinCreateCircleDialog({super.key});

  @override
  State<JoinCreateCircleDialog> createState() => _JoinCreateCircleDialogState();
}

class _JoinCreateCircleDialogState extends State<JoinCreateCircleDialog> {
  final join = TextEditingController();
  final create = TextEditingController();

  @override
  void dispose() {
    join.dispose();
    create.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: DefaultTabController(
      length: 2,
      child: SizedBox(
        width: 320,
        height: 260,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Join Circle'),
                Tab(text: 'Create Circle'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [_tab(join, true), _tab(create, false)],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tab(TextEditingController controller, bool isJoin) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: isJoin ? 'Code or link' : 'Circle name',
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _submit(controller.text.trim(), isJoin),
            child: Text(isJoin ? 'Join Circle' : 'Create Circle'),
          ),
        ],
      ),
    );
  }

  void _submit(String value, bool isJoin) {
    if (value.isEmpty) return;
    Navigator.pop(context);
    context.read<FamilyCircleBloc>().add(
      isJoin ? FamilyJoinSubmitted(value) : FamilyCreateSubmitted(value),
    );
  }
}
