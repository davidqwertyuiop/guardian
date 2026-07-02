abstract class AuthRepository {
  Future<String> firebaseExchange(String phone, String idToken);
}
