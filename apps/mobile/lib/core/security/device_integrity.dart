import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceIntegrity {
  Future<bool> checkIntegrity() async {
    if (!kReleaseMode) {
      debugPrint('DeviceIntegrity: skipped in non-release build.');
      return true;
    }

    try {
      if (Platform.isAndroid) return _checkAndroid();
      if (Platform.isIOS) return _checkIos();
      return false;
    } catch (error) {
      debugPrint('DeviceIntegrity: failed to verify device: $error');
      return false;
    }
  }

  Future<bool> _checkAndroid() async {
    final info = await DeviceInfoPlugin().androidInfo;
    final tags = info.tags.toLowerCase();
    if (!info.isPhysicalDevice || tags.contains('test-keys')) return false;

    const rootPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
    ];

    return !rootPaths.any((path) => File(path).existsSync());
  }

  Future<bool> _checkIos() async {
    final info = await DeviceInfoPlugin().iosInfo;
    if (!info.isPhysicalDevice) return false;

    const jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];

    return !jailbreakPaths.any((path) => File(path).existsSync());
  }
}
