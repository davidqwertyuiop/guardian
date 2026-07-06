import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardian/core/services/notification_service.dart';
import 'package:guardian/export.dart';
import 'package:vibration/vibration.dart';

enum SosSheetStatus { activating, active, cancelled, failure }

class SosBottomSheet extends StatefulWidget {
  final String circleId;
  final double fallbackLatitude;
  final double fallbackLongitude;
  final VoidCallback? onClosed;

  const SosBottomSheet({
    super.key,
    required this.circleId,
    required this.fallbackLatitude,
    required this.fallbackLongitude,
    this.onClosed,
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

  @override
  void initState() {
    super.initState();
    _prepareLocation();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _prepareLocation() async {
    var latitude = widget.fallbackLatitude;
    var longitude = widget.fallbackLongitude;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (_) {}

    final address = await _resolveAddress(latitude, longitude);
    if (!mounted) return;
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _address = address;
    });
  }

  Future<String> _resolveAddress(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality,
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            place.administrativeArea,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}

    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _triggerSos();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  Future<void> _triggerSos() async {
    if (widget.circleId.isEmpty) {
      setState(() {
        _status = SosSheetStatus.failure;
        _errorMessage = 'Select or create a circle before activating SOS.';
      });
      return;
    }

    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 650);
      }

      final latitude = _latitude ?? widget.fallbackLatitude;
      final longitude = _longitude ?? widget.fallbackLongitude;
      final address = _address ?? await _resolveAddress(latitude, longitude);
      final result = await ApiService.triggerSos(
        circleId: widget.circleId,
        latitude: latitude,
        longitude: longitude,
        address: address,
      );

      await NotificationService.showLocalNotification(
        title: 'SOS Broadcast Dispatched',
        body: 'Your circle has been notified and can see your live location.',
      );

      if (!mounted) return;
      setState(() {
        _status = SosSheetStatus.active;
        _broadcastId =
            result['id']?.toString() ?? result['broadcast_id']?.toString();
        _address = address;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = SosSheetStatus.failure;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _cancelActiveSos() async {
    if (_isResolving) return;
    setState(() => _isResolving = true);
    try {
      final id = _broadcastId;
      if (id != null && id.isNotEmpty) {
        await ApiService.dismissSos(id);
      }
      if (!mounted) return;
      setState(() => _status = SosSheetStatus.cancelled);
      widget.onClosed?.call();
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  void _cancelActivation() {
    _timer?.cancel();
    setState(() => _status = SosSheetStatus.cancelled);
  }

  void _close() {
    widget.onClosed?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFFFF8FB),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _CloseButton(onTap: _close),
              ),
              _SosIcon(status: _status),
              const SizedBox(height: 18),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              if (_status == SosSheetStatus.active) ...[
                const SizedBox(height: 20),
                Text(
                  _address ?? 'Updating location...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Updated just now.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 18),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 12),
                _VisibilityList(isDark: isDark),
              ],
              if (_status == SosSheetStatus.failure &&
                  _errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _ActionButton(
                text: _buttonText,
                isLoading: _isResolving,
                onPressed: _buttonAction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title {
    return switch (_status) {
      SosSheetStatus.activating => 'Activating SOS...',
      SosSheetStatus.active => 'SOS ACTIVE',
      SosSheetStatus.cancelled => 'SOS cancelled',
      SosSheetStatus.failure => 'SOS failed',
    };
  }

  String get _subtitle {
    return switch (_status) {
      SosSheetStatus.activating => 'Your circle is being notified.',
      SosSheetStatus.active =>
        'Your circle has been notified.\nThey can see your location now.',
      SosSheetStatus.cancelled =>
        'Glad you are safe. Your circle has been notified.',
      SosSheetStatus.failure =>
        'We could not notify your circle. Please try again.',
    };
  }

  String get _buttonText {
    return switch (_status) {
      SosSheetStatus.activating => 'Cancel - I tapped by mistake',
      SosSheetStatus.active => "I'm safe - cancel SOS",
      SosSheetStatus.cancelled => 'Go home',
      SosSheetStatus.failure => 'Try again',
    };
  }

  VoidCallback get _buttonAction {
    return switch (_status) {
      SosSheetStatus.activating => _cancelActivation,
      SosSheetStatus.active => _cancelActiveSos,
      SosSheetStatus.cancelled => _close,
      SosSheetStatus.failure => () {
        setState(() {
          _status = SosSheetStatus.activating;
          _secondsRemaining = 3;
          _errorMessage = null;
        });
        _startCountdown();
      },
    };
  }
}

class _SosIcon extends StatelessWidget {
  final SosSheetStatus status;

  const _SosIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final asset = switch (status) {
      SosSheetStatus.activating => AppAssets.activatingSosIcon,
      SosSheetStatus.active => AppAssets.sosIcon,
      SosSheetStatus.cancelled => AppAssets.stopBroadcastingIcon,
      SosSheetStatus.failure => AppAssets.sosIcon,
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFF2D7A).withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Center(child: Image.asset(asset, width: 20, height: 20)),
    );
  }
}

class _VisibilityList extends StatelessWidget {
  final bool isDark;

  const _VisibilityList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white70 : Colors.black54;
    return Column(
      children: [
        Text(
          'Your circle can see:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: color),
        ),
        const SizedBox(height: 8),
        _item('Your live location', color),
        _item('Your battery level', color),
        _item('This SOS alert', color),
      ],
    );
  }

  Widget _item(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '✓ $text',
        style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: color),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 16,
          color: isDark ? Colors.white60 : Colors.black38,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
