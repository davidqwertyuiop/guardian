import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<void> execute(String phone) async {
    await repository.sendOtp(phone);
  }
}
