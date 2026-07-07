import 'package:flutter/services.dart';

class RadioTypeService {
  static const _channel = MethodChannel('guardian/radio_type');

  Future<String> mobileRadioType() async {
    try {
      final value = await _channel.invokeMethod<String>('mobileRadioType');
      if (value == null || value.trim().isEmpty) return 'Cellular';
      return value;
    } catch (_) {
      return 'Cellular';
    }
  }
}
