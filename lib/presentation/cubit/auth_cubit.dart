import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final Logger logger;

  AuthCubit({required this.repository, required this.logger})
    : super(AuthInitial());

  /// เข้าสู่ระบบ
  Future<void> login(String username, String password) async {
    try {
      emit(AuthLoading());
      logger.i('Attempting login for user: $username');

      final authResponse = await repository.login(username, password);

      emit(
        AuthAuthenticated(user: authResponse.user, token: authResponse.token),
      );

      logger.i('Successfully logged in user: ${authResponse.user.username}');
    } catch (e) {
      logger.e('Error during login: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// ลงทะเบียนผู้ใช้ใหม่
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      emit(AuthLoading());
      logger.i('Attempting registration for user: $username');

      final authResponse = await repository.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      emit(
        AuthRegistrationSuccess(
          user: authResponse.user,
          token: authResponse.token,
        ),
      );

      logger.i('Successfully registered user: ${authResponse.user.username}');
    } catch (e) {
      logger.e('Error during registration: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// ออกจากระบบ
  Future<void> logout() async {
    try {
      emit(AuthLoading());
      logger.i('Logging out user');

      await repository.logout();

      emit(AuthUnauthenticated());

      logger.i('Successfully logged out');
    } catch (e) {
      logger.e('Error during logout: $e');
      emit(AuthUnauthenticated()); // Still logout on error
    }
  }

  /// ตรวจสอบสถานะการเข้าสู่ระบบ
  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      logger.i('Checking auth status');

      final user = await repository.getCurrentUser();

      if (user != null) {
        emit(
          AuthAuthenticated(
            user: user,
            token: 'stored_token', // In real app, get from secure storage
          ),
        );
        logger.i('User is authenticated: ${user.username}');
      } else {
        emit(AuthUnauthenticated());
        logger.i('User is not authenticated');
      }
    } catch (e) {
      logger.e('Error checking auth status: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// รีเซ็ตสถานะ
  void reset() {
    emit(AuthInitial());
  }

  /// ดูสถานะการเข้าสู่ระบบปัจจุบัน
  bool get isAuthenticated {
    return state is AuthAuthenticated;
  }

  /// ดึงข้อมูลผู้ใช้ปัจจุบัน
  UserModel? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  /// ตรวจสอบว่าผู้ใช้เป็นพนักงานหรือไม่
  bool get isStaff {
    final user = currentUser;
    return user?.role == 'staff' || user?.role == 'admin';
  }

  /// ตรวจสอบว่าผู้ใช้เป็นแอดมินหรือไม่
  bool get isAdmin {
    final user = currentUser;
    return user?.role == 'admin';
  }
}
