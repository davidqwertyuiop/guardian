import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<String> execute(String phone, String code) async {
    return await repository.verifyOtp(phone, code);
  }
}
