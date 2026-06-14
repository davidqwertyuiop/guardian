import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CountryChanged extends AuthEvent {
  final String countryCode;
  final String dialCode;

  const CountryChanged({required this.countryCode, required this.dialCode});

  @override
  List<Object?> get props => [countryCode, dialCode];
}

class PhoneNumberChanged extends AuthEvent {
  final String phoneNumber;

  const PhoneNumberChanged(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class SubmitPhoneNumber extends AuthEvent {
  const SubmitPhoneNumber();
}

class SubmitVerificationCode extends AuthEvent {
  final String code;

  const SubmitVerificationCode(this.code);

  @override
  List<Object?> get props => [code];
}

class ResetAuth extends AuthEvent {
  const ResetAuth();
}
