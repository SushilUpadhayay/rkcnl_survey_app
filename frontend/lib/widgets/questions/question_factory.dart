import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'choice_questions.dart';
import 'text_questions.dart';
import 'rating_questions.dart';
import 'ranking_questions.dart';
import 'matrix_questions.dart';
import 'dropdown_questions.dart';

/// Central factory for dynamic question rendering.
/// To add a new question type:
/// 1. Create a new widget in lib/widgets/questions/
/// 2. Add a case to the switch statement below.
class QuestionFactory {
  static Widget build({
    required Question question,
    required dynamic value,
    required Function(dynamic) onChanged,
  }) {
    switch (question.type) {
      case QuestionType.MultiChoiceSingleSelect:
        return SingleChoiceQuestion(
          question: question,
          value: value as String?,
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.MultiChoiceMultiSelect:
        return MultiChoiceQuestion(
          question: question,
          value: (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.OpenEnd:
        return TextQuestion(
          question: question,
          value: value?.toString() ?? '',
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.RatingScale:
        return RatingQuestion(
          question: question,
          value: (value is num) ? value.toDouble() : 0.0,
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.Ranking:
        return RankingQuestion(
          question: question,
          value: (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.Matrix:
        return MatrixQuestion(
          question: question,
          value: (value as Map<dynamic, dynamic>?)?.map((k, v) => MapEntry(k.toString(), v.toString())),
          onChanged: (val) => onChanged(val),
        );

      case QuestionType.PickingUp:
        return DropdownQuestion(
          question: question,
          value: value?.toString(),
          onChanged: (val) => onChanged(val),
        );
      
      case QuestionType.ChoiceWithAddition:
        return ChoiceWithAdditionQuestion(
          question: question,
          value: value,
          onChanged: (val) => onChanged(val),
        );
      
      case QuestionType.ChoiceWithFreeWriting:
        return ChoiceWithFreeWritingQuestion(
          question: question,
          value: value,
          onChanged: (val) => onChanged(val),
        );
      
      case QuestionType.PickupAndRank:
        return PickupAndRankQuestion(
          question: question,
          value: (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          onChanged: (val) => onChanged(val),
        );

      // Add more types here...
      default:
        return _buildFallback(question);
    }
  }

  static Widget _buildFallback(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(height: 8),
          Text(
            'Question type "${question.type.name}" is not yet implemented or supported.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('The system is designed to be easily extendable.'),
        ],
      ),
    );
  }
}
