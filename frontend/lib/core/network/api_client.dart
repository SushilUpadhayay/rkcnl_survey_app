// lib/core/network/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Centralized API client.
///
/// Responsibilities:
/// - Sending HTTP requests
/// - Managing headers
/// - Handling authentication tokens
/// - Returning parsed responses
///
/// Keeping all network logic here prevents
/// duplicated code across the application.

class ApiClient {

  /// Generic GET request method.
  static Future<dynamic> getRequest(String endpoint) async {

    final Uri url = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    );

    // TODO: Add token to headers if needed
    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Generic POST request method.
  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {

    final Uri url = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }
}
