import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'validation_logic.dart';

/// Manages the state and validation for a single survey question.
class QuestionController extends ChangeNotifier {
  final Question question;
  dynamic _value;
  String? _error;
  bool _isVisible = true;

  QuestionController(this.question, {dynamic initialValue}) : _value = initialValue;

  dynamic get value => _value;
  String? get error => _error;
  bool get isVisible => _isVisible;

  set value(dynamic newValue) {
    _value = newValue;
    _error = null; // Clear error on change
    notifyListeners();
  }

  void setVisible(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      notifyListeners();
    }
  }

  /// Runs all validation rules for this question.
  bool validate() {
    if (!_isVisible) return true;

    final rules = _buildRules();
    for (final rule in rules) {
      final result = rule.validate(_value);
      if (!result.isValid) {
        _error = result.message;
        notifyListeners();
        return false;
      }
    }
    _error = null;
    notifyListeners();
    return true;
  }

  List<ValidationRule> _buildRules() {
    final rules = <ValidationRule>[];
    if (question.isRequired) {
      rules.add(RequiredRule());
    }
    
    // Type-specific rules
    switch (question.type) {
      case QuestionType.Ranking:
      case QuestionType.PickupAndRank:
        if (question.options != null) {
          rules.add(RankingCompleteRule(question.options!.length));
        }
        break;
      case QuestionType.Matrix:
        if (question.matrixRows != null) {
          rules.add(MatrixCompleteRule(question.matrixRows!.length));
        }
        break;
      default:
        break;
    }
    return rules;
  }
}

/// Orchestrates multiple [QuestionController]s for a full survey.
class SurveyController extends ChangeNotifier {
  final Survey survey;
  final List<QuestionController> questions;
  int _currentIndex = 0;

  SurveyController({required this.survey, Map<String, dynamic>? initialAnswers})
      : questions = survey.questions.map((q) {
          return QuestionController(q, initialValue: initialAnswers?[q.id]);
        }).toList();

  int get currentIndex => _currentIndex;
  bool get isFirst => _currentIndex == 0;
  bool get isLast => _currentIndex == questions.length - 1;
  bool get isReview => _currentIndex == questions.length;

  QuestionController get currentQuestion => questions[_currentIndex];

  void next() {
    if (currentQuestion.validate()) {
      if (_currentIndex <= questions.length) {
        _currentIndex++;
        notifyListeners();
      }
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void jumpTo(int index) {
    if (index >= 0 && index <= questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  bool validateAll() {
    bool allValid = true;
    for (var q in questions) {
      if (!q.validate()) allValid = false;
    }
    return allValid;
  }

  Map<String, dynamic> getAllAnswers() {
    final Map<String, dynamic> answers = {};
    for (var q in questions) {
      answers[q.question.id] = AnswerParser.serialize(q.question.type, q.value);
    }
    return answers;
  }
}

/// Centralized utility for normalizing and serializing survey answers.
class AnswerParser {
  /// Normalizes raw UI state into a clean serializable format.
  static dynamic serialize(QuestionType type, dynamic value) {
    if (value == null) return null;

    switch (type) {
      case QuestionType.MultiChoiceMultiSelect:
      case QuestionType.Ranking:
      case QuestionType.PickupAndRank:
        // Ensure it's a list
        return value is List ? value : [value.toString()];
      
      case QuestionType.Matrix:
        // Ensure it's a Map<String, dynamic>
        return value is Map ? value : {};

      case QuestionType.RatingScale:
        return value is num ? value : int.tryParse(value.toString()) ?? 0;

      default:
        return value.toString();
    }
  }

  /// Formats an answer for display in the review screen.
  static String formatForDisplay(QuestionType type, dynamic value) {
    if (value == null) return 'No answer';
    
    if (value is List) {
      if (value.isEmpty) return 'No selection';
      return value.join(', ');
    }
    
    if (value is Map) {
      if (value.isEmpty) return 'Incomplete';
      return value.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }

    return value.toString();
  }
}
