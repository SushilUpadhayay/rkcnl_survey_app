/// All 10 question types supported by the RKCNL survey system.
/// These values MUST match the backend API (Survey.js / schema.prisma).
enum QuestionType {
  /// Multi-choice, multiple answers allowed (checkbox)
  MultiChoiceMultiSelect,

  /// Multi-choice, only one answer allowed (radio)
  MultiChoiceSingleSelect,

  /// Multi-choice with an "Other (specify)" free-text option
  ChoiceWithAddition,

  /// Multi-choice where respondent can also write a reason/notes
  ChoiceWithFreeWriting,

  /// Pure free-text / open-ended answer
  OpenEnd,

  /// Respondents rank items in order of preference / importance
  Ranking,

  /// Searchable dropdown with potentially hundreds of options
  PickingUp,

  /// Like PickingUp but answers are also ranked
  PickupAndRank,

  /// Star / numeric rating scale (e.g. 1–5)
  RatingScale,

  /// Matrix / grid (rows = items, columns = scale labels)
  Matrix,
}

/// Returns a user-facing display label for a [QuestionType].
extension QuestionTypeLabel on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.MultiChoiceMultiSelect:
        return 'Multi-Select';
      case QuestionType.MultiChoiceSingleSelect:
        return 'Single-Select';
      case QuestionType.ChoiceWithAddition:
        return 'Choice + Add Option';
      case QuestionType.ChoiceWithFreeWriting:
        return 'Choice + Free Writing';
      case QuestionType.OpenEnd:
        return 'Open-Ended Text';
      case QuestionType.Ranking:
        return 'Ranking';
      case QuestionType.PickingUp:
        return 'Searchable Dropdown';
      case QuestionType.PickupAndRank:
        return 'Searchable + Rank';
      case QuestionType.RatingScale:
        return 'Rating Scale';
      case QuestionType.Matrix:
        return 'Matrix / Grid';
    }
  }

  /// Returns `true` for types that show a list of predefined options.
  bool get hasOptions =>
      this == QuestionType.MultiChoiceMultiSelect ||
      this == QuestionType.MultiChoiceSingleSelect ||
      this == QuestionType.ChoiceWithAddition ||
      this == QuestionType.ChoiceWithFreeWriting ||
      this == QuestionType.PickingUp ||
      this == QuestionType.PickupAndRank ||
      this == QuestionType.Ranking;

  /// Returns `true` for types that allow a free-text field.
  bool get hasFreeText =>
      this == QuestionType.OpenEnd ||
      this == QuestionType.ChoiceWithAddition ||
      this == QuestionType.ChoiceWithFreeWriting;

  /// Returns `true` for types that involve ranking.
  bool get isRankBased =>
      this == QuestionType.Ranking || this == QuestionType.PickupAndRank;
}

/// Safely parses a [QuestionType] from a string, defaulting to [QuestionType.OpenEnd].
QuestionType questionTypeFromString(String? raw) {
  if (raw == null) return QuestionType.OpenEnd;
  // Legacy lower-case names used before the backend migration
  const legacyMap = {
    'radio': QuestionType.MultiChoiceSingleSelect,
    'checkbox': QuestionType.MultiChoiceMultiSelect,
    'text': QuestionType.OpenEnd,
    'rating': QuestionType.RatingScale,
    'textarea': QuestionType.OpenEnd,
    'dropdown': QuestionType.PickingUp,
    'scale': QuestionType.RatingScale,
    'ranking': QuestionType.Ranking,
  };
  if (legacyMap.containsKey(raw.toLowerCase())) {
    return legacyMap[raw.toLowerCase()]!;
  }
  try {
    return QuestionType.values.byName(raw);
  } catch (_) {
    return QuestionType.OpenEnd;
  }
}

/// A single survey question.
/// Covers all 10 question types from the RKCNL requirements.
class Question {
  final String id;
  final QuestionType type;
  final String text;
  final String? description;

  /// Predefined answer options (used by choice, ranking, and dropdown types).
  final List<String>? options;

  /// Maximum value for RatingScale (default 5).
  final int? maxRating;

  /// Placeholder hint text (used by OpenEnd / free-text fields).
  final String? placeholder;

  /// Whether the respondent must answer this question.
  final bool isRequired;

  /// Column headers for Matrix questions (e.g. ["Poor", "Fair", "Good", "Excellent"]).
  final List<String>? matrixColumns;

  /// Row labels for Matrix questions (e.g. ["Service", "Feeling"]).
  final List<String>? matrixRows;

  /// Additional properties for specific question types (e.g. matrix rows, rating icons).
  /// This ensures the system is "greater or less than 10" types and easily extendable.
  final Map<String, dynamic> extras;

