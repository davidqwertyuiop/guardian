import 'package:guardian/core/services/api_service.dart';

class AuthRemoteDataSource {
  Future<String> firebaseExchange(String phone, String idToken) async {
    final response = await ApiService.firebaseExchange(phone, idToken);
    return response['access_token'] as String;
  }
}
