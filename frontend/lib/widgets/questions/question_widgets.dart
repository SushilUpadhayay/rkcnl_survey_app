import 'package:flutter/material.dart';
import '../../services/survey_engine_core.dart';
import '../../theme/app_theme.dart';
import 'base_question_widget.dart';

/// Widget for QuestionType.MultiChoiceSingleSelect
class SingleChoiceWidget extends StatelessWidget {
  final QuestionController controller;

  const SingleChoiceWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = controller.question.options ?? [];

    return BaseQuestionWidget(
      controller: controller,
      child: Column(
        children: options.map((opt) {
          final selected = controller.value == opt;
          return ListTile(
            title: Text(opt,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: tc.textPrimary)),
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.green : tc.border,
            ),
            onTap: () => controller.value = opt,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
      ),
    );
  }
}

/// Widget for QuestionType.MultiChoiceMultiSelect
class MultiChoiceWidget extends StatelessWidget {
  final QuestionController controller;

  const MultiChoiceWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = controller.question.options ?? [];
    final List<String> currentValues = List<String>.from(controller.value ?? []);

    return BaseQuestionWidget(
      controller: controller,
      child: Column(
        children: options.map((opt) {
          final isChecked = currentValues.contains(opt);
          return CheckboxListTile(
            title: Text(opt,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: tc.textPrimary)),
            value: isChecked,
            onChanged: (v) {
              if (v == true) {
                currentValues.add(opt);
              } else {
                currentValues.remove(opt);
              }
              controller.value = currentValues;
            },
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.green,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }
}

/// Widget for QuestionType.OpenEnd
class OpenEndWidget extends StatelessWidget {
  final QuestionController controller;

  const OpenEndWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BaseQuestionWidget(
      controller: controller,
      child: TextField(
        maxLines: 4,
        onChanged: (v) => controller.value = v,
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: controller.value?.toString() ?? '',
            selection: TextSelection.collapsed(offset: (controller.value?.toString() ?? '').length),
          ),
        ),
        decoration: InputDecoration(
          hintText: controller.question.placeholder ?? 'Type your answer here...',
        ),
      ),
    );
  }
}

/// Widget for QuestionType.RatingScale
class RatingScaleWidget extends StatelessWidget {
  final QuestionController controller;

  const RatingScaleWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final max = controller.question.maxRating ?? 5;

    return BaseQuestionWidget(
      controller: controller,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(max, (i) {
          final val = i + 1;
          final isActive = (controller.value ?? 0) >= val;
          return GestureDetector(
            onTap: () => controller.value = val,
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? AppColors.orange : tc.border,
              size: 36,
            ),
          );
        }),
      ),
    );
  }
}

/// Widget for QuestionType.Ranking
class RankingWidget extends StatelessWidget {
  final QuestionController controller;

  const RankingWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final List<String> currentOrder = controller.value != null 
        ? List<String>.from(controller.value) 
        : List<String>.from(controller.question.options ?? []);

