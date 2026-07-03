/// Question types supported by the survey system
enum QuestionType {
  MultiChoiceSingleSelect,
  MultiChoiceMultiSelect,
  ChoiceWithAddition,
  ChoiceWithFreeWriting,
  OpenEnd,
  Ranking,
  PickingUp,
  PickupAndRank,
  RatingScale,
  Matrix,
}

/// A single question within a survey (created by admin)
class Question {
  final String id;
  final QuestionType type;
  final String text;
  final String? description;
  final List<String>? options;
  final List<String>? matrixRows;
  final List<String>? matrixColumns;
  final int? maxRating;
  final String? placeholder;
  final bool isRequired;
  final Map<String, dynamic> extras;

  const Question({
    required this.id,
    required this.type,
    required this.text,
    this.description,
    this.options,
    this.matrixRows,
    this.matrixColumns,
    this.maxRating,
    this.placeholder,
    this.isRequired = false,
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
        id: (j['id'] as dynamic).toString(),
        type: QuestionType.values.byName((j['type']?.toString() ?? 'OpenEnd')),
        text: (j['text'] as dynamic).toString(),
        description: j['description']?.toString(),
        options: j['options'] != null
            ? (j['options'] as List).map((e) => e.toString()).toList()
            : null,
        matrixRows: j['matrixRows'] != null
            ? (j['matrixRows'] as List).map((e) => e.toString()).toList()
            : null,
        matrixColumns: j['matrixColumns'] != null
            ? (j['matrixColumns'] as List).map((e) => e.toString()).toList()
            : null,
        maxRating: (j['maxRating'] as int?) ?? 5,
        placeholder: j['placeholder']?.toString(),
        isRequired: j['isRequired'] as bool? ?? false,
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
  final int targetResponses;

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
    this.targetResponses = 5,
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
        'targetResponses': targetResponses,
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

  final double? latitude;
  final double? longitude;
  final List<String> photos;

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
    this.latitude,
    this.longitude,
    List<String>? photos,
  }) : answers = answers ?? {},
       photos = photos ?? [];

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
        'latitude': latitude,
        'longitude': longitude,
        'photos': photos,
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
        latitude: j['latitude'] as double?,
        longitude: j['longitude'] as double?,
        photos: j['photos'] != null ? List<String>.from((j['photos'] as List).map((e) => e.toString())) : [],
      );

  Respondent copyWith(
      {RespondentStatus? status,
      Map<String, dynamic>? answers,
      int? completedAt,
      bool? synced,
      double? latitude,
      double? longitude,
      List<String>? photos}) {
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: photos ?? this.photos,
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
