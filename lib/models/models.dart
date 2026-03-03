/// Question types supported by the survey system
enum QuestionType { radio, checkbox, text, rating }

/// A single question within a survey (created by admin)
class Question {
  final String id;
  final QuestionType type;
  final String text;
  final String? description;
  final List<String>? options;
  final int? maxRating;
  final String? placeholder;

  const Question({
    required this.id,
    required this.type,
    required this.text,
    this.description,
    this.options,
    this.maxRating,
    this.placeholder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'text': text,
        'description': description,
        'options': options,
        'maxRating': maxRating,
        'placeholder': placeholder,
      };

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: (j['id'] as dynamic).toString(),
        type: QuestionType.values.byName((j['type']?.toString() ?? 'text')),
        text: (j['text'] as dynamic).toString(),
        description:
            j['description'] != null ? j['description'].toString() : null,
        options: j['options'] != null
            ? (j['options'] as List).map((e) => e.toString()).toList()
            : null,
        maxRating: (j['maxRating'] as int?) ?? 5,
        placeholder:
            j['placeholder'] != null ? j['placeholder'].toString() : null,
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
        phone: j['phone'] != null ? j['phone'].toString() : null,
        age: j['age'] != null ? j['age'].toString() : null,
        gender: j['gender'] != null ? j['gender'].toString() : null,
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
