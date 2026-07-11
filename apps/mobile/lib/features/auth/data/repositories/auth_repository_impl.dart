import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource = AuthRemoteDataSource();

  @override
  Future<bool> sendOtp(String phone) async {
    return await remoteDataSource.sendOtp(phone);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    return await remoteDataSource.verifyOtp(phone, code);
  }
}