  const Question({
    required this.id,
    required this.type,
    required this.text,
    this.description,
    this.options,
    this.maxRating,
    this.placeholder,
    this.isRequired = false,
    this.matrixColumns,
    this.matrixRows,
    this.extras = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        if (description != null) 'description': description,
        if (options != null) 'options': options,
        if (maxRating != null) 'maxRating': maxRating,
        if (placeholder != null) 'placeholder': placeholder,
        'isRequired': isRequired,
        if (matrixColumns != null) 'matrixColumns': matrixColumns,
        if (matrixRows != null) 'matrixRows': matrixRows,
        'extras': extras,
      };

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id']?.toString() ?? '',
        type: questionTypeFromString(j['type']?.toString()),
        text: j['text']?.toString() ?? '',
        description: j['description']?.toString(),
        options: j['options'] != null
            ? List<String>.from(
                (j['options'] as List).map((e) => e.toString()))
            : null,
        maxRating: j['maxRating'] as int?,
        placeholder: j['placeholder']?.toString(),
        isRequired: (j['isRequired'] as bool?) ?? false,
        matrixColumns: j['matrixColumns'] != null
            ? List<String>.from(
                (j['matrixColumns'] as List).map((e) => e.toString()))
            : null,
        matrixRows: j['matrixRows'] != null
            ? List<String>.from(
                (j['matrixRows'] as List).map((e) => e.toString()))
            : null,
        extras: Map<String, dynamic>.from(j['extras'] ?? {}),
      );
}

enum SurveyStatus { pending, inProgress, synced }

/// A survey created by admin and assigned to this surveyor
class Survey {
  final String id;
  final String title;
  final String region;
  final String dueDate;
  final String priority; // high, medium, low
  SurveyStatus status;
  final String description;
  final List<Question> questions;
  final String iconName;
  final int colorValue;

  Survey({
    required this.id,
    required this.title,
    required this.region,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.description,
    required this.questions,
    required this.iconName,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'region': region,
        'dueDate': dueDate,
        'priority': priority,
        'status': status.name,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'iconName': iconName,
        'colorValue': colorValue,
      };

  factory Survey.fromJson(Map<String, dynamic> j) {
    // Map status from backend (Active/Draft/Closed) to frontend enum
    SurveyStatus s = SurveyStatus.pending;
    if (j['status'] == 'Active') s = SurveyStatus.inProgress;

    return Survey(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Untitled Survey',
      region: j['region']?.toString() ?? 'Global', // Default if missing
      dueDate: j['dueDate']?.toString() ?? 'No deadline',
      priority: j['priority']?.toString() ?? 'medium',
      status: s,
      description: j['description']?.toString() ?? '',
      questions: j['questions'] != null
          ? List<Question>.from((j['questions'] as List).map((q) => Question.fromJson(q as Map<String, dynamic>)))
          : [],
      iconName: j['iconName']?.toString() ?? 'assignment',
      colorValue: j['colorValue'] is int ? j['colorValue'] : 0xFF1A6B1A,
    );
  }
}

enum RespondentStatus { pending, draft, completed }

/// A single respondent's data collected by the surveyor
class Respondent {
  final String id;
  final String surveyId;
  final String name;
  final String? phone;
  final String? age;
  final String? gender;
  RespondentStatus status;
  Map<String, dynamic> answers;
  final int startedAt;
  int? completedAt;
  bool synced;

  Respondent({
    required this.id,
    required this.surveyId,
    required this.name,
    this.phone,
    this.age,
    this.gender,
    this.status = RespondentStatus.pending,
    Map<String, dynamic>? answers,
    required this.startedAt,
    this.completedAt,
    this.synced = false,
  }) : answers = answers ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'surveyId': surveyId,
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'status': status.name,
        'answers': answers,
        'startedAt': startedAt,
        'completedAt': completedAt,
        'synced': synced,
      };

  factory Respondent.fromJson(Map<String, dynamic> j) => Respondent(
        id: (j['id'] as dynamic).toString(),
        surveyId: (j['surveyId'] as dynamic).toString(),
        name: (j['name'] as dynamic).toString(),
        phone: j['phone']?.toString(),
        age: j['age']?.toString(),
        gender: j['gender']?.toString(),
        status: RespondentStatus.values
            .byName((j['status']?.toString() ?? 'pending')),
        answers: Map<String, dynamic>.from(j['answers'] ?? {}),
        startedAt: (j['startedAt'] as int?) ?? 0,
        completedAt: j['completedAt'] as int?,
        synced: (j['synced'] as bool?) ?? false,
      );

  Respondent copyWith(
      {RespondentStatus? status,
      Map<String, dynamic>? answers,
      int? completedAt,
      bool? synced}) {
    return Respondent(
      id: id,
      surveyId: surveyId,
      name: name,
      phone: phone,
      age: age,
      gender: gender,
      status: status ?? this.status,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String icon;
  final String colorType; // green, orange, blue
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.colorType,
    this.read = false,
  });
}

class SyncHistoryItem {
  final int count;
  final int timestamp;
  SyncHistoryItem({required this.count, required this.timestamp});
  Map<String, dynamic> toJson() => {'count': count, 'timestamp': timestamp};
  factory SyncHistoryItem.fromJson(Map<String, dynamic> j) => SyncHistoryItem(
      count: (j['count'] as int?) ?? 0,
      timestamp: (j['timestamp'] as int?) ?? 0);
}
