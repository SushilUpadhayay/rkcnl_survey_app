import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for text-based questions (Open end).
class TextQuestion extends StatelessWidget {
  final Question question;
  final String value;
  final ValueChanged<String> onChanged;

  const TextQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              question.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        TextField(
          maxLines: question.type == QuestionType.OpenEnd ? 5 : 1,
          decoration: InputDecoration(
            hintText: question.placeholder ?? 'Type your answer here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: onChanged,
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            ),
          ),
        ),
      ],
    );
  }
}
