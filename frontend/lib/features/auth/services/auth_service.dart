// lib/features/auth/services/auth_service.dart

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Handles all authentication-related API operations.
///
/// Responsibilities:
/// - Login
/// - Registration
/// - Token management
/// - Future auth expansion

class AuthService {

  /// Sends login request to backend API.
  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {

    return await ApiClient.postRequest(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );
  }

  /// Sends register request to backend API.
  static Future<dynamic> register({
    required String name,
    required String email,
    required String password,
  }) async {

    return await ApiClient.postRequest(
      ApiConstants.register,
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }
}
