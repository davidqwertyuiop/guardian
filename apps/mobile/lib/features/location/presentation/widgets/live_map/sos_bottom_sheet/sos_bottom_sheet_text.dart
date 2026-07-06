part of '../sos_bottom_sheet.dart';

extension _SosBottomSheetText on _SosBottomSheetState {
  String get titleText {
    return switch (_status) {
      SosSheetStatus.activating => 'Activating SOS...',
      SosSheetStatus.active => 'SOS ACTIVE',
      SosSheetStatus.cancelled => 'SOS cancelled',
      SosSheetStatus.failure => 'SOS failed',
    };
  }

  String get subtitleText {
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

  String get buttonText {
    return switch (_status) {
      SosSheetStatus.activating => 'Cancel - I tapped by mistake',
      SosSheetStatus.active => "I'm safe - cancel SOS",
      SosSheetStatus.cancelled => 'Go home',
      SosSheetStatus.failure => 'Try again',
    };
  }

  VoidCallback get buttonAction {
    return switch (_status) {
      SosSheetStatus.activating => cancelActivation,
      SosSheetStatus.active => cancelActiveSos,
      SosSheetStatus.cancelled => closeSheet,
      SosSheetStatus.failure => retryActivation,
    };
  }
}
