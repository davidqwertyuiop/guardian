# auth_event.dart

* **File Path:** `apps/mobile/lib/features/auth/presentation/bloc/auth_event.dart`
* **Type:** `DART`

---

```dart
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

class CompleteProfile extends AuthEvent {
  final String username;

  const CompleteProfile(this.username);

  @override
  List<Object?> get props => [username];
}

class NavigateToLogin extends AuthEvent {
  const NavigateToLogin();
}

class NavigateToWelcome extends AuthEvent {
  const NavigateToWelcome();
}

class NavigateBack extends AuthEvent {
  final bool isNativePop;
  const NavigateBack({this.isNativePop = false});

  @override
  List<Object?> get props => [isNativePop];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class EnableLocation extends AuthEvent {
  const EnableLocation();
}

class SkipLocation extends AuthEvent {
  const SkipLocation();
}

class EnableNotifications extends AuthEvent {
  const EnableNotifications();
}

class SkipNotifications extends AuthEvent {
  const SkipNotifications();
}

// New events for the circle flow
class ClickInviteLink extends AuthEvent {
  const ClickInviteLink();
}

class SelectCreateCircle extends AuthEvent {
  const SelectCreateCircle();
}

class SelectJoinCircle extends AuthEvent {
  const SelectJoinCircle();
}

class CreateCircle extends AuthEvent {
  final String circleName;
  const CreateCircle(this.circleName);

  @override
  List<Object?> get props => [circleName];
}

class SubmitInviteCode extends AuthEvent {
  final String code;
  const SubmitInviteCode(this.code);

  @override
  List<Object?> get props => [code];
}

class CompleteCircleOnboarding extends AuthEvent {
  const CompleteCircleOnboarding();
}

class NavigateToPasteLink extends AuthEvent {
  const NavigateToPasteLink();
}

class SubmitInviteLink extends AuthEvent {
  final String link;
  const SubmitInviteLink(this.link);

  @override
  List<Object?> get props => [link];
}

```
