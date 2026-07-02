import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Starts the phone number verification process.
  /// Returns a Future that completes with the `verificationId` when the SMS is sent.
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (e.g. Android reading SMS instantly)
        log('PhoneAuth auto-resolved: ${credential.smsCode}');
        // Note: For a unified flow, we typically ignore auto-resolution here
        // and let the user type it, or handle it specifically in the UI.
        // For now, we just log it.
      },
      verificationFailed: (FirebaseAuthException e) {
        log('PhoneAuth failed: ${e.message}');
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? 'Verification failed'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        log('PhoneAuth code sent. verId: $verificationId');
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('PhoneAuth timeout for verId: $verificationId');
        // We do not complete the completer here because codeSent should have already fired.
      },
    );

    return completer.future;
  }

  /// Exchanges the SMS code for a Firebase ID Token.
  Future<String> verifyOtpAndGetIdToken({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken(true);

    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID Token');
    }

    return idToken;
  }
}
