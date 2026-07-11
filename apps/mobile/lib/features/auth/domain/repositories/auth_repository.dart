abstract class AuthRepository {
  Future<bool> sendOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp(String phone, String code);
}
