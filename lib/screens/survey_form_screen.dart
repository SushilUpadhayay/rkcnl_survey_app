import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SurveyFormScreen extends StatefulWidget {
  final String surveyId;
  final String respondentId;
  const SurveyFormScreen({super.key, required this.surveyId, required this.respondentId});

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
    _respondent = appState.getRespondents(widget.surveyId).firstWhere((r) => r.id == widget.respondentId);
    _answers.addAll(_respondent.answers);
    _initialized = true;
  }

  void _nextStep() {
    if (_currentStep < _survey.questions.length) {
      setState(() => _currentStep++);
      context.read<AppState>().saveRespondentDraft(widget.surveyId, _respondent, _answers);
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
    
    await context.read<AppState>().submitRespondent(widget.surveyId, _respondent, _answers);
    
    if (mounted) {
      Navigator.pop(context); // Close loader
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle, color: AppColors.green, size: 72),
            const SizedBox(height: 24),
            const Text('Response Saved!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text('Submission for ${_respondent.name} was successful.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSub)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/respondents/${widget.surveyId}');
              },
              child: const Text('Back to Respondents'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isReview = _currentStep == _survey.questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _confirmExit()),
        title: Column(
          children: [
            const Text('Survey Collection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSub)),
            Text(_survey.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.save_outlined), onPressed: () {
            context.read<AppState>().saveRespondentDraft(widget.surveyId, _respondent, _answers);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isReview ? _buildReviewScreen() : _buildQuestionScreen(_survey.questions[_currentStep]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(isReview),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / (_survey.questions.length + 1);
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 4, backgroundColor: AppColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Respondent: ${_respondent.name}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSub)),
              Text('Step ${_currentStep + 1} of ${_survey.questions.length + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSub)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionScreen(Question q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(4)),
          child: Text('Question ${_currentStep + 1}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        const SizedBox(height: 16),
        Text(q.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        if (q.description != null) ...[
          const SizedBox(height: 8),
          Text(q.description!, style: const TextStyle(fontSize: 14, color: AppColors.textSub)),
        ],
        const SizedBox(height: 32),
        _buildInput(q),
      ],
    );
  }

  Widget _buildInput(Question q) {
    switch (q.type) {
      case QuestionType.radio:
        return Column(
          children: q.options!.map((opt) => RadioListTile<String>(
            title: Text(opt, style: const TextStyle(fontWeight: FontWeight.w600)),
            value: opt,
            groupValue: _answers[q.id],
            onChanged: (v) => setState(() => _answers[q.id] = v),
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.green,
          )).toList(),
        );
      case QuestionType.checkbox:
        final List<String> current = List<String>.from(_answers[q.id] ?? []);
        return Column(
          children: q.options!.map((opt) => CheckboxListTile(
            title: Text(opt, style: const TextStyle(fontWeight: FontWeight.w600)),
            value: current.contains(opt),
            onChanged: (v) {
              setState(() {
                if (v == true) current.add(opt); else current.remove(opt);
                _answers[q.id] = current;
              });
            },
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.green,
            controlAffinity: ListTileControlAffinity.leading,
          )).toList(),
        );
      case QuestionType.text:
        return TextField(
          maxLines: 4,
          onChanged: (v) => _answers[q.id] = v,
          controller: TextEditingController(text: _answers[q.id] ?? ''),
          decoration: InputDecoration(hintText: q.placeholder ?? 'Type your answer here...'),
        );
      case QuestionType.rating:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(q.maxRating ?? 5, (i) {
            final val = i + 1;
            final isActive = (_answers[q.id] ?? 0) >= val;
            return GestureDetector(
              onTap: () => setState(() => _answers[q.id] = val),
              child: Icon(isActive ? Icons.star : Icons.star_border, color: isActive ? AppColors.orange : AppColors.border, size: 36),
            );
          }),
        );
    }
  }

  Widget _buildReviewScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Submission', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Please verify all details before submitting.', style: TextStyle(color: AppColors.textSub)),
        const SizedBox(height: 32),
        ..._survey.questions.map((q) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              Text(_formatAnswer(q, _answers[q.id]), style: TextStyle(color: _answers[q.id] != null ? AppColors.green : AppColors.red, fontWeight: FontWeight.w600)),
              const Divider(height: 32),
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

  Widget _buildFooter(bool isReview) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(color: AppColors.surface, border: const Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(minimumSize: const Size(100, 52)), child: const Text('Back')),
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
        content: const Text('Your progress will be saved as a draft. You can continue later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            context.read<AppState>().saveRespondentDraft(widget.surveyId, _respondent, _answers);
            Navigator.pop(context); // Close dialog
            context.pop(); // Go back
          }, child: const Text('Save & Exit')),
        ],
      ),
    );
  }
}
