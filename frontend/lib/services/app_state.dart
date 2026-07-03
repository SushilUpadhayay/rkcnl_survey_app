import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Central app state provider - manages auth, surveys, connectivity, and sync.
/// This application is exclusively used by FieldStaff surveyors.
class AppState extends ChangeNotifier {
  final StorageService storage;
  final AuthService _authService = AuthService();

  // ── Auth ──
  bool isLoggedIn = false;
  String userName = 'Field Surveyor';
  String userInitials = 'FS';
  String userRegion = 'Ward 4, Northern Sector';
  String? errorMessage;
  bool isAuthenticating = false;

  // ── Connectivity ──
  bool isOnline = true;

  // ── Settings ──
  bool darkMode = false;
  bool autoSync = true;

  // ── Surveys (fetched from backend on login/startup) ──
  List<Survey> surveys = [];
  bool isLoading = false;
  String? error;

  // ── Notifications ──
  final List<AppNotification> notifications = [
    AppNotification(
        id: '1',
        title: 'New Survey Assigned',
        message: 'Crop Health Assessment – Ward 6 has been assigned to you.',
        time: '2 hrs ago',
        icon: 'assignment',
        colorType: 'green'),
    AppNotification(
        id: '2',
        title: 'Sync Reminder',
        message: 'You have responses pending upload. Please sync when online.',
        time: '5 hrs ago',
        icon: 'cloud_sync',
        colorType: 'orange'),
    AppNotification(
        id: '3',
        title: 'Deadline Alert',
        message:
            'Soil Moisture Survey due date is tomorrow. Please submit soon.',
        time: '1 day ago',
        icon: 'alarm',
        colorType: 'orange',
        read: true),
    AppNotification(
        id: '4',
        title: 'Account Update',
        message: 'Your profile has been updated. Region changed to Ward 4.',
        time: '2 days ago',
        icon: 'manage_accounts',
        colorType: 'blue',
        read: true),
  ];

  AppState(this.storage) {
    _loadSettings();
    _listenConnectivity();
    fetchSurveys();
  }