    // Initialize controller value if null
    if (controller.value == null && currentOrder.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.value = currentOrder;
      });
    }

    return BaseQuestionWidget(
      controller: controller,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.blue),
                SizedBox(width: 8),
                Text('Drag items to reorder by preference', 
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentOrder.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              final items = List<String>.from(currentOrder);
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
              controller.value = items;
            },
            itemBuilder: (context, index) {
              final item = currentOrder[index];
              return Card(
                key: ValueKey(item),
                elevation: 0,
                color: tc.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: tc.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.green,
                    child: Text('${index + 1}', 
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  title: Text(item, style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.drag_indicator),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget for QuestionType.Matrix
class MatrixWidget extends StatelessWidget {
  final QuestionController controller;

  const MatrixWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final rows = controller.question.matrixRows ?? [];
    final cols = controller.question.matrixColumns ?? [];
    final Map<String, String> currentAnswers = Map<String, String>.from(controller.value ?? {});

    return BaseQuestionWidget(
      controller: controller,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 0,
          headingRowHeight: 40,
          columns: [
            const DataColumn(label: Text('')), // Empty for row labels
            ...cols.map((c) => DataColumn(
              label: Text(c, style: TextStyle(fontWeight: FontWeight.bold, color: tc.textSub, fontSize: 12)),
            )),
          ],
          rows: rows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row, style: TextStyle(fontWeight: FontWeight.bold, color: tc.textPrimary))),
              ...cols.map((col) {
                final isSelected = currentAnswers[row] == col;
                return DataCell(
                  Center(
                    child: Radio<String>(
                      value: col,
                      groupValue: currentAnswers[row],
                      activeColor: AppColors.green,
                      onChanged: (val) {
                        if (val != null) {
                          currentAnswers[row] = val;
                          controller.value = currentAnswers;
                        }
                      },
                    ),
                  ),
                );
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

/// Widget for QuestionType.ChoiceWithAddition
class ChoiceWithAdditionWidget extends StatelessWidget {
  final QuestionController controller;

  const ChoiceWithAdditionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = controller.question.options ?? [];
    final Map<String, dynamic> state = Map<String, dynamic>.from(controller.value ?? {'selected': null, 'other': ''});

    return BaseQuestionWidget(
      controller: controller,
      child: Column(
        children: [
          ...options.map((opt) {
            final selected = state['selected'] == opt;
            return ListTile(
              title: Text(opt, style: TextStyle(fontWeight: FontWeight.w600, color: tc.textPrimary)),
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.green : tc.border,
              ),
              onTap: () {
                state['selected'] = opt;
                controller.value = state;
              },
              contentPadding: EdgeInsets.zero,
            );
          }),
          ListTile(
            title: Text('Other (please specify)', style: TextStyle(fontWeight: FontWeight.w600, color: tc.textPrimary)),
            leading: Icon(
              state['selected'] == 'OTHER_OPTION' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: state['selected'] == 'OTHER_OPTION' ? AppColors.green : tc.border,
            ),
            onTap: () {
              state['selected'] = 'OTHER_OPTION';
              controller.value = state;
            },
            contentPadding: EdgeInsets.zero,
          ),
          if (state['selected'] == 'OTHER_OPTION')
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: TextField(
                onChanged: (v) {
                  state['other'] = v;
                  controller.value = state;
                },
                controller: TextEditingController(text: state['other'] ?? ''),
                decoration: const InputDecoration(hintText: 'Specify other...'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget for QuestionType.ChoiceWithFreeWriting
class ChoiceWithFreeWritingWidget extends StatelessWidget {
  final QuestionController controller;

  const ChoiceWithFreeWritingWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = controller.question.options ?? [];
    final Map<String, dynamic> state = Map<String, dynamic>.from(controller.value ?? {'selected': null, 'notes': ''});

    return BaseQuestionWidget(
      controller: controller,
      child: Column(
        children: [
          ...options.map((opt) {
            final selected = state['selected'] == opt;
            return ListTile(
              title: Text(opt, style: TextStyle(fontWeight: FontWeight.w600, color: tc.textPrimary)),
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.green : tc.border,
              ),
              onTap: () {
                state['selected'] = opt;
                controller.value = state;
              },
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 24),
          Text('Reason / Notes:', style: TextStyle(fontWeight: FontWeight.bold, color: tc.textSub, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            onChanged: (v) {
              state['notes'] = v;
              controller.value = state;
            },
            controller: TextEditingController(text: state['notes'] ?? ''),
            decoration: const InputDecoration(hintText: 'Write your reason here...'),
          ),
        ],
      ),
    );
  }
}

/// Widget for QuestionType.PickingUp (Searchable Dropdown)
class PickingUpWidget extends StatefulWidget {
  final QuestionController controller;

  const PickingUpWidget({super.key, required this.controller});

  @override
  State<PickingUpWidget> createState() => _PickingUpWidgetState();
}

class _PickingUpWidgetState extends State<PickingUpWidget> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = widget.controller.question.options ?? [];
    final filtered = options.where((opt) => opt.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return BaseQuestionWidget(
      controller: widget.controller,
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search items...',
              suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: tc.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: tc.border),
              itemBuilder: (context, index) {
                final opt = filtered[index];
                final selected = widget.controller.value == opt;
                return ListTile(
                  dense: true,
                  title: Text(opt, style: TextStyle(
                    color: selected ? AppColors.green : tc.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  )),
                  trailing: selected ? const Icon(Icons.check, color: AppColors.green, size: 18) : null,
                  onTap: () => widget.controller.value = opt,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for QuestionType.PickupAndRank
class PickupAndRankWidget extends StatefulWidget {
  final QuestionController controller;

  const PickupAndRankWidget({super.key, required this.controller});

  @override
  State<PickupAndRankWidget> createState() => _PickupAndRankWidgetState();
}

class _PickupAndRankWidgetState extends State<PickupAndRankWidget> {
  String _searchQuery = '';
  bool _isRankingPhase = false;

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final options = widget.controller.question.options ?? [];
    final List<String> selectedItems = List<String>.from(widget.controller.value ?? []);
    final filtered = options.where((opt) => opt.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return BaseQuestionWidget(
      controller: widget.controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPhaseTab('1. Select', !_isRankingPhase, tc),
              const SizedBox(width: 8),
              _buildPhaseTab('2. Rank', _isRankingPhase, tc),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isRankingPhase) ...[
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search items to rank...'),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: tc.border), borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: tc.border),
                itemBuilder: (context, index) {
                  final opt = filtered[index];
                  final isSelected = selectedItems.contains(opt);
                  return ListTile(
                    dense: true,
                    title: Text(opt, style: TextStyle(color: tc.textPrimary)),
                    trailing: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, 
                      color: isSelected ? AppColors.green : tc.border),
                    onTap: () {
                      setState(() {
                        if (isSelected) selectedItems.remove(opt);
                        else selectedItems.add(opt);
                        widget.controller.value = selectedItems;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedItems.isEmpty ? null : () => setState(() => _isRankingPhase = true),
                child: Text('Next: Rank ${selectedItems.length} Items'),
              ),
            ),
          ] else ...[
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedItems.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final items = List<String>.from(selectedItems);
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
                widget.controller.value = items;
              },
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return ListTile(
                  key: ValueKey(item),
                  leading: CircleAvatar(radius: 12, backgroundColor: AppColors.green, 
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                  title: Text(item, style: TextStyle(color: tc.textPrimary, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.drag_indicator),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _isRankingPhase = false),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Back to Selection'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseTab(String label, bool active, AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.green : tc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? AppColors.green : tc.border),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : tc.textSub,
      )),
    );
  }
}
