import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Central app state provider - manages auth, surveys, connectivity, and sync
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

  // ── Surveys (admin-created, loaded at startup) ──
  final List<Survey> surveys = _buildAdminSurveys();

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
        message:
            'Your profile has been updated by admin. Region changed to Ward 4.',
        time: '2 days ago',
        icon: 'manage_accounts',
        colorType: 'blue',
        read: true),
  ];

  AppState(this.storage) {
    _loadSettings();
    _listenConnectivity();
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
      userName = user['username'] ?? 'User';
      userInitials = userName.length >= 2 ? userName.substring(0, 2).toUpperCase() : userName.toUpperCase();
      
      await storage.saveAuth({
        'loggedIn': true,
        'name': userName,
        'initials': userInitials,
        'region': userRegion
      });
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    isLoggedIn = false;
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
      String surveyId, Respondent r, Map<String, dynamic> answers) async {
    final updated =
        r.copyWith(status: RespondentStatus.draft, answers: answers);
    await storage.saveRespondent(surveyId, updated);
    _markSurveyInProgress(surveyId);
    notifyListeners();
  }

  Future<void> submitRespondent(
      String surveyId, Respondent r, Map<String, dynamic> answers) async {
    final updated = r.copyWith(
      status: RespondentStatus.completed,
      answers: answers,
      completedAt: DateTime.now().millisecondsSinceEpoch,
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

    final token = await _authService.getToken();
    if (token == null) return false;

    // Collect full respondent data for all pending items
    final List<Map<String, dynamic>> responsesToSync = [];
    for (final item in pending) {
      final surveyId = item['surveyId'] as String;
      final respondentId = item['id'] as String;
      
      final respondents = storage.getRespondents(surveyId);
      final r = respondents.firstWhere((r) => r.id == respondentId);
      
      // Transform Map<String, dynamic> answers to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> answersList = [];
      r.answers.forEach((qId, val) {
        answersList.add({
          'questionId': qId,
          'value': val,
        });
      });

      // Map to backend schema (Response controller expectations)
      responsesToSync.add({
        'surveyId': surveyId,
        'deviceTimestamp': DateTime.fromMillisecondsSinceEpoch(r.completedAt ?? DateTime.now().millisecondsSinceEpoch).toIso8601String(),
        'answers': answersList,
        'customQuestions': [], // Placeholder for future use
        'personalNotes': 'Respondent: ${r.name}, Age: ${r.age}, Gender: ${r.gender}, Phone: ${r.phone}',
      });
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/responses/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'responses': responsesToSync}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await storage.addSynced(pending);
        await storage.clearPending();
        await storage.setLastSyncTime(now);
        await storage.addSyncHistory(SyncHistoryItem(count: pending.length, timestamp: now));
        
        _updateSurveyStatuses(pending);
        
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Sync failed: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Connection error during sync: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateSurveyStatuses(List<Map<String, dynamic>> syncedItems) {
    final sids = syncedItems.map((e) => e['surveyId'] as String).toSet();
    for (final sid in sids) {
      final respondents = storage.getRespondents(sid);
      final idx = surveys.indexWhere((s) => s.id == sid);
      if (idx >= 0) {
        final completedCount = respondents.where((r) => r.status == RespondentStatus.completed).length;
        if (completedCount >= surveys[idx].targetResponses) {
          surveys[idx].status = SurveyStatus.synced;
        }
      }
    }
  }

  void _triggerAutoSync() {
    if (isOnline && autoSync && pendingCount > 0) {
      syncAll();
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

  // ── ANALYTICS ──
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
                  r.completedAt == null) {
                return false;
              }
              final d = DateTime.fromMillisecondsSinceEpoch(r.completedAt!);
              return d.day == today.day &&
                  d.month == today.month &&
                  d.year == today.year;
            }).length);
  }
}

