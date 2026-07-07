import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:guardian/export.dart';

class CertificatePinning {
  static bool verify(X509Certificate cert, String host, int port) {
    final pins = EnvConfig.certificateSha256Pins;
    if (pins.isEmpty) {
      log('CertificatePinning has no configured pins for $host:$port.');
      return !kReleaseMode;
    }

    final fingerprint = sha256.convert(cert.der).toString().toLowerCase();
    final isPinned = pins.contains(fingerprint);
    if (!isPinned) {
      log('Certificate pin mismatch for $host:$port.');
    }

    return isPinned;
  }
}
