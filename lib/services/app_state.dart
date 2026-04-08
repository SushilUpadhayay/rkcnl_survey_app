import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Central app state provider - manages auth, surveys, connectivity, and sync
class AppState extends ChangeNotifier {
  final StorageService storage;

  // ── Auth ──
  bool isLoggedIn = false;
  String userName = 'Field Surveyor';
  String userInitials = 'FS';
  String userRegion = 'Ward 4, Northern Sector';

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
  Future<void> login(String name) async {
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    userName = name;
    userInitials = initials;
    isLoggedIn = true;
    await storage.saveAuth({
      'loggedIn': true,
      'name': name,
      'initials': initials,
      'region': userRegion
    });
    notifyListeners();
  }

  Future<void> logout() async {
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
    // Simulate network upload delay
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now().millisecondsSinceEpoch;
    await storage.addSynced(pending);
    await storage.clearPending();
    await storage.setLastSyncTime(now);
    await storage
        .addSyncHistory(SyncHistoryItem(count: pending.length, timestamp: now));
    // Mark surveys as synced if target reached and all respondents done
    for (final p in pending) {
      final sid = p['surveyId'] as String;
      final respondents = storage.getRespondents(sid);
      final idx = surveys.indexWhere((s) => s.id == sid);
      if (idx >= 0) {
        final completedCount = respondents.where((r) => r.status == RespondentStatus.completed).length;
        if (completedCount >= surveys[idx].targetResponses &&
            respondents.every((r) => r.status == RespondentStatus.completed)) {
          surveys[idx].status = SurveyStatus.synced;
        }
      }
    }
    notifyListeners();
    return true;
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
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.radio,
              text: 'What is the current crop stage?',
              description: 'Select the most accurate phase.',
              options: ['Sowing', 'Vegetative', 'Flowering', 'Harvesting']),
          const Question(
              id: 'q2',
              type: QuestionType.radio,
              text: 'Overall crop health?',
              description: 'Rate the general health of the crops.',
              options: ['Excellent', 'Good', 'Fair', 'Poor', 'Critical']),
          const Question(
              id: 'q3',
              type: QuestionType.checkbox,
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
              type: QuestionType.text,
              text: 'Field Observations',
              description: 'Note pests, soil moisture, weather impacts.',
              placeholder: 'Describe what you observed...'),
          const Question(
              id: 'q5',
              type: QuestionType.rating,
              text: 'Estimated yield potential (1–10)?',
              description: '1 = very low, 10 = excellent yield.',
              maxRating: 10),
          const Question(
              id: 'q6',
              type: QuestionType.radio,
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
              type: QuestionType.text,
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
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.radio,
              text: 'Soil moisture level?',
              description: 'Visual and tactile estimation.',
              options: ['Very Dry', 'Dry', 'Moist', 'Wet', 'Waterlogged']),
          const Question(
              id: 'q2',
              type: QuestionType.radio,
              text: 'Soil texture?',
              description: 'Primary texture of the soil.',
              options: ['Sandy', 'Loamy', 'Clay', 'Silt', 'Rocky']),
          const Question(
              id: 'q3',
              type: QuestionType.checkbox,
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
              type: QuestionType.rating,
              text: 'Soil quality rating (1–10)?',
              description: 'Overall assessment of soil quality.',
              maxRating: 10),
          const Question(
              id: 'q5',
              type: QuestionType.text,
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
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.radio,
              text: 'Irrigation system type?',
              description: 'Primary irrigation method.',
              options: ['Drip', 'Sprinkler', 'Flood', 'Canal', 'None']),
          const Question(
              id: 'q2',
              type: QuestionType.radio,
              text: 'System condition?',
              description: 'Overall condition of the infrastructure.',
              options: ['Excellent', 'Good', 'Needs repair', 'Broken']),
          const Question(
              id: 'q3',
              type: QuestionType.checkbox,
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
              type: QuestionType.text,
              text: 'Maintenance notes:',
              description: 'Describe needed repairs.',
              placeholder: 'Describe issues in detail...'),
        ],
      ),
      Survey(
        id: 'SRV-004',
        title: 'Livestock & Fodder Assessment – Ward 6',
        region: 'Western Zone',
        dueDate: 'Mar 20, 2026',
        priority: 'high',
        status: SurveyStatus.pending,
        description:
            'Survey livestock count, fodder availability and animal health in Ward 6.',
        iconName: 'pets',
        colorValue: 0xFF4E342E,
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.radio,
              text: 'Primary livestock species?',
              description: 'Main animals being kept.',
              options: ['Cattle', 'Goats', 'Poultry', 'Pigs', 'Mixed']),
          const Question(
              id: 'q2',
              type: QuestionType.rating,
              text: 'Animal health rating (1–10)?',
              description: 'General condition and vitality.',
              maxRating: 10),
          const Question(
              id: 'q3',
              type: QuestionType.radio,
              text: 'Fodder availability?',
              description: 'Current availability of animal feed.',
              options: ['Abundant', 'Adequate', 'Scarce', 'Critical shortage']),
          const Question(
              id: 'q4',
              type: QuestionType.checkbox,
              text: 'Issues observed:',
              description: 'Select all concerns noted.',
              options: [
                'Disease signs',
                'Malnutrition',
                'Water shortage',
                'Overcrowding',
                'None'
              ]),
          const Question(
              id: 'q5',
              type: QuestionType.text,
              text: 'Additional notes:',
              description: 'Other observations.',
              placeholder: 'Enter notes here...'),
        ],
      ),
      Survey(
        id: 'SRV-005',
        title: 'Post-harvest Loss Assessment',
        region: 'All Sectors',
        dueDate: 'Mar 25, 2026',
        priority: 'medium',
        status: SurveyStatus.pending,
        description:
            'Estimate and document post-harvest losses for major crops.',
        iconName: 'warehouse',
        colorValue: 0xFF6A1B9A,
        questions: [
          const Question(
              id: 'q1',
              type: QuestionType.radio,
              text: 'Primary crop assessed?',
              description: 'Main crop being evaluated.',
              options: [
                'Rice',
                'Wheat',
                'Maize',
                'Vegetables',
                'Fruits',
                'Other'
              ]),
          const Question(
              id: 'q2',
              type: QuestionType.rating,
              text: 'Estimated harvest loss level (1–10)?',
              description: '1 = very low, 10 = severe loss.',
              maxRating: 10),
          const Question(
              id: 'q3',
              type: QuestionType.checkbox,
              text: 'Causes of post-harvest loss:',
              description: 'Select all relevant causes.',
              options: [
                'Pest damage',
                'Moisture/mold',
                'Poor storage',
                'Transport damage',
                'Market delay',
                'None'
              ]),
          const Question(
              id: 'q4',
              type: QuestionType.radio,
              text: 'Storage facility used?',
              description: 'Where is the produce stored?',
              options: [
                'Home storage',
                'Community warehouse',
                'Cooperative store',
                'Cold storage',
                'None – sold immediately'
              ]),
          const Question(
              id: 'q5',
              type: QuestionType.text,
              text: 'Recommendations:',
              description: 'Suggest improvements.',
              placeholder: 'e.g. Better storage containers, cold chain...'),
        ],
      ),
    ];