// ── ADMIN-CREATED SURVEYS (simulated) ──
List<Survey> _buildAdminSurveys() => [
      Survey(
        id: 'SRV-001',
        title: 'Crop Health Assessment – Ward 4',
        region: 'Northern Sector',
        dueDate: 'Mar 10, 2026',
        priority: 'high',
        status: SurveyStatus.inProgress,
        description:
            'Evaluate crop health conditions across assigned plots in Ward 4.',
        iconName: 'eco',
        colorValue: 0xFF1A6B1A,
        targetResponses: 10,
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'What is the current crop stage?',
              description: 'Select the most accurate phase.',
              options: ['Sowing', 'Vegetative', 'Flowering', 'Harvesting']),
          const Question(
              id: 'q2',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'Overall crop health?',
              description: 'Rate the general health of the crops.',
              options: ['Excellent', 'Good', 'Fair', 'Poor', 'Critical']),
          const Question(
              id: 'q3',
              type: QuestionType.MultiChoiceMultiSelect,
              text: 'Issues observed (select all):',
              description: 'Mark all problems currently visible.',
              options: [
                'Pest infestation',
                'Disease signs',
                'Nutrient deficiency',
                'Water stress',
                'Weed overgrowth',
                'None'
              ]),
          const Question(
              id: 'q4',
              type: QuestionType.OpenEnd,
              text: 'Field Observations',
              description: 'Note pests, soil moisture, weather impacts.',
              placeholder: 'Describe what you observed...'),
          const Question(
              id: 'q5',
              type: QuestionType.RatingScale,
              text: 'Estimated yield potential (1–10)?',
              description: '1 = very low, 10 = excellent yield.',
              maxRating: 10),
          const Question(
              id: 'q6',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'Irrigation status?',
              description: 'Current irrigation situation.',
              options: [
                'Adequate',
                'Insufficient',
                'Over-irrigated',
                'Rain-fed only'
              ]),
          const Question(
              id: 'q7',
              type: QuestionType.OpenEnd,
              text: 'Recommended action?',
              description: 'Suggest next steps or interventions.',
              placeholder: 'e.g. Apply fertilizer, drain field...'),
        ],
      ),
      Survey(
        id: 'SRV-002',
        title: 'Soil Moisture Survey – East Plains',
        region: 'Eastern Plains',
        dueDate: 'Mar 15, 2026',
        priority: 'medium',
        status: SurveyStatus.pending,
        description:
            'Measure and document soil moisture levels across Eastern Plains.',
        iconName: 'water_drop',
        colorValue: 0xFF0D47A1,
        targetResponses: 8,
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'Soil moisture level?',
              description: 'Visual and tactile estimation.',
              options: ['Very Dry', 'Dry', 'Moist', 'Wet', 'Waterlogged']),
          const Question(
              id: 'q2',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'Soil texture?',
              description: 'Primary texture of the soil.',
              options: ['Sandy', 'Loamy', 'Clay', 'Silt', 'Rocky']),
          const Question(
              id: 'q3',
              type: QuestionType.MultiChoiceMultiSelect,
              text: 'Observed soil issues:',
              description: 'Select all issues currently visible.',
              options: [
                'Erosion',
                'Compaction',
                'Salinization',
                'Drainage problem',
                'None'
              ]),
          const Question(
              id: 'q4',
              type: QuestionType.RatingScale,
              text: 'Soil quality rating (1–10)?',
              description: 'Overall assessment of soil quality.',
              maxRating: 10),
          const Question(
              id: 'q5',
              type: QuestionType.OpenEnd,
              text: 'Additional notes:',
              description: 'Any other observations.',
              placeholder: 'Enter details here...'),
        ],
      ),
      Survey(
        id: 'SRV-003',
        title: 'Irrigation Audit – Zone B',
        region: 'Central Hub',
        dueDate: 'Feb 28, 2026',
        priority: 'low',
        status: SurveyStatus.synced,
        description:
            'Verify irrigation infrastructure and water distribution in Zone B.',
        iconName: 'water',
        colorValue: 0xFF2E7D32,
        targetResponses: 5,
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'Irrigation system type?',
              description: 'Primary irrigation method.',
              options: ['Drip', 'Sprinkler', 'Flood', 'Canal', 'None']),
          const Question(
              id: 'q2',
              type: QuestionType.MultiChoiceSingleSelect,
              text: 'System condition?',
              description: 'Overall condition of the infrastructure.',
              options: ['Excellent', 'Good', 'Needs repair', 'Broken']),
          const Question(
              id: 'q3',
              type: QuestionType.MultiChoiceMultiSelect,
              text: 'Issues with irrigation:',
              description: 'Select all issues observed.',
              options: [
                'Leaking pipes',
                'Clogged nozzles',
                'Uneven distribution',
                'Low pressure',
                'None'
              ]),
          const Question(
              id: 'q4',
              type: QuestionType.OpenEnd,
              text: 'Maintenance notes:',
              description: 'Describe needed repairs.',
              placeholder: 'Describe issues in detail...'),
        ],
      ),
    ];
