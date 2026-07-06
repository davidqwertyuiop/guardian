# address_text.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/widgets/live_map/address_text.dart`
* **Type:** `DART`

---

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';

class AddressText extends StatefulWidget {
  final double latitude;
  final double longitude;
  const AddressText({super.key, required this.latitude, required this.longitude});

  @override
  State<AddressText> createState() => AddressTextState();
}

class AddressTextState extends State<AddressText> {
  String _address = 'Loading location...';

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  void didUpdateWidget(covariant AddressText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _fetchAddress();
    }
  }

  Future<void> _fetchAddress() async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
        ];
        if (mounted) {
          setState(() {
            _address = parts.join(', ');
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _address =
              '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _address,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

```
