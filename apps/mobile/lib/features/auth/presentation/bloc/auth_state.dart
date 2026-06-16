import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, codeSent, success, profileCompleted, failure }

class AuthState extends Equatable {
  final String countryCode;
  final String dialCode;
  final String phoneNumber;
  final AuthStatus status;
  final String? errorMessage;
  final String username;

  const AuthState({
    required this.countryCode,
    required this.dialCode,
    required this.phoneNumber,
    required this.status,
    this.errorMessage,
    required this.username,
  });

  factory AuthState.initial() {
    return const AuthState(
      countryCode: 'NG',
      dialCode: '+234',
      phoneNumber: '',
      status: AuthStatus.initial,
      username: '',
    );
  }

  AuthState copyWith({
    String? countryCode,
    String? dialCode,
    String? phoneNumber,
    AuthStatus? status,
    String? errorMessage,
    String? username,
  }) {
    return AuthState(
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [countryCode, dialCode, phoneNumber, status, errorMessage, username];
}
