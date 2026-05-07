// lib/core/constants/api_constants.dart

// Base API configuration for the entire application.
// Change this only when backend URL changes.

class ApiConstants {

  // Android emulator localhost mapping
  // Use 'http://10.0.2.2:3000/v1' for Android Emulator
  // Use 'http://localhost:3000/v1' for iOS Simulator or Web
  static const String baseUrl = 'http://10.0.2.2:3000/v1';

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Survey endpoints
  static const String surveys = '/surveys';
}
