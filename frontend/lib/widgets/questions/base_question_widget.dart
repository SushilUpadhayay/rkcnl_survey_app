import 'package:flutter/material.dart';
import '../../services/survey_engine_core.dart';
import '../../theme/app_theme.dart';

/// A wrapper widget that provides consistent styling and error display for all question types.
class BaseQuestionWidget extends StatelessWidget {
  final QuestionController controller;
  final Widget child;

  const BaseQuestionWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tc = context.appColors;
    final q = controller.question;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isVisible) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tc.greenLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    q.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  if (q.isRequired) ...[
                    const SizedBox(width: 4),
                    const Text(
                      '*',
                      style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Question Text
            Text(
              q.text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary,
              ),
            ),
            
            // Description
            if (q.description != null) ...[
              const SizedBox(height: 8),
              Text(
                q.description!,
                style: TextStyle(fontSize: 14, color: tc.textSub),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // The actual input widget
            child,
            
            // Error Message
            if (controller.error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
