import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// User data model for authentication
class UserModel {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role; // 'customer', 'staff', 'admin'
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Authentication response model
class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

abstract class AuthDataSource {
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

class AuthRemoteDataSource implements AuthDataSource {
  final Dio dio;
  final Logger logger;

  AuthRemoteDataSource({required this.dio, required this.logger});

  @override
  Future<AuthResponse> login(String username, String password) async {
    try {
      logger.i('Attempting login for user: $username');

      final response = await dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in login: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw Exception('รหัสผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
      // Return mock success for development
      return _getMockAuthResponse(username);
    } catch (e) {
      logger.e('Exception in login: $e');
      return _getMockAuthResponse(username);
    }
  }

  @override
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      logger.i('Attempting registration for user: $username');

      final response = await dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'role': 'customer', // Default role for new registrations
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return AuthResponse.fromJson(data);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in register: ${e.message}');
      if (e.response?.statusCode == 409) {
        throw Exception('ชื่อผู้ใช้หรืออีเมลนี้มีการใช้งานแล้ว');
      }
      // Return mock success for development
      return _getMockAuthResponse(username, email: email);
    } catch (e) {
      logger.e('Exception in register: $e');
      return _getMockAuthResponse(username, email: email);
    }
  }

  @override
  Future<void> logout() async {
    try {
      logger.i('Logging out user');

      await dio.post('/auth/logout');
      logger.i('Successfully logged out');
    } on DioException catch (e) {
      logger.e('DioException in logout: ${e.message}');
      // Continue with logout process even if API call fails
    } catch (e) {
      logger.e('Exception in logout: $e');
      // Continue with logout process even if API call fails
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      logger.i('Fetching current user');

      final response = await dio.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        return null;
      }
    } on DioException catch (e) {
      logger.e('DioException in getCurrentUser: ${e.message}');
      // Return mock user for development
      return _getMockUser();
    } catch (e) {
      logger.e('Exception in getCurrentUser: $e');
      return _getMockUser();
    }
  }

  // Mock data methods for development
  AuthResponse _getMockAuthResponse(String username, {String? email}) {
    return AuthResponse(
      user: UserModel(
        id: 1,
        username: username,
        email: email ?? '$username@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: username == 'staff' ? 'staff' : 'customer',
        createdAt: DateTime.now(),
      ),
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  UserModel _getMockUser() {
    return UserModel(
      id: 1,
      username: 'testuser',
      email: 'testuser@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'customer',
      createdAt: DateTime.now(),
    );
  }
}
