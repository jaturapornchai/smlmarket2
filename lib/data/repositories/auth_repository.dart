import '../data_sources/auth_remote_data_source.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String username, String password);
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> login(String username, String password) async {
    return await remoteDataSource.login(username, password);
  }

  @override
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    return await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }
}
