import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource = AuthRemoteDataSource();

  @override
  Future<void> sendOtp(String phone) async {
    await remoteDataSource.sendOtp(phone);
  }

  @override
  Future<String> verifyOtp(String phone, String code) async {
    return await remoteDataSource.verifyOtp(phone, code);
  }
}
