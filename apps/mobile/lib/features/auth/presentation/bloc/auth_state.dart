import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, codeSent, success, profileCompleted, failure }

enum AuthStep {
  splash,
  welcome,
  login,
  otp,
  profile,
  location,
  notifications,
  almostIn,
  nameCircle,
  enterInviteCode,
  pasteLink,
  circleEmpty,
  completed
}

class AuthState extends Equatable {
  final String countryCode;
  final String dialCode;
  final String phoneNumber;
  final AuthStatus status;
  final AuthStep step;
  final String? errorMessage;
  final String username;
  final bool isJoiningCircle;
  final String? verificationId;
  final bool triggerNavigation;
  final String? inviteCode;
  final String? inviteLink;

  const AuthState({
    required this.countryCode,
    required this.dialCode,
    required this.phoneNumber,
    required this.status,
    required this.step,
    this.errorMessage,
    required this.username,
    required this.isJoiningCircle,
    this.verificationId,
    this.triggerNavigation = true,
    this.inviteCode,
    this.inviteLink,
  });

  factory AuthState.initial({AuthStep step = AuthStep.welcome}) {
    return AuthState(
      countryCode: 'NG',
      dialCode: '+234',
      phoneNumber: '',
      status: AuthStatus.initial,
      step: step,
      username: '',
      isJoiningCircle: false,
      triggerNavigation: true,
      inviteCode: null,
      inviteLink: null,
    );
  }

  AuthState copyWith({
    String? countryCode,
    String? dialCode,
    String? phoneNumber,
    AuthStatus? status,
    AuthStep? step,
    String? errorMessage,
    String? username,
    bool? isJoiningCircle,
    String? verificationId,
    bool? triggerNavigation,
    String? inviteCode,
    String? inviteLink,
  }) {
    return AuthState(
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      step: step ?? this.step,
      errorMessage: errorMessage,
      username: username ?? this.username,
      isJoiningCircle: isJoiningCircle ?? this.isJoiningCircle,
      verificationId: verificationId ?? this.verificationId,
      triggerNavigation: triggerNavigation ?? true,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteLink: inviteLink ?? this.inviteLink,
    );
  }

  @override
  List<Object?> get props => [
        countryCode,
        dialCode,
        phoneNumber,
        status,
        step,
        errorMessage,
        username,
        isJoiningCircle,
        verificationId,
        triggerNavigation,
        inviteCode,
        inviteLink,
      ];
}
