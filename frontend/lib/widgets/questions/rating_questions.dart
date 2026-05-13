import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for rating scale questions.
class RatingQuestion extends StatelessWidget {
  final Question question;
  final double? value;
  final ValueChanged<double> onChanged;

  const RatingQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final max = (question.maxRating ?? 5).toDouble();
    
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
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Text(
                (value ?? 0).toInt().toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: value ?? 0,
                min: 0,
                max: max,
                divisions: max.toInt(),
                label: (value ?? 0).toInt().toString(),
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.1),
                onChanged: onChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Poor', style: TextStyle(fontSize: 12)),
                    Text('Excellent', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
