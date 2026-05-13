import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for ranking questions (Reorderable List).
class RankingQuestion extends StatelessWidget {
  final Question question;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const RankingQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // If value is empty, initialize with options
    final List<String> items = value.isEmpty ? (question.options ?? []) : value;

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
        const Text(
          'Drag and drop to rank your preferences:',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              final List<String> newList = List<String>.from(items);
              if (newIndex > oldIndex) newIndex -= 1;
              final String item = newList.removeAt(oldIndex);
              newList.insert(newIndex, item);
              onChanged(newList);
            },
            children: [
              for (int i = 0; i < items.length; i++)
                ListTile(
                  key: ValueKey(items[i]),
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(items[i]),
                  trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
