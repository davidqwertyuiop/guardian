import 'package:guardian/core/services/api_service.dart';

class AuthRemoteDataSource {
  Future<void> sendOtp(String phone) async {
    await ApiService.sendOtp(phone);
  }

  Future<String> verifyOtp(String phone, String code) async {
    final response = await ApiService.verifyOtp(phone, code);
    return response['access_token'] as String;
  }
}
