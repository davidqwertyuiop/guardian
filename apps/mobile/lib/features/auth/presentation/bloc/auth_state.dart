import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, codeSent, success, failure }

class AuthState extends Equatable {
  final String countryCode;
  final String dialCode;
  final String phoneNumber;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.countryCode,
    required this.dialCode,
    required this.phoneNumber,
    required this.status,
    this.errorMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      countryCode: 'NG',
      dialCode: '+234',
      phoneNumber: '',
      status: AuthStatus.initial,
    );
  }

  AuthState copyWith({
    String? countryCode,
    String? dialCode,
    String? phoneNumber,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [countryCode, dialCode, phoneNumber, status, errorMessage];
}
