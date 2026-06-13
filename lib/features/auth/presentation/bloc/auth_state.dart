import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, codeSent, success, failure }

class AuthState extends Equatable {
  final String phoneNumber;
  final String countryCode;
  final String dialCode;
  final AuthStatus status;
  final String? errorMessage;
  final String? verificationCode;

  const AuthState({
    required this.phoneNumber,
    required this.countryCode,
    required this.dialCode,
    required this.status,
    this.errorMessage,
    this.verificationCode,
  });

  factory AuthState.initial() {
    return const AuthState(
      phoneNumber: '',
      countryCode: 'NG',
      dialCode: '+234',
      status: AuthStatus.initial,
    );
  }

  AuthState copyWith({
    String? phoneNumber,
    String? countryCode,
    String? dialCode,
    AuthStatus? status,
    String? errorMessage,
    String? verificationCode,
  }) {
    return AuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      status: status ?? this.status,
      errorMessage: errorMessage, // Reset if not explicitly passed
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        countryCode,
        dialCode,
        status,
        errorMessage,
        verificationCode,
      ];
}
