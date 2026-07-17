part of '../sos_bottom_sheet.dart';

extension _SosBottomSheetActions on _SosBottomSheetState {
  Future<void> triggerSos() async {
    if (widget.circleId.isEmpty) {
      refresh(() {
        _status = SosSheetStatus.failure;
        _errorMessage = 'Select or create a circle before activating SOS.';
      });
      return;
    }

    try {
      if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 650);
      final latitude = _latitude ?? widget.fallbackLatitude;
      final longitude = _longitude ?? widget.fallbackLongitude;
      final address = _address ?? await resolveAddress(latitude, longitude);
      final result = await ApiService.triggerSos(
        circleId: widget.circleId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      await NotificationService.showLocalNotification(
        title: 'SOS Broadcast Dispatched',
        body: 'Your circle has been notified and can see your live location.', payload: '',
      );

      if (!mounted) return;
      refresh(() {
        _status = SosSheetStatus.active;
        _broadcastId =
            result['id']?.toString() ?? result['broadcast_id']?.toString();
        _address = address;
      });
      widget.onLocationResolved?.call(latitude, longitude);
      widget.onActiveChanged?.call(true);
      widget.onActivated?.call(_broadcastId, address);
    } catch (e) {
      if (!mounted) return;
      refresh(() {
        _status = SosSheetStatus.failure;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> cancelActiveSos() async {
    if (_isResolving) return;
    refresh(() => _isResolving = true);
    try {
      final id = _broadcastId;
      if (id == null || id.isEmpty) {
        throw Exception('Could not find the active SOS broadcast to cancel.');
      }

      await ApiService.dismissSos(id);
      if (!mounted) return;
      refresh(() {
        _status = SosSheetStatus.cancelled;
        _broadcastId = null;
      });
      widget.onActiveChanged?.call(false);
      widget.onClosed?.call();
    } catch (e) {
      if (!mounted) return;
      refresh(() {
        _status = SosSheetStatus.failure;
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) refresh(() => _isResolving = false);
    }
  }

  void cancelActivation() {
    _timer?.cancel();
    refresh(() => _status = SosSheetStatus.cancelled);
    widget.onActiveChanged?.call(false);
  }

  void closeSheet() {
    widget.onClosed?.call();
    Navigator.of(context).pop();
  }

  void retryActivation() {
    refresh(() {
      _status = SosSheetStatus.activating;
      _secondsRemaining = 3;
      _errorMessage = null;
    });
    startCountdown();
  }
}