  /// Fetches surveys assigned to this FieldStaff user from the backend API.
  Future<void> fetchSurveys() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null) {
        surveys = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final baseUrl = AuthService.baseUrl.replaceAll('/api/auth', '');
      final response = await http.get(
        Uri.parse('$baseUrl/api/surveys/assigned'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        surveys = data.isNotEmpty
            ? data.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList()
            : [];
      } else {
        debugPrint('Failed to fetch surveys: ${response.statusCode}');
        surveys = [];
      }
    } catch (e) {
      debugPrint('Error fetching surveys: $e');
      surveys = [];
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _loadSettings() {
    darkMode = storage.getDarkMode();
    autoSync = storage.getAutoSync();
    final auth = storage.getAuth();
    if (auth != null && auth['loggedIn'] == true) {
      isLoggedIn = true;
      userName = auth['name'] ?? 'Surveyor';
      userInitials = auth['initials'] ?? 'SV';
      userRegion = auth['region'] ?? 'Ward 4';
    }
  }

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = !isOnline;
      isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
      if (wasOffline && isOnline && autoSync) _triggerAutoSync();
    });
    Connectivity().checkConnectivity().then((results) {
      isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
    });
  }

  // ── AUTH ──
  Future<bool> login(String email, String password) async {
    isAuthenticating = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    isAuthenticating = false;
    if (result['success']) {
      final user = result['user'];
      isLoggedIn = true;
      userName = user['username'] ?? 'Surveyor';
      userInitials = userName.length >= 2
          ? userName.substring(0, 2).toUpperCase()
          : userName.toUpperCase();

      await storage.saveAuth({
        'loggedIn': true,
        'name': userName,
        'initials': userInitials,
        'region': userRegion,
      });
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String gender,
    required String dateOfBirth,
    required String location,
    required String email,
    required String phone,
    required String password,
  }) async {
    isAuthenticating = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      fullName: fullName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      location: location,
      email: email,
      phone: phone,
      password: password,
    );

    isAuthenticating = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn = false;
    surveys = [];
    await storage.clearAuth();
    notifyListeners();
  }

  // ── THEME ──
  Future<void> setDarkMode(bool val) async {
    darkMode = val;
    await storage.setDarkMode(val);
    notifyListeners();
  }

  Future<void> setAutoSync(bool val) async {
    autoSync = val;
    await storage.setAutoSync(val);
    notifyListeners();
  }

  // ── RESPONDENTS ──
  List<Respondent> getRespondents(String surveyId) =>
      storage.getRespondents(surveyId);

  Future<Respondent> addRespondent(String surveyId,
      {required String name,
      String? phone,
      String? age,
      String? gender}) async {
    final r = Respondent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surveyId: surveyId,
      name: name,
      phone: phone,
      age: age,
      gender: gender,
      startedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await storage.saveRespondent(surveyId, r);
    _markSurveyInProgress(surveyId);
    notifyListeners();
    return r;
  }

  Future<void> saveRespondentDraft(
      String surveyId, Respondent r, Map<String, dynamic> answers,
      {double? latitude, double? longitude, List<String>? photos}) async {
    final updated = r.copyWith(
        status: RespondentStatus.draft,
        answers: answers,
        latitude: latitude,
        longitude: longitude,
        photos: photos);
    await storage.saveRespondent(surveyId, updated);
    _markSurveyInProgress(surveyId);
    notifyListeners();
  }

  Future<void> submitRespondent(
      String surveyId, Respondent r, Map<String, dynamic> answers,
      {double? latitude, double? longitude, List<String>? photos}) async {
    final updated = r.copyWith(
      status: RespondentStatus.completed,
      answers: answers,
      completedAt: DateTime.now().millisecondsSinceEpoch,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
    );
    await storage.saveRespondent(surveyId, updated);
    final survey = surveys.firstWhere((s) => s.id == surveyId);
    await storage.addPending({
      'id': r.id,
      'surveyId': surveyId,
      'surveyTitle': survey.title,
      'respondent': r.name,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    });
    if (isOnline && autoSync) {
      Future.delayed(const Duration(seconds: 2), _triggerAutoSync);
    }
    notifyListeners();
  }

  void _markSurveyInProgress(String surveyId) {
    final idx = surveys.indexWhere((s) => s.id == surveyId);
    if (idx >= 0 && surveys[idx].status == SurveyStatus.pending) {
      surveys[idx].status = SurveyStatus.inProgress;
    }
  }

  // ── SYNC ──
  int get pendingCount => storage.getPending().length;
  List<Map<String, dynamic>> get pendingItems => storage.getPending();
  List<SyncHistoryItem> get syncHistory => storage.getSyncHistory();
  int? get lastSyncTime => storage.getLastSyncTime();

  Future<bool> syncAll() async {
    if (!isOnline) return false;
    final pending = storage.getPending();
    if (pending.isEmpty) return true;
    
    try {
      final token = await _authService.getToken();

      List<Map<String, dynamic>> payload = [];
      for (final p in pending) {
        final sid = p['surveyId'] as String;
        final rid = p['id'] as String;

        final respondents = storage.getRespondents(sid);
        final idx = respondents.indexWhere((r) => r.id == rid);
        if (idx == -1) continue;

        final r = respondents[idx];

        final answersList = r.answers.entries.map((e) => {
              'questionId': e.key,
              'answer': e.value,
            }).toList();

        // Convert local photo file paths to Base64 strings for upload
        List<String> base64Photos = [];
        for (String photoPath in r.photos) {
          try {
            final file = File(photoPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              base64Photos.add(base64Encode(bytes));
            }
          } catch (e) {
            debugPrint('Failed to read photo: $e');
          }
        }

        payload.add({
          'surveyId': sid,
          'deviceTimestamp': DateTime.fromMillisecondsSinceEpoch(
                  r.completedAt ?? DateTime.now().millisecondsSinceEpoch)
              .toIso8601String(),
          'answers': answersList,
          'customQuestions': [],
          'personalNotes': '',
          'latitude': r.latitude,
          'longitude': r.longitude,
          'photos': base64Photos,
        });
      }

      if (payload.isEmpty) return true;

      final baseUrl = AuthService.baseUrl.replaceAll('/api/auth', '');
      final url = Uri.parse('$baseUrl/api/responses/sync');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'responses': payload}),
      );

      if (response.statusCode == 200 || response.statusCode == 207) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await storage.addSynced(pending);
        await storage.clearPending();
        await storage.setLastSyncTime(now);
        await storage.addSyncHistory(
            SyncHistoryItem(count: pending.length, timestamp: now));

        for (final p in pending) {
          final sid = p['surveyId'] as String;
          final respondents = storage.getRespondents(sid);
          final idx = surveys.indexWhere((s) => s.id == sid);
          if (idx >= 0 &&
              respondents.every((r) => r.status == RespondentStatus.completed)) {
            surveys[idx].status = SurveyStatus.synced;
          }
        }
        notifyListeners();
        return true;
      } else {
        debugPrint('Sync failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Sync exception: $e');
      return false;
    }
  }

  void _triggerAutoSync() {
    if (isOnline && autoSync && pendingCount > 0) {
      syncAll();
    }
  }

  // ── DATA EXPORT ──
  /// Generates a CSV of all locally stored respondents and shares it
  /// via the system share dialog. Fully client-side — no network required.
  Future<bool> exportSyncedData() async {
    try {
      // Build CSV rows
      final List<List<dynamic>> rows = [
        // Header
        [
          'Survey',
          'Respondent Name',
          'Phone',
          'Gender',
          'Age',
          'Status',
          'GPS Latitude',
          'GPS Longitude',
          'Completed At',
          'Answers',
        ]
      ];

      for (final survey in surveys) {
        final respondents = storage.getRespondents(survey.id);
        for (final r in respondents) {
          final completedAt = r.completedAt != null
              ? DateTime.fromMillisecondsSinceEpoch(r.completedAt!)
                  .toIso8601String()
              : '';
          final answersStr = r.answers.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(' | ');

          rows.add([
            survey.title,
            r.name,
            r.phone ?? '',
            r.gender ?? '',
            r.age ?? '',
            r.status.name,
            r.latitude?.toString() ?? '',
            r.longitude?.toString() ?? '',
            completedAt,
            answersStr,
          ]);
        }
      }

      if (rows.length <= 1) return false; // Only header, no data

      final csvString = const ListToCsvConverter().convert(rows);
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/rkcnl_export_$timestamp.csv');
      await file.writeAsString(csvString);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'RKCNL Survey Export',
        text: 'Survey respondent data exported from RKCNL Field App.',
      );

      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  // ── NOTIFICATIONS ──
  int get unreadCount => notifications.where((n) => !n.read).length;

  void markRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id);
    n.read = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  // ── LOCAL ANALYTICS (client-side computed from SharedPreferences) ──
  int get totalResponses =>
      surveys.fold(0, (s, sv) => s + getRespondents(sv.id).length);

  int get completedResponses => surveys.fold(
      0,
      (s, sv) =>
          s +
          getRespondents(sv.id)
              .where((r) => r.status == RespondentStatus.completed)
              .length);

  int get syncedCount => storage.getSynced().length;

  Map<String, int> getSurveyStatusData() {
    final Map<String, int> data = {
      'Pending': surveys.where((s) => s.status == SurveyStatus.pending).length,
      'In Progress':
          surveys.where((s) => s.status == SurveyStatus.inProgress).length,
      'Synced': surveys.where((s) => s.status == SurveyStatus.synced).length,
    };
    return data;
  }

  List<Map<String, dynamic>> getWeeklyTrendData() {
    final List<Map<String, dynamic>> trend = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = surveys.fold(
          0,
          (s, sv) =>
              s +
              getRespondents(sv.id).where((r) {
                if (r.status != RespondentStatus.completed ||
                    r.completedAt == null) {
                  return false;
                }
                final d = DateTime.fromMillisecondsSinceEpoch(r.completedAt!);
                return d.day == date.day &&
                    d.month == date.month &&
                    d.year == date.year;
              }).length);
      trend.add({
        'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
        'count': count,
      });
    }
    return trend;
  }

  int get todayCompleted {
    final today = DateTime.now();
    return surveys.fold(
        0,
        (s, sv) =>
            s +
            getRespondents(sv.id).where((r) {
              if (r.status != RespondentStatus.completed ||
                  r.completedAt == null) return false;
              final d = DateTime.fromMillisecondsSinceEpoch(r.completedAt!);
              return d.day == today.day &&
                  d.month == today.month &&
                  d.year == today.year;
            }).length);
  }
}
