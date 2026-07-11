import 'package:guardian/core/services/api_service.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    return await ApiService.verifyOtp(phone, code);
  }
  
  Future<bool> sendOtp(String phone) async {
    return await ApiService.sendOtp(phone);
  }
}
