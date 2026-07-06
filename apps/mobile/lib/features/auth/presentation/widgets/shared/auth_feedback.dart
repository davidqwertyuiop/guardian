import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../bloc/auth_error_parser.dart';

class AuthFeedback {
  const AuthFeedback._();

  static void showError(BuildContext context, String message) {
    final cleanMessage = AuthErrorParser.cleanForUi(message);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      toastification.show(
        context: context,
        style: ToastificationStyle.minimal,
        title: const Text(
          'Something went wrong',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        description: Text(
          cleanMessage,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 4),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cleanMessage),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
