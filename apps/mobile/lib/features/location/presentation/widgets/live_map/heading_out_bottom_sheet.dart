import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'member_avatar_row.dart';

part 'heading_out_bottom_sheet/heading_out_actions.dart';
part 'heading_out_bottom_sheet/heading_out_content.dart';
part 'heading_out_bottom_sheet/heading_out_dropdown.dart';
part 'heading_out_bottom_sheet/heading_out_circle_selector.dart';
part 'heading_out_bottom_sheet/heading_out_circle_card.dart';
part 'heading_out_bottom_sheet/heading_out_circle_name.dart';
part 'heading_out_bottom_sheet/heading_out_header.dart';
part 'heading_out_bottom_sheet/heading_out_fields.dart';
part 'heading_out_bottom_sheet/heading_out_ios_dropdown.dart';
part 'heading_out_bottom_sheet/heading_out_material_dropdown.dart';
part 'heading_out_bottom_sheet/heading_out_field_parts.dart';
part 'heading_out_bottom_sheet/heading_out_sections.dart';
part 'heading_out_bottom_sheet/heading_out_section_widgets.dart';
part 'heading_out_bottom_sheet/heading_out_start_button.dart';

class HeadingOutBottomSheet extends StatefulWidget {
  final String initialCircleId;
  final String initialCircleName;
  final List<dynamic> initialMembers;

  const HeadingOutBottomSheet({
    super.key,
    required this.initialCircleId,
    required this.initialCircleName,
    required this.initialMembers,
  });

  @override
  State<HeadingOutBottomSheet> createState() => _HeadingOutBottomSheetState();
}

class _HeadingOutBottomSheetState extends State<HeadingOutBottomSheet> {
  String _selectedDestination = 'Home';
  String _selectedDuration = '30 Mins';
  final TextEditingController _customDestController = TextEditingController();
  final TextEditingController _customDurController = TextEditingController();

  final List<String> _destinationOptions = ['Home', 'Work', 'School', 'Custom'];
  final List<String> _durationOptions = [
    '30 Mins',
    '1 Hr',
    '2 Hrs',
    'Until I arrive',
    'Custom',
  ];

  void refresh(VoidCallback callback) => setState(callback);

  @override
  void dispose() {
    _customDestController.dispose();
    _customDurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildSheet(context);
}
