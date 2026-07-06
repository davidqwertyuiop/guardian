import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/export.dart';
import 'package:vibration/vibration.dart';

part 'sos_bottom_sheet/sos_bottom_sheet_controller.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_actions.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_content.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_text.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_widgets.dart';
part 'sos_bottom_sheet/sos_active_details.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_controls.dart';
part 'sos_bottom_sheet/sos_bottom_sheet_button_parts.dart';
part 'sos_bottom_sheet/sos_visibility_list.dart';

enum SosSheetStatus { activating, active, cancelled, failure }

class SosBottomSheet extends StatefulWidget {
  final String circleId;
  final double fallbackLatitude;
  final double fallbackLongitude;
  final VoidCallback? onClosed;
  final ValueChanged<bool>? onActiveChanged;
  final void Function(String? broadcastId, String? address)? onActivated;
  final String? initialBroadcastId;
  final String? initialAddress;
  final bool startActive;

  const SosBottomSheet({
    super.key,
    required this.circleId,
    required this.fallbackLatitude,
    required this.fallbackLongitude,
    this.onClosed,
    this.onActiveChanged,
    this.onActivated,
    this.initialBroadcastId,
    this.initialAddress,
    this.startActive = false,
  });

  @override
  State<SosBottomSheet> createState() => _SosBottomSheetState();
}

class _SosBottomSheetState extends State<SosBottomSheet> {
  Timer? _timer;
  SosSheetStatus _status = SosSheetStatus.activating;
  int _secondsRemaining = 3;
  double? _latitude;
  double? _longitude;
  String? _address;
  String? _broadcastId;
  String? _errorMessage;
  bool _isResolving = false;

  void refresh(VoidCallback callback) => setState(callback);

  @override
  void initState() {
    super.initState();
    if (widget.startActive) {
      _status = SosSheetStatus.active;
      _broadcastId = widget.initialBroadcastId;
      _address = widget.initialAddress;
    }
    prepareLocation();
    if (!widget.startActive) {
      startCountdown();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildSheetContent(context);
}
