// lib/features/survey/services/survey_service.dart

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

/// Handles survey-related API operations.
///
/// This service isolates survey business logic
/// from UI components.

class SurveyService {

  /// Fetch all available surveys.
  static Future<dynamic> getSurveys() async {

    return await ApiClient.getRequest(
      ApiConstants.surveys,
    );
  }
}
