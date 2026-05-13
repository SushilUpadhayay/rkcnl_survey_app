import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for dropdown/pickup questions.
class DropdownQuestion extends StatelessWidget {
  final Question question;
  final String? value;
  final ValueChanged<String?> onChanged;

  const DropdownQuestion({
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: (question.options?.contains(value) ?? false) ? value : null,
              hint: Text(question.placeholder ?? 'Select an option'),
              items: (question.options ?? []).map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Searchable selection that then allows ranking of picked items.
class PickupAndRankQuestion extends StatefulWidget {
  final Question question;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const PickupAndRankQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  State<PickupAndRankQuestion> createState() => _PickupAndRankQuestionState();
}

class _PickupAndRankQuestionState extends State<PickupAndRankQuestion> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List<String>.from(widget.value);
  }

  void _addItem(String item) {
    if (!_selectedItems.contains(item)) {
      setState(() {
        _selectedItems.add(item);
      });
      widget.onChanged(_selectedItems);
    }
    _searchController.clear();
  }

  void _removeItem(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
    widget.onChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (textValue) {
            if (textValue.text == '') return const Iterable<String>.empty();
            return (widget.question.options ?? []).where((opt) =>
                !_selectedItems.contains(opt) &&
                opt.toLowerCase().contains(textValue.text.toLowerCase()));
          },
          onSelected: _addItem,
          fieldViewBuilder: (ctx, ctrl, focus, onFieldSubmitted) {
            return TextField(
              controller: ctrl,
              focusNode: focus,
              decoration: InputDecoration(
                hintText: widget.question.placeholder ?? 'Search and add...',
                suffixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (_selectedItems.isNotEmpty)
          const Text('Rank selected items (drag to reorder):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIdx, newIdx) {
            setState(() {
              if (newIdx > oldIdx) newIdx -= 1;
              final item = _selectedItems.removeAt(oldIdx);
              _selectedItems.insert(newIdx, item);
            });
            widget.onChanged(_selectedItems);
          },
          children: _selectedItems
              .map((item) => ListTile(
                    key: ValueKey(item),
                    title: Text(item),
                    leading: const Icon(Icons.drag_handle),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeItem(item),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
