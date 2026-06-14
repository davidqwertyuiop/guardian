abstract class AuthRepository {
  Future<void> sendOtp(String phone);
  Future<String> verifyOtp(String phone, String code);
}
