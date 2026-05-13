import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A modular widget for matrix/grid questions.
class MatrixQuestion extends StatelessWidget {
  final Question question;
  final Map<String, String>? value; // Row ID -> Selected Column Option
  final ValueChanged<Map<String, String>> onChanged;

  const MatrixQuestion({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final rows = question.matrixRows ?? [];
    final cols = question.matrixColumns ?? [];
    final currentValue = value ?? {};

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 0,
            columns: [
              const DataColumn(label: Text('Aspect', style: TextStyle(fontWeight: FontWeight.bold))),
              ...cols.map((c) => DataColumn(
                label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ],
            rows: rows.map((row) {
              return DataRow(
                cells: [
                  DataCell(Text(row, style: const TextStyle(fontWeight: FontWeight.w500))),
                  ...cols.map((col) {
                    return DataCell(
                      Radio<String>(
                        value: col,
                        groupValue: currentValue[row],
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) {
                          if (val != null) {
                            final newValue = Map<String, String>.from(currentValue);
                            newValue[row] = val;
                            onChanged(newValue);
                          }
                        },
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
