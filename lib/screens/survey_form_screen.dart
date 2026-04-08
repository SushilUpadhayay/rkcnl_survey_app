import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SurveyFormScreen extends StatefulWidget {
  final String surveyId;
  final String respondentId;
  const SurveyFormScreen(
      {super.key, required this.surveyId, required this.respondentId});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  int _currentStep = 0;
  final Map<String, dynamic> _answers = {};
  late Survey _survey;
  late Respondent _respondent;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final appState = context.read<AppState>();
    _survey = appState.surveys.firstWhere((s) => s.id == widget.surveyId);
    _respondent = appState
        .getRespondents(widget.surveyId)
        .firstWhere((r) => r.id == widget.respondentId);
    _answers.addAll(_respondent.answers);
    _initialized = true;
  }

  void _nextStep() {
    if (_currentStep < _survey.questions.length) {
      setState(() => _currentStep++);
      context
          .read<AppState>()
          .saveRespondentDraft(widget.surveyId, _respondent, _answers);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await context
        .read<AppState>()
        .submitRespondent(widget.surveyId, _respondent, _answers);

    if (mounted) {
      Navigator.pop(context);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final tc = context.appColors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          context.go('/dashboard');
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check_circle, color: AppColors.green, size: 72),
              const SizedBox(height: 24),
              Text('Response Saved!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: tc.textPrimary)),
              const SizedBox(height: 12),
              Text('Submission for ${_respondent.name} was successful.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tc.textSub)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.go('/dashboard');
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tc = context.appColors;
    final isReview = _currentStep == _survey.questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: () => _confirmExit()),
        title: Column(
          children: [
            Text('Survey Collection',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tc.textSub)),
            Text(_survey.id,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tc.textPrimary)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: () {
                context.read<AppState>().saveRespondentDraft(
                    widget.surveyId, _respondent, _answers);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft saved successfully')));
              }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(tc),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isReview
                    ? _buildReviewScreen(tc)
                    : _buildQuestionScreen(_survey.questions[_currentStep], tc),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(isReview, tc),
    );
  }

  Widget _buildProgressIndicator(AppThemeColors tc) {
    final progress = (_currentStep + 1) / (_survey.questions.length + 1);
    return Column(
      children: [
        LinearProgressIndicator(
            value: progress, minHeight: 4, backgroundColor: tc.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Respondent: ${_respondent.name}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tc.textSub)),
              Text(
                  'Step ${_currentStep + 1} of ${_survey.questions.length + 1}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tc.textSub)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionScreen(Question q, AppThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: tc.greenLight, borderRadius: BorderRadius.circular(4)),
          child: Text('Question ${_currentStep + 1}',
              style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        const SizedBox(height: 16),
        Text(q.text,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary)),
        if (q.description != null) ...[
          const SizedBox(height: 8),
          Text(q.description!,
              style: TextStyle(fontSize: 14, color: tc.textSub)),
        ],
        const SizedBox(height: 32),
        _buildInput(q, tc),
      ],
    );
  }

  Widget _buildInput(Question q, AppThemeColors tc) {
    switch (q.type) {
      case QuestionType.radio:
        return Column(
          children: q.options!.map((opt) {
            final selected = _answers[q.id] == opt;
            return ListTile(
              title: Text(opt,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: tc.textPrimary)),
              leading: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.green : tc.border,
              ),
              onTap: () => setState(() => _answers[q.id] = opt),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );
      case QuestionType.checkbox:
        final List<String> current = List<String>.from(_answers[q.id] ?? []);
        return Column(
          children: q.options!
              .map((opt) => CheckboxListTile(
                    title: Text(opt,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tc.textPrimary)),
                    value: current.contains(opt),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          current.add(opt);
                        } else {
                          current.remove(opt);
                        }
                        _answers[q.id] = current;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.green,
                    controlAffinity: ListTileControlAffinity.leading,
                  ))
              .toList(),
        );
      case QuestionType.text:
        return TextField(
          maxLines: 4,
          onChanged: (v) => _answers[q.id] = v,
          controller: TextEditingController(text: _answers[q.id] ?? ''),
          decoration: InputDecoration(
              hintText: q.placeholder ?? 'Type your answer here...'),
        );
      case QuestionType.rating:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(q.maxRating ?? 5, (i) {
            final val = i + 1;
            final isActive = (_answers[q.id] ?? 0) >= val;
            return GestureDetector(
              onTap: () => setState(() => _answers[q.id] = val),
              child: Icon(isActive ? Icons.star : Icons.star_border,
                  color: isActive ? AppColors.orange : tc.border, size: 36),
            );
          }),
        );
    }
  }

  Widget _buildReviewScreen(AppThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Submission',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary)),
        const SizedBox(height: 8),
        Text('Please verify all details before submitting.',
            style: TextStyle(color: tc.textSub)),
        const SizedBox(height: 32),
        ..._survey.questions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.text,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: tc.textPrimary)),
                  const SizedBox(height: 8),
                  Text(_formatAnswer(q, _answers[q.id]),
                      style: TextStyle(
                          color: _answers[q.id] != null
                              ? AppColors.green
                              : AppColors.red,
                          fontWeight: FontWeight.w600)),
                  Divider(height: 32, color: tc.border),
                ],
              ),
            )),
      ],
    );
  }

  String _formatAnswer(Question q, dynamic ans) {
    if (ans == null) return 'No answer provided';
    if (ans is List) return ans.isEmpty ? 'No answer provided' : ans.join(', ');
    return ans.toString();
  }

  Widget _buildFooter(bool isReview, AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
          color: tc.surface, border: Border(top: BorderSide(color: tc.border))),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(
                onPressed: _prevStep,
                style:
                    OutlinedButton.styleFrom(minimumSize: const Size(100, 52)),
                child: const Text('Back')),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isReview ? _submit : _nextStep,
              child: Text(isReview ? 'Submit Response' : 'Next Step'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Survey?'),
        content: const Text(
            'Your progress will be saved as a draft. You can continue later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                context.read<AppState>().saveRespondentDraft(
                    widget.surveyId, _respondent, _answers);
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Save & Exit')),
        ],
      ),
    );
  }
}
