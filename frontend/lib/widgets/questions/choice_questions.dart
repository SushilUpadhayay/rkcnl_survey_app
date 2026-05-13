import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for single-choice questions (Radio buttons).
class SingleChoiceQuestion extends StatelessWidget {
  final Question question;
  final String? value;
  final ValueChanged<String?> onChanged;

  const SingleChoiceQuestion({
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
        ...(question.options ?? []).map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: value == option
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: value == option
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : null,
            ),
            child: RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: value,
              onChanged: onChanged,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }),
      ],
    );
  }
}

/// A modular widget for multiple-choice questions (Checkboxes).
class MultiChoiceQuestion extends StatelessWidget {
  final Question question;
  final List<String> value;
  final ValueChanged<List<String>> onChanged;

  const MultiChoiceQuestion({
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
        ...(question.options ?? []).map((option) {
          final isSelected = value.contains(option);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : null,
            ),
            child: CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (bool? checked) {
                final newValue = List<String>.from(value);
                if (checked == true) {
                  newValue.add(option);
                } else {
                  newValue.remove(option);
                }
                onChanged(newValue);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }),
      ],
    );
  }
}

/// Choice with an "Other" option that reveals a text input.
class ChoiceWithAdditionQuestion extends StatefulWidget {
  final Question question;
  final dynamic value; // Can be String or Map
  final ValueChanged<dynamic> onChanged;

  const ChoiceWithAdditionQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ChoiceWithAdditionQuestion> createState() => _ChoiceWithAdditionQuestionState();
}

class _ChoiceWithAdditionQuestionState extends State<ChoiceWithAdditionQuestion> {
  late TextEditingController _controller;
  String? _selectedOption;
  bool _isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    final val = widget.value;
    if (val is String) {
      if (widget.question.options?.contains(val) ?? false) {
        _selectedOption = val;
      } else {
        _selectedOption = 'Other';
        _isOtherSelected = true;
        _controller = TextEditingController(text: val);
      }
    }
    if (_selectedOption == null) {
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String? val) {
    setState(() {
      _selectedOption = val;
      _isOtherSelected = val == 'Other';
    });
    if (!_isOtherSelected) {
      widget.onChanged(val);
    } else {
      widget.onChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [...(widget.question.options ?? []), 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedOption,
            onChanged: _handleChanged,
          );
        }),
        if (_isOtherSelected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Please specify...'),
              onChanged: (text) => widget.onChanged(text),
            ),
          ),
      ],
    );
  }
}

/// Choice where a free-writing explanation is always available.
class ChoiceWithFreeWritingQuestion extends StatefulWidget {
  final Question question;
  final dynamic value; // Expecting Map {'selection': String, 'text': String}
  final ValueChanged<dynamic> onChanged;

  const ChoiceWithFreeWritingQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ChoiceWithFreeWritingQuestion> createState() => _ChoiceWithFreeWritingQuestionState();
}

class _ChoiceWithFreeWritingQuestionState extends State<ChoiceWithFreeWritingQuestion> {
  late TextEditingController _controller;
  String? _selection;

  @override
  void initState() {
    super.initState();
    final map = widget.value as Map<String, dynamic>?;
    _selection = map?['selection'];
    _controller = TextEditingController(text: map?['text'] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update() {
    widget.onChanged({
      'selection': _selection,
      'text': _controller.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...(widget.question.options ?? []).map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selection,
            onChanged: (val) {
              setState(() => _selection = val);
              _update();
            },
          );
        }),
        const SizedBox(height: 12),
        const Text('Additional comments:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your explanation here...',
          ),
          onChanged: (_) => _update(),
        ),
      ],
    );
  }
}
