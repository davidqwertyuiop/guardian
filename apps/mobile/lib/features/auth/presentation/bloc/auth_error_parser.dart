import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorParser {
  const AuthErrorParser._();

  static String parse(dynamic error) {
    final message = error.toString();
    if (message.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (message.contains('invalid-verification-code')) {
      return 'Invalid code. Please check and try again.';
    }
    if (message.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (message.contains('user-disabled')) {
      return 'This account has been disabled.';
    }
    if (message.contains('session-expired')) {
      return 'Session expired. Please request a new code.';
    }
    if (error is FirebaseAuthException) {
      return error.message ?? 'An authentication error occurred.';
    }
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }

  static String cleanForUi(String message) {
    if (!message.contains(':')) return message;
    return message.substring(message.lastIndexOf(':') + 1).trim();
  }
}
